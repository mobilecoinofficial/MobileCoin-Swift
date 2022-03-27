//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import XCTest
@testable import MobileCoin
@testable import LibMobileCoin


extension TxOutMemoParser {
    enum Fixtures { }
}

extension TxOutMemoParser.Fixtures {

    struct DefaultEmptyPayload {
        let txOut: TxOut
        let payload: Data
        let senderAccountKey: AccountKey
        let destinationAccountKey: AccountKey

        init() throws {
            let accountFixture = try AccountKey.Fixtures.TxOutMemoParser()
            self.senderAccountKey = accountFixture.senderAccountKey
            self.destinationAccountKey = accountFixture.destinationAccountKey
            self.txOut = try Self.getTxOut()
            self.payload = try Self.getPayload()
        }
    }

    struct DefaultUnusedPayload {
        let txOut: TxOut
        let payload: Data
        let senderAccountKey: AccountKey
        let destinationAccountKey: AccountKey

        init() throws {
            let accountFixture = try AccountKey.Fixtures.TxOutMemoParser()
            self.senderAccountKey = accountFixture.senderAccountKey
            self.destinationAccountKey = accountFixture.destinationAccountKey
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
            let accountFixture = try AccountKey.Fixtures.TxOutMemoParser()
            self.senderAccountKey = accountFixture.senderAccountKey
            self.destinationAccountKey = accountFixture.destinationAccountKey
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
            let accountFixture = try AccountKey.Fixtures.TxOutMemoParser()
            self.senderAccountKey = accountFixture.senderAccountKey
            self.destinationAccountKey = accountFixture.destinationAccountKey
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
            let accountFixture = try AccountKey.Fixtures.TxOutMemoParser()
            self.senderAccountKey = accountFixture.senderAccountKey
            self.destinationAccountKey = accountFixture.destinationAccountKey
            self.txOut = try Self.getTxOut()
            self.payload = try Self.getPayload()
        }
    }
    
}

extension TxOutMemoParser.Fixtures.DefaultEmptyPayload {
    static let txOutHex =
        """
        0a2d0a220a2080d150b3957ff20758b9413a47044408731151fbf0140e7433e0d119bf658f4a11b8\
        9889a83748c3b712220a20ea28e0a73e2e579163d8710ef1d19bafc1bd04f681168a7eed50054c7c\
        91b45d1a220a20f40936fb0af75ae89f632685e930a9a53abcac8665ae6a7cd59915e07f15d86e22\
        560a5400000000000000000000000000000000000000000000000000000000000000000000000000\
        00000000000000000000000000000000000000000000000000000000000000000000000000000000\
        000000000000002a440a4246597e555ff2700a08d66334a78b43f43c02a270bd580225a05f4f1bb4\
        ca56017ab622dcdb26555c7340344a0a0499f6ee48a77a1fe9525496cd87f70d154ca2a436
        """
    
    static func getTxOut() throws -> TxOut {
        try TxOutMemoParser.Fixtures.makeTxOut(hex: txOutHex)
    }
    
    static func getPayload() throws -> Data {
        Data()
    }
}

extension TxOutMemoParser.Fixtures.DefaultUnusedPayload {
    static let txOutHex =
        """
        0a2d0a220a2080d150b3957ff20758b9413a47044408731151fbf0140e7433e0d119bf658f4a11b8\
        9889a83748c3b712220a20ea28e0a73e2e579163d8710ef1d19bafc1bd04f681168a7eed50054c7c\
        91b45d1a220a20f40936fb0af75ae89f632685e930a9a53abcac8665ae6a7cd59915e07f15d86e22\
        560a5400000000000000000000000000000000000000000000000000000000000000000000000000\
        00000000000000000000000000000000000000000000000000000000000000000000000000000000\
        000000000000002a440a4246597e555ff2700a08d66334a78b43f43c02a270bd580225a05f4f1bb4\
        ca56017ab622dcdb26555c7340344a0a0499f6ee48a77a1fe9525496cd87f70d154ca2a436
        """

    
    static func getTxOut() throws -> TxOut {
        try TxOutMemoParser.Fixtures.makeTxOut(hex: txOutHex)
    }
    
    static let decryptedUnusedMemoPayload =
        """
        00000000000000000000000000000000000000000000000000000000000000000000000000000000\
        0000000000000000000000000000000000000000000000000000
        """
    
    static func getPayload() throws -> Data {
        try TxOutMemoParser.Fixtures.makePayloadData(hex: decryptedUnusedMemoPayload)
    }
}

extension TxOutMemoParser.Fixtures.DefaultSenderMemo {
    static let senderMemoTxOutHex =
        """
        0a2d0a220a2080d150b3957ff20758b9413a47044408731151fbf0140e7433e0d119bf658f4a11b8\
        9889a83748c3b712220a20ea28e0a73e2e579163d8710ef1d19bafc1bd04f681168a7eed50054c7c\
        91b45d1a220a20f40936fb0af75ae89f632685e930a9a53abcac8665ae6a7cd59915e07f15d86e22\
        560a5400000000000000000000000000000000000000000000000000000000000000000000000000\
        00000000000000000000000000000000000000000000000000000000000000000000000000000000\
        000000000000002a440a4246597e555ff2700a08d66334a78b43f43c02a270bd580225a05f4f1bb4\
        ca56017ab622dcdb26555c7340344a0a0499f6ee48a77a1fe9525496cd87f70d154ca2a436
        """

    static func getTxOut() throws -> TxOut {
        try TxOutMemoParser.Fixtures.makeTxOut(hex: senderMemoTxOutHex)
    }
    
    static let decryptedSenderMemoPayload =
        """
        0100477458144e8cf4f6d54b6cc4ddf68bb200000000000000000000000000000000000000000000\
        00000000000000000000228aef692188b3cefc94b5198bdbbca2
        """
    
    static func getPayload() throws -> Data {
        try TxOutMemoParser.Fixtures.makePayloadData(hex: decryptedSenderMemoPayload)
    }
}

extension TxOutMemoParser.Fixtures.DefaultDestinationMemo {
    static let destinationMemoTxOutHex =
        """
        0a2d0a220a209cd38dde0a41b026306ad55ea70f3ba0c0edcf93ead541e577a7d4729342fd2a11d3\
        20946556c6eadd12220a201e6c1a745fe1632885aedb8c2efbb3a7d0241d3ecd927f00b08c06ab0d\
        65ec5a1a220a20c0c6a236ed89069f2c6ffe3cb8303c551b6102280cccd858e4da1a8c7610800922\
        560a5400000000000000000000000000000000000000000000000000000000000000000000000000\
        00000000000000000000000000000000000000000000000000000000000000000000000000000000\
        000000000000002a440a425b81d7d5b98d57f8684ee9344f567e7d30b22ad0881d3755564c144b86\
        1f71bdd7d9b5a5bcba0f52ed891f0c212f29003ddc9c7c824b4640258c901dbef2bb2e56b5
        """

    static func getTxOut() throws -> TxOut {
        try TxOutMemoParser.Fixtures.makeTxOut(hex: destinationMemoTxOutHex)
    }
    
    static let decryptedDestinationMemoPayload =
        """
        020040b3a58c408ddb104b2ef471e451588a010000000000001500000000000001d80000000000000\
        000000000000000000000000000000000000000000000000000
        """

    static func getPayload() throws -> Data {
        try TxOutMemoParser.Fixtures.makePayloadData(hex: decryptedDestinationMemoPayload)
    }
}


extension TxOutMemoParser.Fixtures.DefaultSenderWithPaymentRequestMemo {
    static let senderWithPaymentRequestMemoTxOutHex =
        """
        0a2d0a220a2080d150b3957ff20758b9413a47044408731151fbf0140e7433e0d119bf658f4a11b8\
        9889a83748c3b712220a20ea28e0a73e2e579163d8710ef1d19bafc1bd04f681168a7eed50054c7c\
        91b45d1a220a20f40936fb0af75ae89f632685e930a9a53abcac8665ae6a7cd59915e07f15d86e22\
        560a5400000000000000000000000000000000000000000000000000000000000000000000000000\
        00000000000000000000000000000000000000000000000000000000000000000000000000000000\
        000000000000002a440a4246587e555ff2700a08d66334a78b43f43c02a270bd580225a11d4f1bb4\
        ca56017ab622dcdb26555c7340344a0a0499f6ee48ea1335e6a8c4ba4424cfe8ccc523dd1e
        """

    static func getTxOut() throws -> TxOut {
        try TxOutMemoParser.Fixtures.makeTxOut(hex: senderWithPaymentRequestMemoTxOutHex)
    }
    
    static let decryptedSenderWithPaymentRequestMemoPayload =
        """
        0101477458144e8cf4f6d54b6cc4ddf68bb200000000000001420000000000000000000000000000\
        000000000000000000006fe3c566db189f475fac50c0025ac58a
        """
    
    static func getPayload() throws -> Data {
        try TxOutMemoParser.Fixtures.makePayloadData(hex:
                                            decryptedSenderWithPaymentRequestMemoPayload)
    }
}

extension TxOutMemoParser.Fixtures {
    static func makeTxOut(hex: String) throws -> TxOut {
        let data = try XCTUnwrap(Data(hexEncoded: hex))
        let serializedData = try External_TxOut(contiguousBytes: data).serializedData()
        return try XCTUnwrap(TxOut(serializedData: serializedData))
    }
    
    static func makePayloadData(hex: String) throws -> Data {
        try XCTUnwrap(Data(hexEncoded: hex))
    }
}

