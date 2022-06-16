//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin

extension BlockchainMetaFetcher {
    enum Fixtures {}
}

extension BlockchainMetaFetcher.Fixtures {
    struct SuccessCacheValid {
        let initialBlockVersion: BlockVersion = 0
        let minimumFee: UInt64 = 10_000_000
        let blockchainService: TestBlockchainService
        let metaFetcher: BlockchainMetaFetcher
        let mockSyncChecker: MockFogSyncChecker
        let consensusService: TestConsensusService
        let transactionSubmitter: TransactionSubmitter

        init() {
            blockchainService = TestBlockchainService(successWithMinimumFee: minimumFee)
            metaFetcher = BlockchainMetaFetcher(
                blockchainService: blockchainService,
                metaCacheTTL: 60,
                targetQueue: DispatchQueue.main)
            mockSyncChecker = MockFogSyncChecker(
                viewIndex: 10,
                ledgerIndex: 10,
                consensusIndex: 10)

            consensusService = TestConsensusService(successWithBlockVersion: initialBlockVersion)
            transactionSubmitter = TransactionSubmitter(
                consensusService: consensusService,
                metaFetcher: metaFetcher,
                syncChecker: ReadWriteDispatchLock(mockSyncChecker))

        }
    }

    struct FailureTxFeeError {
        let initialBlockVersion: BlockVersion = 0
        let minimumFee: UInt64 = 10_000_000
        let blockchainService: TestBlockchainService
        let metaFetcher: BlockchainMetaFetcher
        let mockSyncChecker: MockFogSyncChecker
        let consensusService: TestConsensusService
        let transactionSubmitter: TransactionSubmitter

        init() {
            blockchainService = TestBlockchainService(successWithMinimumFee: minimumFee)
            metaFetcher = BlockchainMetaFetcher(
                blockchainService: blockchainService,
                metaCacheTTL: 60,
                targetQueue: DispatchQueue.main)

            mockSyncChecker = MockFogSyncChecker(
                viewIndex: 10,
                ledgerIndex: 10,
                consensusIndex: 10)

            consensusService = TestConsensusService(
                failureWithResult: .txFeeError,
                blockVersion: initialBlockVersion)
            transactionSubmitter = TransactionSubmitter(
                consensusService: consensusService,
                metaFetcher: metaFetcher,
                syncChecker: ReadWriteDispatchLock(mockSyncChecker))
        }
    }

    struct SuccessEqualBlockVersions {
        let initialBlockVersion: BlockVersion = 0
        let blockchainService: TestBlockchainService
        let metaFetcher: BlockchainMetaFetcher
        let mockSyncChecker: MockFogSyncChecker
        let consensusService: TestConsensusService
        let transactionSubmitter: TransactionSubmitter

        init () {
            blockchainService = TestBlockchainService(successWithBlockVersion: initialBlockVersion)
            metaFetcher = BlockchainMetaFetcher(
                blockchainService: blockchainService,
                metaCacheTTL: 60,
                targetQueue: DispatchQueue.main)

            mockSyncChecker = MockFogSyncChecker(
                viewIndex: 10,
                ledgerIndex: 10,
                consensusIndex: 10)

            consensusService = TestConsensusService(successWithBlockVersion: initialBlockVersion)
            transactionSubmitter = TransactionSubmitter(
                consensusService: consensusService,
                metaFetcher: metaFetcher,
                syncChecker: ReadWriteDispatchLock(mockSyncChecker))
        }
    }

    struct FailureEqualBlockVersions {
        let initialBlockVersion: BlockVersion = 0
        let blockchainService: TestBlockchainService
        let metaFetcher: BlockchainMetaFetcher
        let mockSyncChecker: MockFogSyncChecker
        let consensusService: TestConsensusService
        let transactionSubmitter: TransactionSubmitter

        init() {
            blockchainService = TestBlockchainService(successWithBlockVersion: initialBlockVersion)
            metaFetcher = BlockchainMetaFetcher(
                blockchainService: blockchainService,
                metaCacheTTL: 60,
                targetQueue: DispatchQueue.main)

            mockSyncChecker = MockFogSyncChecker(
                viewIndex: 10,
                ledgerIndex: 10,
                consensusIndex: 10)

            consensusService = TestConsensusService(
                failureWithResult: .tombstoneBlockExceeded,
                blockVersion: initialBlockVersion)
            transactionSubmitter = TransactionSubmitter(
                consensusService: consensusService,
                metaFetcher: metaFetcher,
                syncChecker: ReadWriteDispatchLock(mockSyncChecker))
        }
    }

    struct FailureMismatchedBlockVersions {
        let initialBlockVersion: BlockVersion = 0
        let mismtachedBlockVersion: BlockVersion = 1
        let blockchainService: TestBlockchainService
        let metaFetcher: BlockchainMetaFetcher
        let mockSyncChecker: MockFogSyncChecker
        let consensusService: TestConsensusService
        let transactionSubmitter: TransactionSubmitter

        init() {
            blockchainService = TestBlockchainService(successWithBlockVersion: initialBlockVersion)
            metaFetcher = BlockchainMetaFetcher(
                blockchainService: blockchainService,
                metaCacheTTL: 60,
                targetQueue: DispatchQueue.main)

            mockSyncChecker = MockFogSyncChecker(
                viewIndex: 10,
                ledgerIndex: 10,
                consensusIndex: 10)

            consensusService = TestConsensusService(
                failureWithResult: .tombstoneBlockExceeded,
                blockVersion: mismtachedBlockVersion)
            transactionSubmitter = TransactionSubmitter(
                consensusService: consensusService,
                metaFetcher: metaFetcher,
                syncChecker: ReadWriteDispatchLock(mockSyncChecker))
        }
    }

    struct SuccessMismatchedBlockVersions {
        let initialBlockVersion: BlockVersion = 0
        let mismtachedBlockVersion: BlockVersion = 1
        let blockchainService: TestBlockchainService
        let metaFetcher: BlockchainMetaFetcher
        let mockSyncChecker: MockFogSyncChecker
        let consensusService: TestConsensusService
        let transactionSubmitter: TransactionSubmitter

        init() {
            blockchainService = TestBlockchainService(successWithBlockVersion: initialBlockVersion)
            metaFetcher = BlockchainMetaFetcher(
                blockchainService: blockchainService,
                metaCacheTTL: 60,
                targetQueue: DispatchQueue.main)

            mockSyncChecker = MockFogSyncChecker(
                viewIndex: 10,
                ledgerIndex: 10,
                consensusIndex: 10)

            consensusService = TestConsensusService(successWithBlockVersion: mismtachedBlockVersion)
            transactionSubmitter = TransactionSubmitter(
                consensusService: consensusService,
                metaFetcher: metaFetcher,
                syncChecker: ReadWriteDispatchLock(mockSyncChecker))
        }
    }
}
