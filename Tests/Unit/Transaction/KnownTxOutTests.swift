//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin
@testable import LibMobileCoin

class KnownTxOutTests: XCTestCase {

    func testFogViewRecordMemoPayloadNotSet() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultNotSet()
//        let accountKey = fixture.senderAccountKey
        let txOut = fixture.knownTxOut
        let txOutMemo = txOut.recoverableMemo
        
        switch txOutMemo {
        case .notset:
            XCTAssertTrue(true)
        default:
            XCTFail("TxOutMemo type mismatch")
        }
    }

    func testFogViewRecordMemoPayloadUnused() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultUnused()
//        let accountKey = fixture.senderAccountKey
        let txOut = fixture.knownTxOut
        let txOutMemo = txOut.recoverableMemo
        
        switch txOutMemo {
        case .unused:
            XCTAssertTrue(true)
        default:
            XCTFail("TxOutMemo type mismatch")
        }
    }
    
    func testFogViewRecordSenderMemoPayload() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultSenderMemo()
//        let accountKey = fixture.senderAccountKey
        let txOut = fixture.knownTxOut
        let txOutMemo = txOut.recoverableMemo
        
        switch txOutMemo {
        case .sender(_):
            XCTAssertTrue(true)
        default:
            XCTFail("TxOutMemo type mismatch")
        }
    }

    func testFogViewRecordSenderMemoPayloadValues() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultSenderMemo()
//        let accountKey = fixture.senderAccountKey
        let txOut = fixture.knownTxOut
        let txOutMemo = txOut.recoverableMemo
        
        switch txOutMemo {
        case .sender(let recoverableSenderMemo):
            // TODO compare address hash ?
            XCTAssertTrue(true)
            let recovered = recoverableSenderMemo.recover(senderPublicAddress: fixture.senderAccountKey.publicAddress)
            XCTAssertNotNil(recovered)
            let senderAddressHash = fixture.senderAccountKey.publicAddress.calculateAddressHash()
            XCTAssertEqual(recovered?.addressHash, senderAddressHash)
        default:
            XCTFail("TxOutMemo type mismatch")
        }
        
    }
    
    func testFogViewRecordDestinationMemoPayload() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultDestinationMemo()
//        let accountKey = fixture.senderAccountKey
        let txOut = fixture.knownTxOut
        let txOutMemo = txOut.recoverableMemo
        
        switch txOutMemo {
        case .destination(_):
            XCTAssertTrue(true)
        default:
            XCTFail("TxOutMemo type mismatch")
        }
    }

    func testFogViewRecordDestinationMemoPayloadValues() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultDestinationMemo()
//        let accountKey = fixture.senderAccountKey
        let txOut = fixture.knownTxOut
        let txOutMemo = txOut.recoverableMemo
        
        switch txOutMemo {
        case .destination(let recoverableDestinationMemo):
            // TODO compare address hash ?
            XCTAssertTrue(true)
            let recovered = recoverableDestinationMemo.recover()
            XCTAssertNotNil(recovered)
            XCTAssertEqual(recovered?.fee, fixture.fee)
            XCTAssertEqual(recovered?.totalOutlay, fixture.totalOutlay)
//            XCTAssertEqual(recovered?.numberOfRecipients, fixture.numberOfRecipients)
        default:
            XCTFail("TxOutMemo type mismatch")
        }
        
    }
    
    func testFogViewRecordSenderWithPaymentRequestMemoPayload() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultSenderWithPaymentRequestMemo()
        let txOut = fixture.knownTxOut
        let txOutMemo = txOut.recoverableMemo
        
        switch txOutMemo {
        case .senderWithPaymentRequest(_):
            XCTAssertTrue(true)
        default:
            XCTFail("TxOutMemo type mismatch")
        }
    }

    func testFogViewRecordSenderWithPaymentRequestMemoPayloadValues() throws {
        let fixture = try KnownTxOut.Fixtures.DefaultSenderWithPaymentRequestMemo()
        let txOut = fixture.knownTxOut
        let txOutMemo = txOut.recoverableMemo
        
        switch txOutMemo {
        case .senderWithPaymentRequest(let recoverableSenderWithPaymentRequestMemo):
            // TODO compare address hash ?
            XCTAssertTrue(true)
            let recovered = recoverableSenderWithPaymentRequestMemo.recover(senderPublicAddress: fixture.senderAccountKey.publicAddress)
            XCTAssertNotNil(recovered)
            let senderAddressHash = fixture.senderAccountKey.publicAddress.calculateAddressHash()
            XCTAssertEqual(recovered?.addressHash, senderAddressHash)
            XCTAssertEqual(recovered?.paymentRequestId, fixture.paymentRequestId)
        default:
            XCTFail("TxOutMemo type mismatch")
        }
        
    }
    
}

extension KnownTxOut {
    enum Fixtures {}
}

extension KnownTxOut.Fixtures {
    struct Init {
        let senderAccountKey: AccountKey
        let receiverAccountKey: AccountKey

        init() throws {
            self.senderAccountKey = try Self.makeAccountKey(hex: Self.senderAccountKeyHex)
            self.receiverAccountKey = try Self.makeAccountKey(hex: Self.receiverAccountKeyHex)
        }
    }
    
    struct DefaultNotSet {
        let ledgerTxOut: LedgerTxOut
        let knownTxOut: KnownTxOut
        let senderAccountKey: AccountKey
        let receiverAccountKey: AccountKey

        init() throws {
            let initFixture = try Init()
            self.senderAccountKey = initFixture.senderAccountKey
            self.receiverAccountKey = initFixture.receiverAccountKey
            self.ledgerTxOut = try Self.getTxOut(viewKey: self.receiverAccountKey.viewPrivateKey)
            guard let knownTxOut = KnownTxOut(self.ledgerTxOut, accountKey: receiverAccountKey) else {
                throw InvalidInputError("Could not create KnownTxOut")
            }
            self.knownTxOut = knownTxOut
        }
    }
    
    struct DefaultUnused {
        let ledgerTxOut: LedgerTxOut
        let knownTxOut: KnownTxOut
        let senderAccountKey: AccountKey
        let receiverAccountKey: AccountKey

        init() throws {
            let initFixture = try Init()
            self.senderAccountKey = initFixture.senderAccountKey
            self.receiverAccountKey = initFixture.receiverAccountKey
            self.ledgerTxOut = try Self.getTxOut(viewKey: self.receiverAccountKey.viewPrivateKey)
            guard let knownTxOut = KnownTxOut(self.ledgerTxOut, accountKey: receiverAccountKey) else {
                throw InvalidInputError("Could not create KnownTxOut")
            }
            self.knownTxOut = knownTxOut
        }
    }
    
    struct DefaultSenderMemo {
        let ledgerTxOut: LedgerTxOut
        let knownTxOut: KnownTxOut
        let senderAccountKey: AccountKey
        let receiverAccountKey: AccountKey

        init() throws {
            let initFixture = try Init()
            self.senderAccountKey = initFixture.senderAccountKey
            self.receiverAccountKey = initFixture.receiverAccountKey
            self.ledgerTxOut = try Self.getTxOut(viewKey: self.receiverAccountKey.viewPrivateKey)
            guard let knownTxOut = KnownTxOut(self.ledgerTxOut, accountKey: receiverAccountKey) else {
                throw InvalidInputError("Could not create KnownTxOut")
            }
            self.knownTxOut = knownTxOut
        }
    }
    
    struct DefaultDestinationMemo {
        let ledgerTxOut: LedgerTxOut
        let knownTxOut: KnownTxOut
        let senderAccountKey: AccountKey
        let receiverAccountKey: AccountKey
        let fee = Self.expectedDestinationFee
        let totalOutlay = Self.expectedDestinationTotalOutlay
        let numberOfRecipients = Self.expectedDestinationNumberOfRecipients

        init() throws {
            let initFixture = try Init()
            self.senderAccountKey = initFixture.senderAccountKey
            self.receiverAccountKey = initFixture.receiverAccountKey
            self.ledgerTxOut = try Self.getTxOut(viewKey: self.senderAccountKey.viewPrivateKey)
            guard let knownTxOut = KnownTxOut(self.ledgerTxOut, accountKey: senderAccountKey) else {
                throw InvalidInputError("Could not create KnownTxOut")
            }
            self.knownTxOut = knownTxOut
        }
    }
    
    struct DefaultSenderWithPaymentRequestMemo {
        let ledgerTxOut: LedgerTxOut
        let knownTxOut: KnownTxOut
        let senderAccountKey: AccountKey
        let receiverAccountKey: AccountKey
        let paymentRequestId = Self.expectedPaymentRequestId

        init() throws {
            let initFixture = try Init()
            self.senderAccountKey = initFixture.senderAccountKey
            self.receiverAccountKey = initFixture.receiverAccountKey
            self.ledgerTxOut = try Self.getTxOut(viewKey: self.receiverAccountKey.viewPrivateKey)
            guard let knownTxOut = KnownTxOut(self.ledgerTxOut, accountKey: receiverAccountKey) else {
                throw InvalidInputError("Could not create KnownTxOut")
            }
            self.knownTxOut = knownTxOut
        }
    }
}

extension KnownTxOut.Fixtures.Init {
    static func makeAccountKey(hex: String) throws -> AccountKey {
        return try KnownTxOut.Fixtures.makeAccountKey(hex: hex)
    }
}

extension KnownTxOut.Fixtures {
    static func makeAccountKey(hex: String) throws -> AccountKey {
        guard let data = Data(hexEncoded: hex) else {
            throw InvalidInputError("Bad hex string")
        }
        let protoKey = try External_AccountKey.init(contiguousBytes: data)
        guard let key = AccountKey(protoKey) else {
            throw InvalidInputError("Could not create AccountKey from Data()")
        }
        
        return key
    }
    
    static func makeTxOut(hex: String, viewKey: RistrettoPrivate) throws -> LedgerTxOut {
        guard let data = Data(hexEncoded: hex) else {
            throw InvalidInputError("Bad hex string")
        }
        let txOutProto = try FogView_TxOutRecord(contiguousBytes: data)
        guard let txOut = LedgerTxOut(txOutProto, viewKey: viewKey) else {
            throw InvalidInputError("Could not create TxOut from Data()")
        }
        return txOut
    }
}

extension KnownTxOut.Fixtures.Init {
    static let senderAccountKeyHex = "0a220a20b1f765d30fbb85b605f04edd29bb9cbb83938f68600d4a618863e9664e7b960912220a20dae7da08e27ea4f17a233f15c234b58ce20d0d2727abb98e9bdcf04aeea540081a11666f673a2f2f6578616d706c652e636f6d";
    static let receiverAccountKeyHex = "0a220a20ff6b8ebfe4cda6a2bca7fa6061e73c752ecc3c01876a25b984f0230bcdab8b0712220a20197d2746aac53be4911b6dd01b3e67d5565fcf322c87c75add37959a608e4a021a11666f673a2f2f6578616d706c652e636f6d";
}

extension KnownTxOut.Fixtures.DefaultNotSet {
    static let viewRecordWithNotSetMemoHex = "11b89889a83748c3b71a20ea28e0a73e2e579163d8710ef1d19bafc1bd04f681168a7eed50054c7c91b45d2220f40936fb0af75ae89f632685e930a9a53abcac8665ae6a7cd59915e07f15d86e296400000000000000310100000000000000390a0000000000000045dad4f606";
    
    static func getTxOut(viewKey: RistrettoPrivate) throws -> LedgerTxOut {
        try KnownTxOut.Fixtures.makeTxOut(hex: viewRecordWithNotSetMemoHex, viewKey: viewKey)
    }
    
}

extension KnownTxOut.Fixtures.DefaultUnused {
    static let viewRecordWithUnusedMemoHex = "11639758694fb8292e1a20d2da037ee1c216c48c9b2742a2ea1ac7d7c29ab754f650ad160424871df5ee662220566c5eeee7236065bce4a8f6c9c70dc8f51f271527fb68114e97bd26874a963a296500000000000000310100000000000000390a0000000000000045b0ced38e4a42c39286d2a3e9c746c2cd19025d3d27c32818f23aa7280c655e794a45b2bff247a627ed203dc007bddd65139f57eeb41e9ea74dd2ffe3276e84e20c7d5f08508812e0";
    
    static func getTxOut(viewKey: RistrettoPrivate) throws -> LedgerTxOut {
        try KnownTxOut.Fixtures.makeTxOut(hex: viewRecordWithUnusedMemoHex, viewKey: viewKey)
    }
    
}

extension KnownTxOut.Fixtures.DefaultSenderMemo {
    static let viewRecordWithSenderMemoHex = "11b89889a83748c3b71a20ea28e0a73e2e579163d8710ef1d19bafc1bd04f681168a7eed50054c7c91b45d2220f40936fb0af75ae89f632685e930a9a53abcac8665ae6a7cd59915e07f15d86e296400000000000000310100000000000000390a0000000000000045dad4f6064a4246597e555ff2700a08d66334a78b43f43c02a270bd580225a05f4f1bb4ca56017ab622dcdb26555c7340344a0a0499f6ee48a77a1fe9525496cd87f70d154ca2a436";
    
    static func getTxOut(viewKey: RistrettoPrivate) throws -> LedgerTxOut {
        try KnownTxOut.Fixtures.makeTxOut(hex: viewRecordWithSenderMemoHex, viewKey: viewKey)
    }
}

extension KnownTxOut.Fixtures.DefaultDestinationMemo {
    static let viewRecordWithDestinationMemoHex = "11d320946556c6eadd1a201e6c1a745fe1632885aedb8c2efbb3a7d0241d3ecd927f00b08c06ab0d65ec5a2220c0c6a236ed89069f2c6ffe3cb8303c551b6102280cccd858e4da1a8c76108009296400000000000000310100000000000000390a000000000000004578fd2d5b4a425b81d7d5b98d57f8684ee9344f567e7d30b22ad0881d3755564c144b861f71bdd7d9b5a5bcba0f52ed891f0c212f29003ddc9c7c824b4640258c901dbef2bb2e56b5";
    
    static let expectedDestinationFee = UInt64(21)
    static let expectedDestinationNumberOfRecipients = UInt(8)
    static let expectedDestinationTotalOutlay = UInt64(472)
    
    static func getTxOut(viewKey: RistrettoPrivate) throws -> LedgerTxOut {
        try KnownTxOut.Fixtures.makeTxOut(hex: viewRecordWithDestinationMemoHex, viewKey: viewKey)
    }
}

extension KnownTxOut.Fixtures.DefaultSenderWithPaymentRequestMemo {
    static let viewRecordWithSenderWithPaymentRequestMemoHex =
      "11b89889a83748c3b71a20ea28e0a73e2e579163d8710ef1d19bafc1bd04f681168a7eed50054c7c91b45d2220f40936fb0af75ae89f632685e930a9a53abcac8665ae6a7cd59915e07f15d86e296400000000000000310100000000000000390a0000000000000045dad4f6064a4246587e555ff2700a08d66334a78b43f43c02a270bd580225a11d4f1bb4ca56017ab622dcdb26555c7340344a0a0499f6ee48ea1335e6a8c4ba4424cfe8ccc523dd1e";
    
    static let expectedPaymentRequestId = UInt64(322);
    
    static func getTxOut(viewKey: RistrettoPrivate) throws -> LedgerTxOut {
        try KnownTxOut.Fixtures.makeTxOut(hex: viewRecordWithSenderWithPaymentRequestMemoHex, viewKey: viewKey)
    }
}
