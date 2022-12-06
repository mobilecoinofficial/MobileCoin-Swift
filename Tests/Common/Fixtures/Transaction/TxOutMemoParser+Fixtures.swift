//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

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

    struct DefaultDestinationWithPaymentRequestMemo {
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

    struct DefaultDestinationWithPaymentIntentMemo {
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

    struct DefaultSenderWithPaymentIntentMemo {
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

extension TxOutMemoParser.Fixtures.DefaultDestinationWithPaymentRequestMemo {
    static let destinationWithPaymentRequestMemoTxOutHex =
        """
        0a2d0a220a209e6743ccbcc1e6bcdd0e9c366fea58a3543c0dead6e2c68b420bd936d46b255511b05\
        347e5062e2a2f12220a209cfcdfeeb8cdd8face6b641073939b82b3083549d7cd7caa0210e87f6e8d\
        8b001a220a20563f5b7f2853f0324c41ec2667cd030b10bca911a0f8f10d9c096be7919ad00322560\
        a54749aa2b8536a4b794e9d85106441ef52e973ef427e8ff6ddd64127c53f7f9805a4a5ae899d2d19\
        85ef5bdea0ade8a908e78ae2d9dadf70eaffa8723855d9b6a9e07e00f77fe6ee85b8b9ea11fbc0850\
        d844201002a440a428c101336f6fd1a356278c7981139d05efb55a498635fc77eb85e0697d2a9a1c2\
        c5ec13a57bd197f015fd0519c0644f69576950bd1103e62eadb6e018fa40f4432dd7
        """

    static func getTxOut() throws -> TxOut {
        try TxOutMemoParser.Fixtures.makeTxOut(hex: destinationWithPaymentRequestMemoTxOutHex)
    }

    static let decryptedDestinationWithPaymentRequestMemoPayload =
        """
        0203ab7b2b63966ea9a865df8d620f0b5fb0010000000000000100000000000000020000000000000\
        12d000000000000000000000000000000000000000000000000
        """

    static func getPayload() throws -> Data {
        try TxOutMemoParser.Fixtures.makePayloadData(hex:
                                            decryptedDestinationWithPaymentRequestMemoPayload)
    }
}

extension TxOutMemoParser.Fixtures.DefaultSenderWithPaymentIntentMemo {
    static let senderWithPaymentIntentMemoTxOutHex =
        """
        0a2d0a220a20042c91ddc63947d35175dc14d7350f8fc382952826ddf1966b4991f5e033742011fd\
        2381bc62c65b5912220a20784319526ee2f161d5bb709fd101514c5666562bea284c93fec373eccf\
        66b0301a220a206603a91186d7a5360199b749406c3a80bad7a9df51bb9aeb31f23378ec8c1d3f22\
        560a54ec0baf6c7aa9805ec10612784a2046414e3f65399c060dd838c0897c238f0d4d03486c7db7\
        5590f8af6d15cff9e161d6fd6ef031e7234b6dc12a6f4cfb64a004866e64b96d1e166a4c2b5f97bb\
        acdb42571701002a440a4237cc9d921f966ff63a28f9b8d85c2bd3b94177ebb4b7a71bf2f98370b0\
        10aa043cebaed8e26aa1fbcf299103c50bd15ca75df1e25bc84de804a6786187537b4afd40
        """

    static func getTxOut() throws -> TxOut {
        try TxOutMemoParser.Fixtures.makeTxOut(hex: senderWithPaymentIntentMemoTxOutHex)
    }

    static let decryptedSenderWithPaymentIntentMemoPayload =
        """
        0102ccb5a98f0c0c42f68491e5e0c9362452000000000000019100000000000000000000000000000000\
        0000000000000000bf6cc64dc5a8bfb8f6871196f7a084ea
        """

    static func getPayload() throws -> Data {
        try TxOutMemoParser.Fixtures.makePayloadData(hex:
                                            decryptedSenderWithPaymentIntentMemoPayload)
    }
}

extension TxOutMemoParser.Fixtures.DefaultDestinationWithPaymentIntentMemo {
    static let destinationWithPaymentIntentMemoTxOutHex =
        """
        0a2d0a220a209e6743ccbcc1e6bcdd0e9c366fea58a3543c0dead6e2c68b420bd936d46b255511b0\
        5347e5062e2a2f12220a209cfcdfeeb8cdd8face6b641073939b82b3083549d7cd7caa0210e87f6e\
        8d8b001a220a20563f5b7f2853f0324c41ec2667cd030b10bca911a0f8f10d9c096be7919ad00322\
        560a54749aa2b8536a4b794e9d85106441ef52e973ef427e8ff6ddd64127c53f7f9805a4a5ae899d\
        2d1985ef5bdea0ade8a908e78ae2d9dadf70eaffa8723855d9b6a9e07e00f77fe6ee85b8b9ea11fb\
        c0850d844201002a440a428c171336f6fd1a356278c7981139d05efb55a498635fc77eb85e0697d2\
        a9a1c2c5ec13a57bd197f015410519c0644f69576950bd1103e62eadb6e018fa40f4432dd7
        """

    static func getTxOut() throws -> TxOut {
        try TxOutMemoParser.Fixtures.makeTxOut(hex: destinationWithPaymentIntentMemoTxOutHex)
    }

    static let decryptedDestinationWithPaymentIntentMemoPayload =
        """
        0204ab7b2b63966ea9a865df8d620f0b5fb0010000000000000100000000000000020000000000000\
        191000000000000000000000000000000000000000000000000
        """

    static func getPayload() throws -> Data {
        try TxOutMemoParser.Fixtures.makePayloadData(hex:
                                            decryptedDestinationWithPaymentIntentMemoPayload)
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
