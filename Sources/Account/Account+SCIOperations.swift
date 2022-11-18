//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//

import Foundation

extension Account {
    struct SCIOperations {
        private let serialQueue: DispatchQueue
        private let account: ReadWriteDispatchLock<Account>
        private let metaFetcher: BlockchainMetaFetcher
        private let txOutSelector: TxOutSelector
        private let signedContingentInputCreator: SignedContingentInputCreator

        init(
            account: ReadWriteDispatchLock<Account>,
            fogMerkleProofService: FogMerkleProofService,
            fogResolverManager: FogResolverManager,
            metaFetcher: BlockchainMetaFetcher,
            txOutSelectionStrategy: TxOutSelectionStrategy,
            mixinSelectionStrategy: MixinSelectionStrategy,
            rngSeed: RngSeed,
            targetQueue: DispatchQueue?
        ) {
            self.serialQueue = DispatchQueue(
                label: "com.mobilecoin.\(Account.self).\(Self.self))",
                target: targetQueue)
            self.account = account
            self.metaFetcher = metaFetcher
            self.txOutSelector = TxOutSelector(txOutSelectionStrategy: txOutSelectionStrategy)
            self.signedContingentInputCreator = SignedContingentInputCreator(
                accountKey: account.accessWithoutLocking.accountKey,
                fogMerkleProofService: fogMerkleProofService,
                fogResolverManager: fogResolverManager,
                mixinSelectionStrategy: mixinSelectionStrategy,
                rngSeed: rngSeed,
                targetQueue: targetQueue)
        }

        private func verifyBlockVersion(
            _ blockVersion: BlockVersion,
            _ completion: @escaping (
                Result<SignedContingentInput, SignedContingentInputCreationError>) -> Void
        ) -> Bool {
            // verify block version >= 3
            guard blockVersion >= 3 else {
                serialQueue.async {
                    completion(.failure(.invalidBlockVersion(
                        "Block version must be > 3 for SCI support")))
                }
                return false
            }
            return true
        }

        private func verifyAmountIsNonZero(
            _ amount: Amount,
            _ actionDescription: String,
            _ completion: @escaping (
                Result<SignedContingentInput, SignedContingentInputCreationError>) -> Void
        ) -> Bool {
            guard amount.value > 0 else {
                let errorMessage = "createSignedContingentInput failure: " +
                    "Cannot \(actionDescription) 0 \(amount.tokenId)"
                logger.error(errorMessage, logFunction: false)
                serialQueue.async {
                    completion(.failure(.invalidInput(errorMessage)))
                }
                return false
            }
            return true
        }

        private func logTxOuts(_ txOuts: [KnownTxOut], _ message: String) {
            logger.info(
                "\(message): " +
                    """
                        0x\(redacting: txOuts.map {
                            $0.publicKey.hexEncodedString()
                        })
                    """,
                logFunction: false)
        }

        private func logUnspentTxOuts(
            _ recipient: PublicAddress,
            _ amountToSend: Amount,
            _ amountToReceive: Amount,
            _ txOuts: [KnownTxOut]
        ) {
            logger.info(
                "Creating signed contingent input to recipient: \(redacting: recipient), " +
                    "amountToSend: \(redacting: amountToSend), " +
                    "amountToRecieve: \(redacting: amountToReceive), " +
                    "unspentTxOutValues: \(redacting: txOuts.map { $0.value })",
                logFunction: false)
        }

        func createSignedContingentInput(
            to recipient: PublicAddress,
            memoType: MemoType,
            amountToSend: Amount,
            amountToReceive: Amount,
            completion: @escaping (
                Result<SignedContingentInput, SignedContingentInputCreationError>
            ) -> Void
        ) {
            let functionName = "createSignedContingentInput"

            guard verifyAmountIsNonZero(amountToSend, "send", completion) else {
                return
            }

            guard verifyAmountIsNonZero(amountToReceive, "receive", completion) else {
                return
            }

            // get all unspent txOuts
            let (unspentTxOuts, ledgerBlockCount) =
            account.readSync {
                ($0.unspentTxOuts(tokenId: amountToSend.tokenId), $0.knowableBlockCount)
            }
            logUnspentTxOuts(recipient, amountToSend, amountToReceive, unspentTxOuts)

            // fee is zero here, because the fee will be covered by the consumer of the SCI
            switch txOutSelector
                .selectTransactionInputs(amount: amountToSend, fee: 0, fromTxOuts: unspentTxOuts)
            {
            case .success(let txOutsToSpend):
                metaFetcher.blockVersion {
                    switch $0 {
                    case .success(let blockVersion):

                        guard verifyBlockVersion(blockVersion, completion) else {
                            return
                        }

                        logTxOuts(txOutsToSpend, "SCI preparation selected txOutsToSpend")

                        signedContingentInputCreator.createSignedContingentInput(
                            inputs: txOutsToSpend,
                            recipient: recipient,
                            memoType: memoType,
                            amountToSend: amountToSend,
                            amountToReceive: amountToReceive,
                            tombstoneBlockIndex: ledgerBlockCount + 50,
                            blockVersion: blockVersion) { result in
                            serialQueue.async {
                                completion(result)
                            }
                        }
                    case .failure(let error):
                        logger.info("\(functionName) failure: \(error)", logFunction: false)

                        serialQueue.async {
                            completion(.failure(.connectionError(error)))
                        }
                    }
                }

            case .failure(let error):
                logger.info("\(functionName) failure: \(error)", logFunction: false)
                serialQueue.async {
                    completion(.failure(SignedContingentInputCreationError.create(from: error)))
                }
            }
        }
    }
}
