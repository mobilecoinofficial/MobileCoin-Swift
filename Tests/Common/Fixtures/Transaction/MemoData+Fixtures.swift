//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin
@testable import LibMobileCoin
import XCTest

enum MemoData {
    struct Fixtures {}
}

extension MemoData.Fixtures {
    struct Shared {
        let txOutPublicKey: RistrettoPublic
        
        init() throws {
            self.txOutPublicKey = try Self.getTxOutPublicKey()
        }
    }
    
    struct DestinationMemo {
        let accountKey: AccountKey
        let expectedMemoData: Data64
        let fee: UInt64 = Self.expectedFee
        let totalOutlay: UInt64 = Self.expectedTotalOutlay
        let numberOfRecipients: UInt8 = Self.expectedNumberOfRecipients

        init() throws {
            self.accountKey = try AccountKey.Fixtures.AliceAndBob().alice
            self.expectedMemoData = try Self.getExpectedMemoData()
        }
    }
    
    struct SenderMemo {
        let senderAccountKey: AccountKey
        let recieverAccountKey: AccountKey
        let txOutPublicKey: RistrettoPublic
        let expectedMemoData: Data64

        init() throws {
            self.senderAccountKey = try AccountKey.Fixtures.AliceAndBob().alice
            self.recieverAccountKey = try AccountKey.Fixtures.AliceAndBob().bob
            self.txOutPublicKey = try MemoData.Fixtures.Shared().txOutPublicKey
            self.expectedMemoData = try Self.getExpectedMemoData()
        }
    }
    
    struct SenderWithPaymentRequestMemo {
        let senderAccountKey: AccountKey
        let recieverAccountKey: AccountKey
        let txOutPublicKey: RistrettoPublic
        let expectedMemoData: Data64
        let paymentRequestId: UInt64 = Self.expectedPaymentRequestId

        init() throws {
            self.senderAccountKey = try AccountKey.Fixtures.AliceAndBob().alice
            self.recieverAccountKey = try AccountKey.Fixtures.AliceAndBob().bob
            self.txOutPublicKey = try MemoData.Fixtures.Shared().txOutPublicKey
            self.expectedMemoData = try Self.getExpectedMemoData()
        }
    }
}

extension MemoData.Fixtures.Shared {
    static let txOutPublicKeyHex =
        """
        c235c13c4dedd808e95f428036716d52561fad7f51ce675f4d4c9c1fa1ea2165
        """
    
    static func getTxOutPublicKey() throws -> RistrettoPublic {
        try XCTUnwrap(
                RistrettoPublic(try XCTUnwrap(
                                    Data(hexEncoded: txOutPublicKeyHex))))
    }
}
    
extension MemoData.Fixtures.DestinationMemo {
    
    static let expectedFee: UInt64 = 3
    static let expectedTotalOutlay: UInt64 = 100
    static let expectedNumberOfRecipients: UInt8 = 1
    
    static func getExpectedMemoData() throws -> Data64 {
        try XCTUnwrap(Data64(
                        XCTUnwrap(Data(hexEncoded: validMemoDataHexBytes))))
    }
    
    static var validMemoDataHexBytes: String =
        """
        ccb5a98f0c0c42f68491e5e0c936245201000000000000040000000000000064\
        0000000000000000000000000000000000000000000000000000000000000000
        """
}

extension MemoData.Fixtures.SenderMemo {
    static func getExpectedMemoData() throws -> Data64 {
        try XCTUnwrap(Data64(
                        XCTUnwrap(Data(hexEncoded: validMemoDataHexBytes))))
    }

    static var validMemoDataHexBytes: String =
        """
        ccb5a98f0c0c42f68491e5e0c936245200000000000000000000000000000000\
        00000000000000000000000000000000bf2eef7c5c35df8f909e40fbd118e426
        """
}
    
extension MemoData.Fixtures.SenderWithPaymentRequestMemo {
    
    static let expectedPaymentRequestId: UInt64 = 17014
    
    static func getExpectedMemoData() throws -> Data64 {
        try XCTUnwrap(Data64(
                        XCTUnwrap(Data(hexEncoded: validMemoDataHexBytes))))
    }

    static var validMemoDataHexBytes: String =
        """
        ccb5a98f0c0c42f68491e5e0c936245200000000000042760000000000000000\
        0000000000000000000000000000000007c61e75690f221bf0834b22e6833820
        """
}
