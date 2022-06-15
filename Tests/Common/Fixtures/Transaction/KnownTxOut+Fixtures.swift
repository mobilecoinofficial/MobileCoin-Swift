//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
@testable import MobileCoin
import XCTest

extension KnownTxOut {
    enum Fixtures {}
}

extension KnownTxOut.Fixtures {
    struct DefaultNotSet {
        let knownTxOut: KnownTxOut
        let senderAccountKey: AccountKey
        let receiverAccountKey: AccountKey

        init() throws {
            let accountFixture = try AccountKey.Fixtures.KnownTxOut()
            self.senderAccountKey = accountFixture.senderAccountKey
            self.receiverAccountKey = accountFixture.receiverAccountKey
            self.knownTxOut = try Self.getKnownTxOut(accountKey: receiverAccountKey)
        }
    }
}

extension KnownTxOut.Fixtures.DefaultNotSet {
    static let viewRecordHex =
        """
        11b89889a83748c3b71a20ea28e0a73e2e579163d8710ef1d19bafc1bd04f681168a7eed50054c7c\
        91b45d2220f40936fb0af75ae89f632685e930a9a53abcac8665ae6a7cd59915e07f15d86e296400\
        000000000000310100000000000000390a0000000000000045dad4f606
        """

    static func getKnownTxOut(accountKey: AccountKey) throws -> KnownTxOut {
        try KnownTxOut.Fixtures.getKnownTxOut(hex: viewRecordHex, accountKey: accountKey)
    }
}

extension KnownTxOut.Fixtures {
    struct DefaultUnused {
        let knownTxOut: KnownTxOut
        let senderAccountKey: AccountKey
        let receiverAccountKey: AccountKey

        init() throws {
            let accountFixture = try AccountKey.Fixtures.KnownTxOut()
            self.senderAccountKey = accountFixture.senderAccountKey
            self.receiverAccountKey = accountFixture.receiverAccountKey
            self.knownTxOut = try Self.getKnownTxOut(accountKey: receiverAccountKey)
        }
    }
}

extension KnownTxOut.Fixtures.DefaultUnused {
    static let viewRecordHex =
        """
        11639758694fb8292e1a20d2da037ee1c216c48c9b2742a2ea1ac7d7c29ab754f650ad160424871d\
        f5ee662220566c5eeee7236065bce4a8f6c9c70dc8f51f271527fb68114e97bd26874a963a296500\
        000000000000310100000000000000390a0000000000000045b0ced38e4a42c39286d2a3e9c746c2\
        cd19025d3d27c32818f23aa7280c655e794a45b2bff247a627ed203dc007bddd65139f57eeb41e9e\
        a74dd2ffe3276e84e20c7d5f08508812e0
        """

    static func getKnownTxOut(accountKey: AccountKey) throws -> KnownTxOut {
        try KnownTxOut.Fixtures.getKnownTxOut(hex: viewRecordHex, accountKey: accountKey)
    }
}

extension KnownTxOut.Fixtures {
    struct DefaultSenderMemo {
        let knownTxOut: KnownTxOut
        let senderAccountKey: AccountKey
        let receiverAccountKey: AccountKey

        init() throws {
            let accountFixture = try AccountKey.Fixtures.KnownTxOut()
            self.senderAccountKey = accountFixture.senderAccountKey
            self.receiverAccountKey = accountFixture.receiverAccountKey
            self.knownTxOut = try Self.getKnownTxOut(accountKey: receiverAccountKey)
        }
    }
}

extension KnownTxOut.Fixtures.DefaultSenderMemo {
    static let viewRecordHex =
        """
        11b89889a83748c3b71a20ea28e0a73e2e579163d8710ef1d19bafc1bd04f681168a7eed50054c7c\
        91b45d2220f40936fb0af75ae89f632685e930a9a53abcac8665ae6a7cd59915e07f15d86e296400\
        000000000000310100000000000000390a0000000000000045dad4f6064a4246597e555ff2700a08\
        d66334a78b43f43c02a270bd580225a05f4f1bb4ca56017ab622dcdb26555c7340344a0a0499f6ee\
        48a77a1fe9525496cd87f70d154ca2a436
        """

    static func getKnownTxOut(accountKey: AccountKey) throws -> KnownTxOut {
        try KnownTxOut.Fixtures.getKnownTxOut(hex: viewRecordHex, accountKey: accountKey)
    }
}

extension KnownTxOut.Fixtures {
    struct DefaultDestinationMemo {
        let knownTxOut: KnownTxOut
        let senderAccountKey: AccountKey
        let receiverAccountKey: AccountKey
        let fee = Self.expectedDestinationFee
        let totalOutlay = Self.expectedDestinationTotalOutlay
        let numberOfRecipients = Self.expectedDestinationNumberOfRecipients

        init() throws {
            let accountFixture = try AccountKey.Fixtures.KnownTxOut()
            self.senderAccountKey = accountFixture.senderAccountKey
            self.receiverAccountKey = accountFixture.receiverAccountKey
            self.knownTxOut = try Self.getKnownTxOut(accountKey: senderAccountKey)
        }
    }
}

extension KnownTxOut.Fixtures.DefaultDestinationMemo {
    static let viewRecordHex =
        """
        11e8672b2c2a3dfdb01a20d633484d79c87c7eb43174137fb8f3ef76a903480be709aff0b4965f0f9\
        6f91222207a70b708482ad30825d12029215b0445c838d17c3300f304abc2c99354344d4c29640000\
        0000000000310100000000000000390a00000000000000450976a45c4a42be19c8919ab21ec0597c8\
        5816703535faeb208b84a01ae5fb6d708be9cf67280b2d6a2a116f93bf1895ba4c33bf1779728527c\
        cd621271f0e67e01d1d85cf95c09d1
        """

    static let expectedDestinationFee = UInt64(21)
    static let expectedDestinationNumberOfRecipients = PositiveUInt8(1)!
    static let expectedDestinationTotalOutlay = UInt64(472)

    static func getKnownTxOut(accountKey: AccountKey) throws -> KnownTxOut {
        try KnownTxOut.Fixtures.getKnownTxOut(hex: viewRecordHex, accountKey: accountKey)
    }
}

extension KnownTxOut.Fixtures {
    struct DefaultSenderWithPaymentRequestMemo {
        let knownTxOut: KnownTxOut
        let senderAccountKey: AccountKey
        let receiverAccountKey: AccountKey
        let paymentRequestId = Self.expectedPaymentRequestId

        init() throws {
            let accountFixture = try AccountKey.Fixtures.KnownTxOut()
            self.senderAccountKey = accountFixture.senderAccountKey
            self.receiverAccountKey = accountFixture.receiverAccountKey
            self.knownTxOut = try Self.getKnownTxOut(accountKey: receiverAccountKey)
        }
    }
}

extension KnownTxOut.Fixtures.DefaultSenderWithPaymentRequestMemo {
    static let viewRecordHex =
        """
        11b89889a83748c3b71a20ea28e0a73e2e579163d8710ef1d19bafc1bd04f681168a7eed50054c7c\
        91b45d2220f40936fb0af75ae89f632685e930a9a53abcac8665ae6a7cd59915e07f15d86e296400\
        000000000000310100000000000000390a0000000000000045dad4f6064a4246587e555ff2700a08\
        d66334a78b43f43c02a270bd580225a11d4f1bb4ca56017ab622dcdb26555c7340344a0a0499f6ee\
        48ea1335e6a8c4ba4424cfe8ccc523dd1e
        """

    static let expectedPaymentRequestId = UInt64(322)

    static func getKnownTxOut(accountKey: AccountKey) throws -> KnownTxOut {
        try KnownTxOut.Fixtures.getKnownTxOut(hex: viewRecordHex, accountKey: accountKey)
    }
}

extension KnownTxOut.Fixtures {
    struct GetSharedSecret {
        let knownTxOut: KnownTxOut
        let senderAccountKey: AccountKey
        let receiverAccountKey: AccountKey

        init() throws {
            let accountFixture = try AccountKey.Fixtures.KnownTxOut()
            self.senderAccountKey = accountFixture.senderAccountKey
            self.receiverAccountKey = accountFixture.receiverAccountKey
            self.knownTxOut = try Self.getKnownTxOut(accountKey: receiverAccountKey)
        }
    }
}

extension KnownTxOut.Fixtures.GetSharedSecret {
    static let viewRecordHex =
        """
        11b89889a83748c3b71a20ea28e0a73e2e579163d8710ef1d19bafc1bd04f681168a7eed50054c7c\
        91b45d2220f40936fb0af75ae89f632685e930a9a53abcac8665ae6a7cd59915e07f15d86e296400\
        000000000000310100000000000000390a0000000000000045dad4f6064a4246587e555ff2700a08\
        d66334a78b43f43c02a270bd580225a11d4f1bb4ca56017ab622dcdb26555c7340344a0a0499f6ee\
        48ea1335e6a8c4ba4424cfe8ccc523dd1e
        """

    static func getKnownTxOut(accountKey: AccountKey) throws -> KnownTxOut {
        try KnownTxOut.Fixtures.getKnownTxOut(hex: viewRecordHex, accountKey: accountKey)
    }
}

extension KnownTxOut.Fixtures {
    static func makeLedgerTxOut(
        txHex: String,
        viewKey: RistrettoPrivate,
        globalIndex: UInt64 = 10000,
        block: BlockMetadata = BlockMetadata(index: 9999, timestamp: nil)
    ) throws -> LedgerTxOut {
        try XCTUnwrap(
            LedgerTxOut(
                try XCTUnwrap(PartialTxOut(
                    try XCTUnwrap(TxOut(serializedData:
                        try XCTUnwrap(Data(hexEncoded: txHex)))))),
                globalIndex: globalIndex,
                block: block))

    }

    static func makeLedgerTxOut(hex: String, viewKey: RistrettoPrivate) throws -> LedgerTxOut {
        try XCTUnwrap(
            LedgerTxOut(
                try XCTUnwrap(Data(hexEncoded: hex)),
                viewKey: viewKey))
    }

    static func makeKnownTxOut(
        ledgerTxOut: LedgerTxOut,
        accountKey: AccountKey
    ) throws -> KnownTxOut {
        try XCTUnwrap(KnownTxOut(ledgerTxOut, accountKey: accountKey))
    }

    static func getKnownTxOut(hex: String, accountKey: AccountKey) throws -> KnownTxOut {
        try Self.makeKnownTxOut(
                ledgerTxOut: try Self.makeLedgerTxOut(hex: hex, viewKey: accountKey.viewPrivateKey),
                accountKey: accountKey)
    }
}
