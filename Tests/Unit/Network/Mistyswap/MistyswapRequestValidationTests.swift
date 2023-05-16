//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
@testable import LibMobileCoin
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
        XCTAssertEqual(proto.srcAssetID, fixtures.srcAssetID)
        XCTAssertEqual(proto.srcExpectedAmount, fixtures.srcExpectedAmount)
        XCTAssertEqual(proto.dstAssetID, fixtures.dstAssetID)
        XCTAssertEqual(proto.dstAddress, fixtures.dstAddress)
        XCTAssertEqual(proto.dstAddressTag, fixtures.dstAddressTag)
        XCTAssertEqual(proto.minDstReceivedAmount, fixtures.minDstReceivedAmount)
        XCTAssertEqual(proto.maxFeeAmountInDstTokens, fixtures.maxFeeAmountInDstTokens)
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
