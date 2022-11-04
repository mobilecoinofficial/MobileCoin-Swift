//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//

// swiftlint:disable closure_body_length function_body_length

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

        func createSignedContingentInput(
            to recipient: PublicAddress,
            memoType: MemoType,
            amountToSend: Amount,
            amountToReceive: Amount,
            completion: @escaping (
                Result<SignedContingentInput, SignedContingentInputCreationError>
            ) -> Void
        ) {
            guard amountToSend.value > 0 else {
                let errorMessage = "createSignedContingentInput failure: " +
                    "Cannot spend 0 \(amountToSend.tokenId)"
                logger.error(errorMessage, logFunction: false)
                serialQueue.async {
                    completion(.failure(.invalidInput(errorMessage)))
                }
                return
            }

            guard amountToReceive.value > 0 else {
                let errorMessage = "createSignedContingentInput failure: " +
                    "Cannot receive 0 \(amountToReceive.tokenId)"
                logger.error(errorMessage, logFunction: false)
                serialQueue.async {
                    completion(.failure(.invalidInput(errorMessage)))
                }
                return
            }

            // get all unspent txouts (getUnspentTxOuts() ?)
            let (unspentTxOuts, ledgerBlockCount) =
            account.readSync {
                ($0.unspentTxOuts(tokenId: amountToSend.tokenId), $0.knowableBlockCount)
            }
            logger.info(
                "Creating signed contingent input to recipient: \(redacting: recipient), " +
                    "amountToSpend: \(redacting: amountToSend), " +
                    "amountToRecieve: \(redacting: amountToReceive), " +
                    "unspentTxOutValues: \(redacting: unspentTxOuts.map { $0.value })",
                logFunction: false)

            // check that total available is > amount to spend
            // - this is done by txOutSelector, which will return an error if there are not
            //   enough funds from the unspentTxOuts
            // - fee is zero here, because the fee will be covered by the consumer of the SCI
            switch txOutSelector
                .selectTransactionInputs(amount: amountToSend, fee: 0, fromTxOuts: unspentTxOuts)
                .mapError({ error -> TransactionPreparationError in
                    switch error {
                    case .insufficientTxOuts:
                        return .insufficientBalance()
                    case .defragmentationRequired:
                        return .defragmentationRequired()
                    }
                })
            {
            case .success(let txOutsToSpend):
                metaFetcher.blockVersion {
                    switch $0 {
                    case .success(let blockVersion):

                        // verify block version >= 3
                        guard blockVersion >= 3 else {
                            serialQueue.async {
                                completion(.failure(.invalidBlockVersion(
                                    "Block version must be > 3 for SCI support")))
                            }
                            return
                        }

                        logger.info(
                            "SCI preparation selected txOutsToSpend: " +
                                """
                                    0x\(redacting: txOutsToSpend.map {
                                        $0.publicKey.hexEncodedString()
                                    })
                                """,
                            logFunction: false)

                        // set tombstone block index
                        let tombstoneBlockIndex = ledgerBlockCount + 50

                        signedContingentInputCreator.createSignedContingentInput(
                            inputs: txOutsToSpend,
                            recipient: recipient,
                            memoType: memoType,
                            amountToSend: amountToSend,
                            amountToReceive: amountToReceive,
                            tombstoneBlockIndex: tombstoneBlockIndex,
                            blockVersion: blockVersion) { result in
                                completion(result.mapError {
                                    let error: SignedContingentInputCreationError
                                    switch $0 {
                                    case .invalidInput(let reason):
                                        error = .invalidInput(reason)
                                    case .defragmentationRequired(let reason):
                                        error = .defragmentationRequired(reason)
                                    case .insufficientBalance(let reason):
                                        error = .insufficientBalance(reason)
                                    case .connectionError(let reason):
                                        error = .connectionError(reason)
                                    }
                                    return error
                                })
                        }
                    case .failure(let error):
                        logger.info(
                            "prepareSignedContingentInput failure: \(error)",
                            logFunction: false)

                        serialQueue.async {
                            completion(.failure(.connectionError(error)))
                        }
                    }
                }

            case .failure(let error):
                logger.info("prepareSignedContingentInput failure: \(error)", logFunction: false)
                serialQueue.async {
                    completion(.failure(SignedContingentInputCreationError.create(from: error)))
                }
            }
        }
    }
}
