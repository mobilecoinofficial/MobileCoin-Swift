//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin
t mimport XCTest

enum MemoData {
    struct Fixtures {}
}

extension MemoData.Fixtures {
    struct Shared {
        let txOutPublicKey: RistrettoPublic
        let badTxOutPublicKey: RistrettoPublic
        
        init() throws {
            self.txOutPublicKey = try Self.getTxOutPublicKey()
            self.badTxOutPublicKey = try Self.getBadTxOutPublicKey()
        }
    }
    
    struct DefaultDestinationMemo {
        let accountKey: AccountKey
        let expectedMemoData: Data64
        let fee: UInt64
        let totalOutlay: UInt64
        let numberOfRecipients: PositiveUInt8

        init() throws {
            self.accountKey = try AccountKey.Fixtures.AliceAndBob().alice
            self.expectedMemoData = try Self.getExpectedMemoData()
            self.fee = Self.expectedFee
            self.totalOutlay = Self.expectedTotalOutlay
            self.numberOfRecipients = Self.expectedNumberOfRecipients
        }
    }
    
    struct DestinationZeroOutlayMemo {
        let accountKey: AccountKey
        let expectedMemoData: Data64
        let fee: UInt64
        let totalOutlay: UInt64
        let numberOfRecipients: PositiveUInt8

        init() throws {
            self.accountKey = try AccountKey.Fixtures.AliceAndBob().alice
            self.expectedMemoData = try Self.getExpectedMemoData()
            self.fee = Self.expectedFee
            self.totalOutlay = Self.expectedTotalOutlay
            self.numberOfRecipients = Self.expectedNumberOfRecipients
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
    
    struct SenderMemoInvalidates {
        let senderAccountKey: AccountKey
        let recieverAccountKey: AccountKey
        let txOutPublicKey: RistrettoPublic
        let memoData: Data64
        
        let wrongSenderAccountKey: AccountKey
        let wrongReceiverAccountKey: AccountKey
        let badTxOutPublicKey: RistrettoPublic

        init() throws {
            self.senderAccountKey = try AccountKey.Fixtures.AliceAndBob().alice
            self.recieverAccountKey = try AccountKey.Fixtures.AliceAndBob().bob
            self.txOutPublicKey = try MemoData.Fixtures.Shared().txOutPublicKey
            self.memoData = try Self.getMemoData()
            self.badTxOutPublicKey = try MemoData.Fixtures.Shared().badTxOutPublicKey
            self.wrongSenderAccountKey = self.recieverAccountKey
            self.wrongReceiverAccountKey = self.senderAccountKey
        }
    }

    struct InvalidSenderMemo {
        let senderAccountKey: AccountKey
        let recieverAccountKey: AccountKey
        let txOutPublicKey: RistrettoPublic
        let invalidMemoData: Data64

        init() throws {
            self.senderAccountKey = try AccountKey.Fixtures.AliceAndBob().alice
            self.recieverAccountKey = try AccountKey.Fixtures.AliceAndBob().bob
            self.txOutPublicKey = try MemoData.Fixtures.Shared().txOutPublicKey
            self.invalidMemoData = try Self.getInvalidMemoData()
        }
    }
    
    struct SenderWithPaymentRequestMemo {
        let senderAccountKey: AccountKey
        let recieverAccountKey: AccountKey
        let txOutPublicKey: RistrettoPublic
        let expectedMemoData: Data64
        let paymentRequestId: UInt64

        init() throws {
            self.senderAccountKey = try AccountKey.Fixtures.AliceAndBob().alice
            self.recieverAccountKey = try AccountKey.Fixtures.AliceAndBob().bob
            self.txOutPublicKey = try MemoData.Fixtures.Shared().txOutPublicKey
            self.expectedMemoData = try Self.getExpectedMemoData()
            self.paymentRequestId = Self.expectedPaymentRequestId
        }
    }
    
    struct InvalidSenderWithPaymentRequestMemo {
        let senderAccountKey: AccountKey
        let recieverAccountKey: AccountKey
        let txOutPublicKey: RistrettoPublic
        let invalidMemoData: Data64
        let paymentRequestId: UInt64

        init() throws {
            self.senderAccountKey = try AccountKey.Fixtures.AliceAndBob().alice
            self.recieverAccountKey = try AccountKey.Fixtures.AliceAndBob().bob
            self.txOutPublicKey = try MemoData.Fixtures.Shared().txOutPublicKey
            self.invalidMemoData = try Self.getInvalidMemoData()
            self.paymentRequestId = Self.expectedPaymentRequestId
        }
    }
    
    struct SenderWithPaymentRequestMemoInvalidates {
        let senderAccountKey: AccountKey
        let recieverAccountKey: AccountKey
        let txOutPublicKey: RistrettoPublic
        let memoData: Data64

        let wrongSenderAccountKey: AccountKey
        let wrongReceiverAccountKey: AccountKey
        let badTxOutPublicKey: RistrettoPublic

        init() throws {
            self.senderAccountKey = try AccountKey.Fixtures.AliceAndBob().alice
            self.recieverAccountKey = try AccountKey.Fixtures.AliceAndBob().bob
            self.txOutPublicKey = try MemoData.Fixtures.Shared().txOutPublicKey
            self.memoData = try Self.getMemoData()
            self.badTxOutPublicKey = try MemoData.Fixtures.Shared().badTxOutPublicKey
            self.wrongSenderAccountKey = self.recieverAccountKey
            self.wrongReceiverAccountKey = self.senderAccountKey
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
    
    static let badTxOutPublicKeyHex =
        """
        0e61ca061876b651e6981ad9a74fd5fe8d4af2f6981283bafe4c1ba40c3d0803
        """
    
    static func getBadTxOutPublicKey() throws -> RistrettoPublic {
        try XCTUnwrap(
                RistrettoPublic(try XCTUnwrap(
                                    Data(hexEncoded: badTxOutPublicKeyHex))))
    }
    
}
    
extension MemoData.Fixtures.DefaultDestinationMemo {
    
    static let expectedFee: UInt64 = 3
    static let expectedTotalOutlay: UInt64 = 100
    static let expectedNumberOfRecipients = PositiveUInt8(1)!
    
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

extension MemoData.Fixtures.DestinationZeroOutlayMemo {
    
    static let expectedFee: UInt64 = 0
    static let expectedTotalOutlay: UInt64 = 0
    static let expectedNumberOfRecipients = PositiveUInt8(1)!
    
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
    
extension MemoData.Fixtures.SenderMemoInvalidates {
    static func getMemoData() throws -> Data64 {
        let shared = try MemoData.Fixtures.Shared()
        let keys = try AccountKey.Fixtures.AliceAndBob()
        return try XCTUnwrap(
            SenderMemoUtils.create(
                senderAccountKey: keys.alice,
                receipientPublicAddress: keys.bob.publicAddress,
                txOutPublicKey: shared.txOutPublicKey))
    }
}
    
extension MemoData.Fixtures.InvalidSenderMemo {
    static func getInvalidMemoData() throws -> Data64 {
        try XCTUnwrap(Data64(
                        XCTUnwrap(Data(hexEncoded: invalidMemoDataHexBytes))))
    }

    static var invalidMemoDataHexBytes: String =
        """
        c3e69cb8953ce920ffbee21e0142eaf440aab016859ea320e4131d6a60e98c59\
        1eff7121e85fe09fc6fc70c818e2f7b6bacf94237a3a0d9549f5bb5708f14a15
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

extension MemoData.Fixtures.InvalidSenderWithPaymentRequestMemo {
    
    static let expectedPaymentRequestId: UInt64 = 17014
    
    static func getInvalidMemoData() throws -> Data64 {
        try XCTUnwrap(Data64(
                        XCTUnwrap(Data(hexEncoded: invalidMemoDataHexBytes))))
    }

    static var invalidMemoDataHexBytes: String =
        """
        1478a1c0825ebd274f7a59cb58ab78351a88a3c01fbda4b58f6a3b7226b19bcb\
        7e0ddcc68bc1413e489ba6d15dd1699f538e1e462a6dcebcd0752728074cd05b
        """
}

extension MemoData.Fixtures.SenderWithPaymentRequestMemoInvalidates {
    
    static let expectedPaymentRequestId: UInt64 = 17014
    
    static func getMemoData() throws -> Data64 {
        let shared = try MemoData.Fixtures.Shared()
        let keys = try AccountKey.Fixtures.AliceAndBob()
        return try XCTUnwrap(
            SenderWithPaymentRequestMemoUtils.create(
                senderAccountKey: keys.alice,
                receipientPublicAddress: keys.bob.publicAddress,
                txOutPublicKey: shared.txOutPublicKey,
                paymentRequestId: Self.expectedPaymentRequestId))
    }
}
