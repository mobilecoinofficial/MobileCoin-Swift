//
//  Copyright (c) 2020-2025 MobileCoin. All rights reserved.
//

// swiftlint:disable function_parameter_count multiline_function_chains function_body_length
// swiftlint:disable array_init

import Foundation

struct ProofOfReserveSignedContingentInputCreator {
    private let serialQueue: DispatchQueue
    private let accountKey: AccountKey
    private let selfPaymentAddress: PublicAddress
    private let fogResolverManager: FogResolverManager
    private let fogMerkleProofFetcher: FogMerkleProofFetcher
    private let rng: MobileCoinRng

    init(
        accountKey: AccountKey,
        fogMerkleProofService: FogMerkleProofService,
        fogResolverManager: FogResolverManager,
        rngSeed: RngSeed,
        targetQueue: DispatchQueue?
    ) {
        self.serialQueue = DispatchQueue(
            label: "com.mobilecoin.\(Account.self).\(Self.self)",
            target: targetQueue)
        self.accountKey = accountKey
        self.selfPaymentAddress = accountKey.publicAddress
        self.fogResolverManager = fogResolverManager
        self.fogMerkleProofFetcher = FogMerkleProofFetcher(
            fogMerkleProofService: fogMerkleProofService,
            targetQueue: targetQueue)
        self.rng = MobileCoinChaCha20Rng(rngSeed: rngSeed)
    }

    func createSignedContingentInput(
        input: KnownTxOut,
        fogTombstoneBlockIndex: UInt64,
        blockVersion: BlockVersion,
        completion: @escaping (
            Result<SignedContingentInput, SignedContingentInputCreationError>
        ) -> Void
    ) {
        performAsync(body1: { callback in
            fogResolverManager.fogResolver(
                addresses: [selfPaymentAddress],
                desiredMinPubkeyExpiry: fogTombstoneBlockIndex,
                completion: callback)
        }, body2: { callback in
            prepareInput(input: input, completion: callback)
        }, completion: {
            completion($0.mapError { .connectionError($0) }
                .flatMap { fogResolver, preparedInput in
                    SignedContingentInputBuilder.build(
                        inputs: [preparedInput],
                        accountKey: self.accountKey,
                        memoType: .recoverable,
                        amountToSend: input.amount,
                        // UInt64.max to make this SCI not spendable
                        amountToReceive: Amount(value: UInt64.max, tokenId: input.tokenId),
                        // Block index in the past to make this SCI not spendable
                        tombstoneBlockIndex: 1,
                        fogResolver: fogResolver,
                        blockVersion: blockVersion,
                        rng: self.rng
                    ).mapError { .invalidInput(String(describing: $0)) }
                })
        })
    }

    private func prepareInput(
        input: KnownTxOut,
        ledgerTxOutCount: UInt64? = nil,
        merkleRootBlock: UInt64? = nil,
        completion: @escaping (Result<PreparedTxInput, ConnectionError>) -> Void
    ) {
        fogMerkleProofFetcher.getOutputs(
            globalIndicesArray: [[input.globalIndex]],
            merkleRootBlock: input.block.index,
            maxNumIndicesPerQuery: 100
        ) {
            self.processFetchResults(
                $0,
                input: input,
                ledgerTxOutCount: ledgerTxOutCount,
                completion: completion)
        }
    }

    private func processFetchResults(
        _ results: Result<[[(TxOut, TxOutMembershipProof)]], FogMerkleProofFetcherError>,
        input: KnownTxOut,
        ledgerTxOutCount: UInt64?,
        completion: @escaping (Result<PreparedTxInput, ConnectionError>) -> Void
    ) {
        switch results {
        case .success(let inputsMixinOutputs):
            completion(PreparedTxInput.make(knownTxOut: input, ring: inputsMixinOutputs[0])
                .mapError { .invalidServerResponse(String(describing: $0)) })
        case .failure(let error):
            switch error {
            case .connectionError(let connectionError):
                logger.error("FetchMerkleProofs error: \(connectionError)", logFunction: false)
                completion(.failure(connectionError))
            case let .outOfBounds(blockCount: blockCount, ledgerTxOutCount: responseTxOutCount):
                if let ledgerTxOutCount = ledgerTxOutCount {
                    let errorMessage = "Fog GetMerkleProof returned doesNotExist, even though " +
                        "txo indices were limited by globalTxoCount returned by previous call to " +
                        "GetMerkleProof. Previously returned globalTxoCount: " +
                        "\(ledgerTxOutCount), response globalTxoCount: " +
                        "\(responseTxOutCount), response blockCount: \(blockCount)"
                    logger.error(errorMessage, logFunction: false)
                    completion(.failure(.invalidServerResponse(errorMessage)))
                } else {
                    // Retry, making sure we limit mixin indices to txo count
                    // returned by the server. Uses blockCount returned by server for
                    // merkleRootBlock.
                    prepareInput(
                        input: input,
                        ledgerTxOutCount: responseTxOutCount,
                        merkleRootBlock: blockCount,
                        completion: completion)
                }
            }
        }
    }
}
