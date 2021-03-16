//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_function_chains

import Foundation
import LibMobileCoin
@testable import MobileCoin

protocol MockFogServiceProtocol: FogBlockService, FogKeyImageService, FogViewService {
    func query(requestAad: FogView_QueryRequestAAD, request: FogView_QueryRequest)
        -> Result<FogView_QueryResponse, ConnectionError>
    func getBlocks(request: FogLedger_BlockRequest)
        -> Result<FogLedger_BlockResponse, ConnectionError>
    func checkKeyImages(request: FogLedger_CheckKeyImagesRequest)
        -> Result<FogLedger_CheckKeyImagesResponse, ConnectionError>
}

extension MockFogServiceProtocol {
    func query(
        requestAad: FogView_QueryRequestAAD,
        request: FogView_QueryRequest,
        completion: @escaping (Result<FogView_QueryResponse, ConnectionError>) -> Void
    ) {
        DispatchQueue.main.async {
            completion(self.query(requestAad: requestAad, request: request))
        }
    }

    func getBlocks(
        request: FogLedger_BlockRequest,
        completion: @escaping (Result<FogLedger_BlockResponse, ConnectionError>) -> Void
    ) {
        DispatchQueue.main.async { completion(self.getBlocks(request: request)) }
    }

    func checkKeyImages(
        request: FogLedger_CheckKeyImagesRequest,
        completion: @escaping (Result<FogLedger_CheckKeyImagesResponse, ConnectionError>) -> Void
    ) {
        DispatchQueue.main.async { completion(self.checkKeyImages(request: request)) }
    }
}

class MockFogService: MockFogServiceProtocol {
    let accountKey: AccountKey
    private let rng: @convention(c) (UnsafeMutableRawPointer?) -> UInt64 = testRngCallback
    private let rngContext = TestRng()

    init(accountKey: AccountKey) {
        self.accountKey = accountKey
    }

    var viewServiceRngKeys: [FogRngKey] {
        []
    }

    var viewServiceTxOuts: [[PartialTxOut]] {
        []
    }

    var viewServiceMissedBlockRanges: [Range<UInt64>] {
        []
    }

    var blockServiceTxOuts: [[TxOut]] {
        []
    }

    var keyImageServiceSpentKeyImages: [(keyImage: KeyImage, spentAtBlockIndex: UInt64)] {
        []
    }
}

extension MockFogService {
    var viewServiceRngRecords: [(nonce: FogRngKey, startBlock: UInt64)] {
        viewServiceRngKeys.map { (nonce: $0, startBlock: 0) }
    }

    func viewServiceTxOutRecords() -> [(searchKey: Data, txOutRecord: FogView_TxOutRecord)] {
        let viewTxOuts = self.viewServiceTxOuts
        if let rngKey = viewServiceRngRecords.first?.nonce, !viewTxOuts.isEmpty {
            let rng: FogRng
            do {
                rng = try FogRng.make(accountKey: accountKey, fogRngKey: rngKey).get()
            } catch {
                fatalError("Error: \(Self.self).\(#function): \(error)")
            }
            var globalIndex: UInt64 = 0
            return viewTxOuts.enumerated().flatMap { blockIndex, blockTxOuts in
                blockTxOuts.map { txOut in
                    var txOutRecord = FogView_TxOutRecord(txOut)
                    txOutRecord.txOutGlobalIndex = globalIndex
                    globalIndex += 1
                    txOutRecord.blockIndex = UInt64(blockIndex)
                    txOutRecord.timestamp = .max
                    return (searchKey: rng.advance(), txOutRecord: txOutRecord)
                }
            }
        } else {
            return []
        }
    }

    var blockServiceBlocks: [FogLedger_Block] {
        var cummulativeTxOutCount: UInt64 = 0
        return blockServiceTxOuts.enumerated().map { index, txOuts in
            cummulativeTxOutCount += UInt64(txOuts.count)
            var block = FogLedger_Block()
            block.index = UInt64(index)
            block.globalTxoCount = cummulativeTxOutCount
            block.outputs = txOuts.map { External_TxOut($0) }
            return block
        }
    }

    var defaultBlockCount: UInt64 {
        var possibleValues = viewServiceMissedBlockRanges.map { $0.upperBound }
        possibleValues.append(contentsOf: blockServiceBlocks.map { $0.index + 1 })
        possibleValues.append(contentsOf: viewServiceRngRecords.map { $0.startBlock + 1 })
        possibleValues
            .append(contentsOf: keyImageServiceSpentKeyImages.map { $0.spentAtBlockIndex + 1 })
        return possibleValues.max() ?? 0
    }

    var defaultViewServiceBlockCount: UInt64 {
        defaultBlockCount
    }

    var defaultKeyImageServiceBlockCount: UInt64 {
        defaultBlockCount
    }

    var defaultLastKnownBlockCount: UInt64 {
        defaultBlockCount
    }

    var defaultLastKnownBlockCumulativeTxOutCount: UInt64 {
        blockServiceBlocks.map { $0.globalTxoCount }.max() ?? 0
    }

    func query(requestAad: FogView_QueryRequestAAD, request: FogView_QueryRequest)
        -> Result<FogView_QueryResponse, ConnectionError>
    {
        defaultQueryResponse(request: request)
    }

    func defaultQueryResponse(request: FogView_QueryRequest)
        -> Result<FogView_QueryResponse, ConnectionError>
    {
        var response = FogView_QueryResponse()
        response.highestProcessedBlockCount = defaultViewServiceBlockCount
        response.missedBlockRanges = viewServiceMissedBlockRanges.map { FogCommon_BlockRange($0) }
        response.rngs = viewServiceRngRecords.map {
            FogView_RngRecord(nonce: $0.nonce, startBlock: $0.startBlock)
        }
        response.txOutSearchResults = request.getTxos.map { requestSearchKey in
            var result = FogView_TxOutSearchResult()
            result.searchKey = requestSearchKey
            if let foundTxOut =
                viewServiceTxOutRecords().first(where: { $0.searchKey == requestSearchKey })
            {
                result.resultCodeEnum = .found
                do {
                    result.ciphertext = try FogViewUtils.encryptTxOutRecord(
                        txOutRecord: foundTxOut.txOutRecord,
                        publicAddress: accountKey.publicAddress,
                        rng: rng,
                        rngContext: rngContext).get()
                } catch {
                    fatalError("Error: \(Self.self).\(#function): \(error)")
                }
            } else {
                result.resultCodeEnum = .notFound
            }
            return result
        }
        response.lastKnownBlockCount = defaultLastKnownBlockCount
        response.lastKnownBlockCumulativeTxoCount = defaultLastKnownBlockCumulativeTxOutCount
        return .success(response)
    }

    func getBlocks(request: FogLedger_BlockRequest)
        -> Result<FogLedger_BlockResponse, ConnectionError>
    {
        .success(defaultBlocksResponse(request: request))
    }

    func defaultBlocksResponse(request: FogLedger_BlockRequest) -> FogLedger_BlockResponse {
        var response = FogLedger_BlockResponse()
        response.blocks = request.ranges.flatMap { blockRange in
            (blockRange.startBlock..<blockRange.endBlock).compactMap { blockIndex in
                blockServiceBlocks.first(where: { $0.index == blockIndex })
            }
        }
        response.numBlocks = defaultLastKnownBlockCount
        response.globalTxoCount = defaultLastKnownBlockCumulativeTxOutCount
        return response
    }

    func checkKeyImages(request: FogLedger_CheckKeyImagesRequest)
        -> Result<FogLedger_CheckKeyImagesResponse, ConnectionError>
    {
        .success(defaultKeyImagesResponse(request: request))
    }

    func defaultKeyImagesResponse(request: FogLedger_CheckKeyImagesRequest)
        -> FogLedger_CheckKeyImagesResponse
    {
        var response = FogLedger_CheckKeyImagesResponse()
        response.numBlocks = defaultKeyImageServiceBlockCount
        response.globalTxoCount = defaultLastKnownBlockCumulativeTxOutCount
        response.results = request.queries.map {
            let keyImageQuery = $0.keyImage.data
            var result = FogLedger_KeyImageResult()
            result.keyImage.data = keyImageQuery
            if let keyImage = keyImageServiceSpentKeyImages
                .first(where: { $0.keyImage.data == keyImageQuery })
            {
                result.keyImageResultCodeEnum = .spent
                result.spentAt = keyImage.spentAtBlockIndex
            } else {
                result.keyImageResultCodeEnum = .notSpent
                result.spentAt = .max
            }
            result.timestampResultCodeEnum = .unavailable
            result.timestamp = .max
            return result
        }
        return response
    }
}
