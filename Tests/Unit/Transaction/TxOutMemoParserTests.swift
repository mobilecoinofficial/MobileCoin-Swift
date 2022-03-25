//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin
@testable import LibMobileCoin

class TxOutMemoParserTest: XCTestCase {

    func testEmptyMemoPayloadParse() throws {
        let emptyPayload = Data()
        let fixture = try TxOutMemoParser.Fixtures.Default()
        let accountKey = fixture.senderAccountKey
        let txOut = fixture.txOut
        let txOutMemo: RecoverableMemo = TxOutMemoParser.parse(decryptedPayload: emptyPayload, accountKey: accountKey, txOut: txOut)
        XCTAssertEqual(txOutMemo, .notset)
    }
    
    func testUnusedMemoPayloadParse() throws {
        let fixture = try TxOutMemoParser.Fixtures.Default()
        let accountKey = fixture.senderAccountKey
        let txOut = fixture.txOut
        let unusedPayload = fixture.payload
        let txOutMemo: RecoverableMemo = TxOutMemoParser.parse(decryptedPayload: unusedPayload, accountKey: accountKey, txOut: txOut)
        XCTAssertEqual(txOutMemo, .unused)
    }

    func testSenderMemoPayloadParse() throws {
        let fixture = try TxOutMemoParser.Fixtures.DefaultSenderMemo()
        let accountKey = fixture.senderAccountKey
        let txOut = fixture.txOut
        let payload = fixture.payload
        let txOutMemo: RecoverableMemo = TxOutMemoParser.parse(decryptedPayload: payload, accountKey: accountKey, txOut: txOut)
        
        switch txOutMemo {
        case .sender(let memo):
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }
    
    func testSenderWithPaymentRequestMemoPayloadParse() throws {
        let fixture = try TxOutMemoParser.Fixtures.DefaultSenderWithPaymentRequestMemo()
        let accountKey = fixture.senderAccountKey
        let txOut = fixture.txOut
        let payload = fixture.payload
        let txOutMemo: RecoverableMemo = TxOutMemoParser.parse(decryptedPayload: payload, accountKey: accountKey, txOut: txOut)
        
        switch txOutMemo {
        case .senderWithPaymentRequest(let memo):
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }
    
    func testDestinationMemoPayloadParse() throws {
        let fixture = try TxOutMemoParser.Fixtures.DefaultDestinationMemo()
        let accountKey = fixture.senderAccountKey
        let txOut = fixture.txOut
        let payload = fixture.payload
        let txOutMemo: RecoverableMemo = TxOutMemoParser.parse(decryptedPayload: payload, accountKey: accountKey, txOut: txOut)
        
        switch txOutMemo {
        case .destination(let memo):
            XCTAssert(true)
        default:
            XCTAssert(false)
        }
    }
}

extension TxOutMemoParser {
    enum Fixtures { }
}

extension TxOutMemoParser.Fixtures {
    struct Init {
        let senderAccountKey: AccountKey
        let destinationAccountKey: AccountKey

        init() throws {
            self.senderAccountKey = try Self.makeAccountKey(hex: Self.senderAccountKeyHex)
            self.destinationAccountKey = try Self.makeAccountKey(hex: Self.destinationAccountKeyHex)
        }
    }
    
    struct Default {
        let txOut: TxOut
        let payload: Data
        let senderAccountKey: AccountKey
        let destinationAccountKey: AccountKey

        init() throws {
            let initFixture = try Init()
            self.senderAccountKey = initFixture.senderAccountKey
            self.destinationAccountKey = initFixture.destinationAccountKey
            self.txOut = try Self.getTxOut()
            self.payload = try Self.getPayload()
        }
    }

    struct DefaultSenderMemo {
        let txOut: TxOut
        let payload: Data
        let senderAccountKey: AccountKey
        let destinationAccountKey: AccountKey

        init() throws {
            let initFixture = try Init()
            self.senderAccountKey = initFixture.senderAccountKey
            self.destinationAccountKey = initFixture.destinationAccountKey
            self.txOut = try Self.getTxOut()
            self.payload = try Self.getPayload()
        }
    }
    
    struct DefaultDestinationMemo {
        let txOut: TxOut
        let payload: Data
        let senderAccountKey: AccountKey
        let destinationAccountKey: AccountKey

        init() throws {
            let initFixture = try Init()
            self.senderAccountKey = initFixture.senderAccountKey
            self.destinationAccountKey = initFixture.destinationAccountKey
            self.txOut = try Self.getTxOut()
            self.payload = try Self.getPayload()
        }
    }
    
    struct DefaultSenderWithPaymentRequestMemo {
        let txOut: TxOut
        let payload: Data
        let senderAccountKey: AccountKey
        let destinationAccountKey: AccountKey

        init() throws {
            let initFixture = try Init()
            self.senderAccountKey = initFixture.senderAccountKey
            self.destinationAccountKey = initFixture.destinationAccountKey
            self.txOut = try Self.getTxOut()
            self.payload = try Self.getPayload()
        }
    }
    
}

extension TxOutMemoParser.Fixtures.Init {
    static let senderAccountKeyHex = "0a220a20553a1c51c1e91d3105b17c909c163f8bc6faf93718deb06e5b9fdb9a24c2560912220a20db8b25545216d606fc3ff6da43d3281e862ba254193aff8c408f3564aefca5061a1e666f673a2f2f666f672e616c7068612e6d6f62696c65636f696e2e636f6d2aa60430820222300d06092a864886f70d01010105000382020f003082020a0282020100c853a8724bc211cf5370ed4dbec8947c5573bed0ec47ae14211454977b41336061f0a040f77dbf529f3a46d8095676ec971b940ab4c9642578760779840a3f9b3b893b2f65006c544e9c16586d33649769b7c1c94552d7efa081a56ad612dec932812676ebec091f2aed69123604f4888a125e04ff85f5a727c286664378581cf34c7ee13eb01cc4faf3308ed3c07a9415f98e5fbfe073e6c357967244e46ba6ebbe391d8154e6e4a1c80524b1a6733eca46e37bfdd62d75816988a79aac6bdb62a06b1237a8ff5e5c848d01bbff684248cf06d92f301623c893eb0fba0f3faee2d197ea57ac428f89d6c000f76d58d5aacc3d70204781aca45bc02b1456b454231d2f2ed4ca6614e5242c7d7af0fe61e9af6ecfa76674ffbc29b858091cbfb4011538f0e894ce45d21d7fac04ba2ff57e9ff6db21e2afd9468ad785c262ec59d4a1a801c5ec2f95fc107dc9cb5f7869d70aa84450b8c350c2fa48bddef20752a1e43676b246c7f59f8f1f4aee43c1a15f36f7a36a9ec708320ea42089991551f2656ec62ea38233946b85616ff182cf17cd227e596329b546ea04d13b053be4cf3338de777b50bc6eca7a6185cf7a5022bc9be3749b1bb43e10ecc88a0c580f2b7373138ee49c7bafd8be6a64048887230480b0c85a045255494e04a9a81646369ce7a10e08da6fae27333ec0c16c8a74d93779a9e055395078d0b07286f9930203010001";
    
    static let destinationAccountKeyHex = "0a220a20ec8cb9814ac5c1a4aacbc613e756744679050927cc9e5f8772c6d649d4a5ac0612220a20e7ef0b2772663314ecd7ee92008613764ab5669666d95bd2621d99d60506cb0d1a1e666f673a2f2f666f672e616c7068612e6d6f62696c65636f696e2e636f6d2aa60430820222300d06092a864886f70d01010105000382020f003082020a0282020100c853a8724bc211cf5370ed4dbec8947c5573bed0ec47ae14211454977b41336061f0a040f77dbf529f3a46d8095676ec971b940ab4c9642578760779840a3f9b3b893b2f65006c544e9c16586d33649769b7c1c94552d7efa081a56ad612dec932812676ebec091f2aed69123604f4888a125e04ff85f5a727c286664378581cf34c7ee13eb01cc4faf3308ed3c07a9415f98e5fbfe073e6c357967244e46ba6ebbe391d8154e6e4a1c80524b1a6733eca46e37bfdd62d75816988a79aac6bdb62a06b1237a8ff5e5c848d01bbff684248cf06d92f301623c893eb0fba0f3faee2d197ea57ac428f89d6c000f76d58d5aacc3d70204781aca45bc02b1456b454231d2f2ed4ca6614e5242c7d7af0fe61e9af6ecfa76674ffbc29b858091cbfb4011538f0e894ce45d21d7fac04ba2ff57e9ff6db21e2afd9468ad785c262ec59d4a1a801c5ec2f95fc107dc9cb5f7869d70aa84450b8c350c2fa48bddef20752a1e43676b246c7f59f8f1f4aee43c1a15f36f7a36a9ec708320ea42089991551f2656ec62ea38233946b85616ff182cf17cd227e596329b546ea04d13b053be4cf3338de777b50bc6eca7a6185cf7a5022bc9be3749b1bb43e10ecc88a0c580f2b7373138ee49c7bafd8be6a64048887230480b0c85a045255494e04a9a81646369ce7a10e08da6fae27333ec0c16c8a74d93779a9e055395078d0b07286f9930203010001";
    
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
}

extension TxOutMemoParser.Fixtures {
    static func makeTxOut(hex: String) throws -> TxOut {
        guard let data = Data(hexEncoded: hex) else {
            throw InvalidInputError("Bad hex string")
        }
        let txOutProto = try External_TxOut(contiguousBytes: data)
        guard let txOut = TxOut(serializedData: try txOutProto.serializedData()) else {
            throw InvalidInputError("Could not create TxOut from Data()")
        }
        return txOut
    }
    
    static func makePayloadData(hex: String) throws -> Data {
        guard let data = Data(hexEncoded: hex) else {
            throw InvalidInputError("Bad hex string")
        }
        return data
    }
}


extension TxOutMemoParser.Fixtures.Default {
    static let txOutHex = "0a2d0a220a2080d150b3957ff20758b9413a47044408731151fbf0140e7433e0d119bf658f4a11b89889a83748c3b712220a20ea28e0a73e2e579163d8710ef1d19bafc1bd04f681168a7eed50054c7c91b45d1a220a20f40936fb0af75ae89f632685e930a9a53abcac8665ae6a7cd59915e07f15d86e22560a540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002a440a4246597e555ff2700a08d66334a78b43f43c02a270bd580225a05f4f1bb4ca56017ab622dcdb26555c7340344a0a0499f6ee48a77a1fe9525496cd87f70d154ca2a436"
    
    static func getTxOut() throws -> TxOut {
        try TxOutMemoParser.Fixtures.makeTxOut(hex: txOutHex)
    }
    
    static let decryptedUnusedMemoPayload = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
    
    static func getPayload() throws -> Data {
        try TxOutMemoParser.Fixtures.makePayloadData(hex: decryptedUnusedMemoPayload)
    }
}

extension TxOutMemoParser.Fixtures.DefaultSenderMemo {
    static let senderMemoTxOutHex = "0a2d0a220a2080d150b3957ff20758b9413a47044408731151fbf0140e7433e0d119bf658f4a11b89889a83748c3b712220a20ea28e0a73e2e579163d8710ef1d19bafc1bd04f681168a7eed50054c7c91b45d1a220a20f40936fb0af75ae89f632685e930a9a53abcac8665ae6a7cd59915e07f15d86e22560a540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002a440a4246597e555ff2700a08d66334a78b43f43c02a270bd580225a05f4f1bb4ca56017ab622dcdb26555c7340344a0a0499f6ee48a77a1fe9525496cd87f70d154ca2a436"
    
    static func getTxOut() throws -> TxOut {
        try TxOutMemoParser.Fixtures.makeTxOut(hex: senderMemoTxOutHex)
    }
    
    static let decryptedSenderMemoPayload = "0100477458144e8cf4f6d54b6cc4ddf68bb20000000000000000000000000000000000000000000000000000000000000000228aef692188b3cefc94b5198bdbbca2";
    
    static func getPayload() throws -> Data {
        try TxOutMemoParser.Fixtures.makePayloadData(hex: decryptedSenderMemoPayload)
    }
}

extension TxOutMemoParser.Fixtures.DefaultDestinationMemo {
    static let destinationMemoTxOutHex = "0a2d0a220a209cd38dde0a41b026306ad55ea70f3ba0c0edcf93ead541e577a7d4729342fd2a11d320946556c6eadd12220a201e6c1a745fe1632885aedb8c2efbb3a7d0241d3ecd927f00b08c06ab0d65ec5a1a220a20c0c6a236ed89069f2c6ffe3cb8303c551b6102280cccd858e4da1a8c7610800922560a540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002a440a425b81d7d5b98d57f8684ee9344f567e7d30b22ad0881d3755564c144b861f71bdd7d9b5a5bcba0f52ed891f0c212f29003ddc9c7c824b4640258c901dbef2bb2e56b5"
    
    static func getTxOut() throws -> TxOut {
        try TxOutMemoParser.Fixtures.makeTxOut(hex: destinationMemoTxOutHex)
    }
    
    static let decryptedDestinationMemoPayload = "020040b3a58c408ddb104b2ef471e451588a010000000000001500000000000001d80000000000000000000000000000000000000000000000000000000000000000";

    static func getPayload() throws -> Data {
        try TxOutMemoParser.Fixtures.makePayloadData(hex: decryptedDestinationMemoPayload)
    }
}


extension TxOutMemoParser.Fixtures.DefaultSenderWithPaymentRequestMemo {
    static let senderWithPaymentRequestMemoTxOutHex = "0a2d0a220a2080d150b3957ff20758b9413a47044408731151fbf0140e7433e0d119bf658f4a11b89889a83748c3b712220a20ea28e0a73e2e579163d8710ef1d19bafc1bd04f681168a7eed50054c7c91b45d1a220a20f40936fb0af75ae89f632685e930a9a53abcac8665ae6a7cd59915e07f15d86e22560a540000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002a440a4246587e555ff2700a08d66334a78b43f43c02a270bd580225a11d4f1bb4ca56017ab622dcdb26555c7340344a0a0499f6ee48ea1335e6a8c4ba4424cfe8ccc523dd1e"
    
    static func getTxOut() throws -> TxOut {
        try TxOutMemoParser.Fixtures.makeTxOut(hex: senderWithPaymentRequestMemoTxOutHex)
    }
    
    static let decryptedSenderWithPaymentRequestMemoPayload = "0101477458144e8cf4f6d54b6cc4ddf68bb200000000000001420000000000000000000000000000000000000000000000006fe3c566db189f475fac50c0025ac58a";
    
    static func getPayload() throws -> Data {
        try TxOutMemoParser.Fixtures.makePayloadData(hex: decryptedSenderWithPaymentRequestMemoPayload)
    }
}
