//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif
@testable import MobileCoin
import XCTest

class MistyswapRequestValidationTests: XCTestCase {
    func testGoodJSON() throws {
        let fixtures = try Mistyswap.Fixtures.InitiateOfframp()

        let proto = try XCTUnwrapSuccess(Mistyswap_InitiateOfframpRequest.make(
            mixinCredentialsJSON: fixtures.goodJSON,
            srcAssetID: fixtures.srcAssetID,
            srcExpectedAmount: fixtures.srcExpectedAmount,
            dstAssetID: fixtures.dstAssetID,
            dstAddress: fixtures.dstAddress,
            dstAddressTag: fixtures.dstAddressTag,
            minDstReceivedAmount: fixtures.minDstReceivedAmount,
            maxFeeAmountInDstTokens: fixtures.maxFeeAmountInDstTokens
        ))

        XCTAssertEqual(proto.mixinCredentialsJson, fixtures.goodJSON)
        XCTAssertEqual(proto.params.srcAssetID, fixtures.srcAssetID)
        XCTAssertEqual(proto.params.srcExpectedAmount, fixtures.srcExpectedAmount)
        XCTAssertEqual(proto.params.dstAssetID, fixtures.dstAssetID)
        XCTAssertEqual(proto.params.dstAddress, fixtures.dstAddress)
        XCTAssertEqual(proto.params.dstAddressTag, fixtures.dstAddressTag)
        XCTAssertEqual(proto.params.minDstReceivedAmount, fixtures.minDstReceivedAmount)
        XCTAssertEqual(proto.params.maxFeeAmountInDstTokens, fixtures.maxFeeAmountInDstTokens)
    }

    func testBadJSON() throws {
        let fixtures = try Mistyswap.Fixtures.InitiateOfframp()

        try XCTUnwrapFailure(Mistyswap_InitiateOfframpRequest.make(
            mixinCredentialsJSON: fixtures.badJSON,
            srcAssetID: fixtures.srcAssetID,
            srcExpectedAmount: fixtures.srcExpectedAmount,
            dstAssetID: fixtures.dstAssetID,
            dstAddress: fixtures.dstAddress,
            dstAddressTag: fixtures.dstAddressTag,
            minDstReceivedAmount: fixtures.minDstReceivedAmount,
            maxFeeAmountInDstTokens: fixtures.maxFeeAmountInDstTokens
        ))
    }

    func testForgetGoodOfframpID() throws {
        let fixtures = try Mistyswap.Fixtures.ForgetOfframp()

        let proto = try XCTUnwrapSuccess(Mistyswap_ForgetOfframpRequest.make(
            offrampID: fixtures.offrampID.data
        ))
        XCTAssertEqual(proto.offrampID, fixtures.offrampID.data)
    }

    func testForgetBadOfframpID() throws {
        let fixtures = try Mistyswap.Fixtures.ForgetOfframp()

        try XCTUnwrapFailure(Mistyswap_ForgetOfframpRequest.make(
            offrampID: fixtures.badOfframpID
        ))
    }

    func testGetStatusGoodOfframpID() throws {
        let fixtures = try Mistyswap.Fixtures.GetOfframpStatus()

        let proto = try XCTUnwrapSuccess(Mistyswap_GetOfframpStatusRequest.make(
            offrampID: fixtures.offrampID.data
        ))
        XCTAssertEqual(proto.offrampID, fixtures.offrampID.data)
    }

    func testGetStatusBadOfframpID() throws {
        let fixtures = try Mistyswap.Fixtures.GetOfframpStatus()

        try XCTUnwrapFailure(Mistyswap_GetOfframpStatusRequest.make(
            offrampID: fixtures.badOfframpID
        ))
    }

}
