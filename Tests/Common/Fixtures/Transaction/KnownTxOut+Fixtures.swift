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
        try KnownTxOut.Fixtures.getKnownTxOut(fogRecordHex: viewRecordHex, accountKey: accountKey)
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
        try KnownTxOut.Fixtures.getKnownTxOut(fogRecordHex: viewRecordHex, accountKey: accountKey)
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
        try KnownTxOut.Fixtures.getKnownTxOut(fogRecordHex: viewRecordHex, accountKey: accountKey)
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
        try KnownTxOut.Fixtures.getKnownTxOut(fogRecordHex: viewRecordHex, accountKey: accountKey)
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
        try KnownTxOut.Fixtures.getKnownTxOut(fogRecordHex: viewRecordHex, accountKey: accountKey)
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
        try KnownTxOut.Fixtures.getKnownTxOut(fogRecordHex: viewRecordHex, accountKey: accountKey)
    }
}

extension KnownTxOut.Fixtures {
    struct RTHSeedableRng {
        let four_to_one: (output: KnownTxOut, change: KnownTxOut)
        let one_to_four: (output: KnownTxOut, change: KnownTxOut)
        let one_to_two: (output: KnownTxOut, change: KnownTxOut)
        let one_to_three: (output: KnownTxOut, change: KnownTxOut)

        init() throws {
            let accountFixture = try AccountKey.Fixtures.SeedableRng()
            let oneAccountKey = accountFixture.oneSeed
            let twoAccountKey = accountFixture.twoSeed
            let threeAccountKey = accountFixture.threeSeed
            let fourAccountKey = accountFixture.fourSeed
            self.four_to_one = (
                output: try KnownTxOut.Fixtures.getKnownTxOut(
                    txOutHex: Self.four_to_one_output,
                    accountKey: oneAccountKey),
                change: try KnownTxOut.Fixtures.getKnownTxOut(
                    txOutHex: Self.four_to_one_change,
                    accountKey: fourAccountKey)
            )
            self.one_to_four = (
                output: try KnownTxOut.Fixtures.getKnownTxOut(
                    txOutHex: Self.one_to_four_output,
                    accountKey: fourAccountKey),
                change: try KnownTxOut.Fixtures.getKnownTxOut(
                    txOutHex: Self.one_to_four_change,
                    accountKey: oneAccountKey)
            )
            self.one_to_three = (
                output: try KnownTxOut.Fixtures.getKnownTxOut(
                    txOutHex: Self.one_to_three_output,
                    accountKey: threeAccountKey),
                change: try KnownTxOut.Fixtures.getKnownTxOut(
                    txOutHex: Self.one_to_three_change,
                    accountKey: oneAccountKey)
            )
            self.one_to_two = (
                output: try KnownTxOut.Fixtures.getKnownTxOut(
                    txOutHex: Self.one_to_two_output,
                    accountKey: twoAccountKey),
                change: try KnownTxOut.Fixtures.getKnownTxOut(
                    txOutHex: Self.one_to_two_change,
                    accountKey: oneAccountKey)
            )
        }
    }
}

extension KnownTxOut.Fixtures.RTHSeedableRng {
//    Value in pico-mob
//    555000000000
//
//    Change Value in pico-mob
//    66000000000

    static let four_to_one_output =
        """
        0a370a220a20a6d8916608c4c7636ec2185437878bbc50bbfceabcf20319860f38666ae9a92d11a0\
        cde5c81a83d6fe1a08ba85397ad671b9d412220a20904887f349a4e4590d96f9f47d71740590b958\
        f665060dfd3e2531c90d49050a1a220a2072d63ea647f1dffeab04514d50928363be913ca6e08f71\
        9c609a924a7273b41f22560a54025d0ba8f9f6150599cdbfcbef8ff7cf18c7203ea2226163363347\
        cd35e2c62754ad76f0228d0cc8314e658b80d7e40cc7fc7f405f9dba9c1f5ac71293a9d71c190a61\
        65cecb663bafb19f6dccd8fff2139101002a440a42f29b9439b79553f7819682ea6025752ddd7e6d\
        d9ff1a3a5f353994e5bcbce6738a84bc04a178561c11f0dcc4a3d5fc2f9f75f511f2b4f75892faaa\
        d5dbe1938a0692
        """

    static let four_to_one_change =
        """
        0a370a220a20421dcf596dd49efab1f7235616ef5835866a12f15394ca7f22946fcb7f80cb33114e\
        869141cbbfec2d1a089f8f2e556588b66f12220a202250c2129252182753b77330d875c088f0cd5a\
        9685f6cacb7138462fd664223a1a220a20a8d293a485982b7dfc50eedff17777a1f6281a9e5b1635\
        6c27da395a320c125c22560a542ebc5e32038584ed42be68900c36cdb4042db2c6b0aba04c9efdd1\
        bcbdf50b166c9574f24b595d7a88f8bfd86a03f2fb10e4c627eefd210d8264bd76940c5265d33d43\
        c09cc8d832cad1fd08349e2dcad24f01002a440a4224950a1ebae03e7b5c5ef3f47826452b27478e\
        658f18e13ef292c30a591cb01de6037ca153acd79503d5febf3eb9a23fad76e117ed7126bdb02401\
        31ba6c2359fa0b
        """

//    Value in pico-mob
//    444000000000
//
//    Change Value in pico-mob
//    70000000000

    static let one_to_four_output =
        """
        0a370a220a20f69a12a494808ee13619e9fbdd73f4a17eb3b01d65e439eae9d5b532e75ee31f11f2\
        b44aa6781475b51a085f61b93da77fdcef12220a20504da174ed15486586d9eeb557eb2ae32c3359\
        6c52b508f428722b2732c13e621a220a20505e2b61bde17e535d04e28975d7f5075205f9fd182e2e\
        783d8c830c4af3674b22560a542d328871568c469a72e274ad43cafed88ad8105f6ee4263ff9353d\
        481c7c75bb71a774f24b595d7a88f8bfd86a03f2fb10e4c627eefd210d8264bd76940c5265d33d87\
        054ad8c717938f3f90ef74af13fff701002a440a4201dbbe5707d6f687337dc67b348d644388dc24\
        ea5bbc64e47e92b3efd81b9dc1440bd8f735e82ae3446658c69d02ab40f49b4423983b72d6051c89\
        4f4cb8ea60e363
        """

    static let one_to_four_change =
        """
        0a370a220a200c8482a1513d49d0d337b030947b3b96134675cac58a7101b92cf16ebdd0435a114b\
        f0856187e600461a082ca6e5f6633d427a12220a20140354a2be21a6c8ed51201f792b1ba200cd84\
        794af81a0842a5c106186d8f1b1a220a204efc3fa61256001db0d6ce20652eccf74140b6fd28a3de\
        7dc1287b00b0e3462422560a541eaf30b8769203873447abbfa9e1759475241857c792e22acb0cad\
        2c1d6d8c119ccc52ab7d7a7da48f577c72d572fd4f977298f50d9f49a2d88c1638814d88d60725fb\
        671a41d3d7318dae5cc15c6c898cc301002a440a421bdf6bad76d8d55382dc8b08c2d875649463bf\
        45ed688851675f72b488d73af87d8261953c45eafcf53d336183bb089eadea1aa437bc0016e44d37\
        0d5001b0d70ecd
        """

//    Value in pico-mob
//    122000000000
//
//
//    Change Value in pico-mob
//    90000000000

    static let one_to_two_output =
        """
        0a370a220a20cc3fc9f4812d343af8dcf1043b77d18321aad281bafc70211422d0d0513c177e113f\
        48dae24b2c74201a0845ebdf63e5f274d812220a2000b8c8fac95f9742dbc5c02bedd0d430ef72c9\
        636b8434d007ad23f9b380042a1a220a2014be6139f7c4ac4f2d663457afbc1cda0ad381ed2bb9f3\
        7fd2331e6584dff81722560a54316d2aed06989b3061443c58ea4b1a7e8c6f4e4866726aedb8dd17\
        d203f7f49642286a9b368499ca8907fde4ffa0fe91ded108b5f16307704cb14dfc52d15cc39e77a3\
        77820f9c1955e3bfa193cc7b854eb901002a440a42cc750b6207458af52f8f190be6849503b86197\
        cce1180d20c24a189a454c0122b812fd4336cd34b347cae214c8638868a17c65f103175812587ad2\
        1e35fcc58e2c06
        """

    static let one_to_two_change =
        """
        0a370a220a20002d4f9aa43742649ddd0e748c33a5485214a1cfa6d671a0c3adc38c9d556b1f1103\
        36696b9cccea981a081af16d2a2c54787612220a2018d37defa52c3111dcfc8260623563948673c9\
        2100b8dc54e88ca2b21df837691a220a209ca97e61f2357e1babb7e296e63f6e1c514a603bd86493\
        f545fe469c0a8f082922560a54f6d9642bfc72ba9ad7b7f6b9a2d035e2781915b07f31947317b00d\
        a1f82219efc55008df22fbb5f87e180679c7f5aa9d4bd194e87784cdca21158af45cd9c6e6490fc8\
        81f48e12e1e6be7bcfb71e32e16d9f01002a440a42632eaf6048366aadbb53c1ae6dcd54ea8e5059\
        9f818c6b2a8f5ca7d6ffecceb3516e823c11e0a9270e5cef6183d1965101fd0cec8dc11c9feb5a43\
        1b609980a5783d
        """

//    Value in pico-mob
//    133000000000
//
//    Change Value in pico-mob
//    100000000000
//

    static let one_to_three_output =
        """
        0a370a220a20aae8250232aa5e23c01b81d0dd237f79b64a9acbe3dbd155d9248092ddbce97411b5\
        bac0affb41af511a083dcdbebe92ca876e12220a20c84827ff773e05b6373c67c65e2870462fb9fc\
        0f546ae649c330946cbf007f421a220a209aa33183ccd0f6ca9068c64dc277539666288d7674f731\
        c795661546fef5f71c22560a5430e0171a01269470c845f2c81c28c0d6d12e79121bf020a00617a5\
        3fdb3855543ccdae945f4bd2b97b78662a55c0847b6d9d5e5aef14bf22c89e19ac2bf26617a326c6\
        a65fadf97a79cb763e52b8cfa9697e01002a440a424a2609dbc0887b871000779f9c206c95a1dace\
        2835d08057a0694d87f545faaba86b5e9a9b46cb49b5010cfa82e896b42466886f150beeda348965\
        7d5833a8d324c6
        """

    static let one_to_three_change =
        """
        0a370a220a205ced6eaa771e8bf841800a291ef6cbaf656d53999645663213a61e020fc5b106116d\
        d252ff3f1890331a082b125c8618fe95f212220a20a2b8ea85709aaddc9bdaee056e91ec125749a5\
        581bbedc73515baed091bb56791a220a208a0557e90d609c7bffcc288b4d564c5af603a07618e080\
        6c47a841a7bfcb475d22560a54febad0e90275f786c4e753f5b28cd2a51517e727a63ed4ee3be593\
        a8846a346f84efe6448b292d4d485e6df9492686b96879f3c00b1ebd8d16842b57b437f47393242d\
        aca5ac2e4210f4f892102bf4d6041a01002a440a42729912f1b821cec9f4a5b5b4885db81dee80db\
        831cda291b293c62c7c95f2e1d74f83217425a9426a9ac48e73b4d7fd778a4af159f7a2cb9d11242\
        f802e40c268896
        """

}

extension KnownTxOut.Fixtures {
    static func makeKnownTxOut(
        ledgerTxOut: LedgerTxOut,
        accountKey: AccountKey
    ) throws -> KnownTxOut {
        try XCTUnwrap(KnownTxOut(ledgerTxOut, accountKey: accountKey))
    }

    static func makeLedgerTxOut(
        fogRecordHex: String,
        viewKey: RistrettoPrivate
    ) throws -> LedgerTxOut {
        try XCTUnwrap(
            LedgerTxOut(
                try XCTUnwrap(Data(hexEncoded: fogRecordHex)),
                viewKey: viewKey))
    }

    static func makeLedgerTxOut(
        txOutHex: String,
        viewKey: RistrettoPrivate,
        globalIndex: UInt64 = 10000,
        block: BlockMetadata = BlockMetadata(index: 9999, timestamp: nil)
    ) throws -> LedgerTxOut {
        try XCTUnwrap(
            LedgerTxOut(
                try XCTUnwrap(PartialTxOut(
                    try XCTUnwrap(TxOut(serializedData:
                        try XCTUnwrap(Data(hexEncoded: txOutHex)))))),
                globalIndex: globalIndex,
                block: block))

    }

    static func getKnownTxOut(fogRecordHex: String, accountKey: AccountKey) throws -> KnownTxOut {
        try Self.makeKnownTxOut(
                ledgerTxOut: try Self.makeLedgerTxOut(
                    fogRecordHex: fogRecordHex,
                    viewKey: accountKey.viewPrivateKey),
                accountKey: accountKey)
    }

    static func getKnownTxOut(txOutHex: String, accountKey: AccountKey) throws -> KnownTxOut {
        try Self.makeKnownTxOut(
                ledgerTxOut: try Self.makeLedgerTxOut(
                    txOutHex: txOutHex,
                    viewKey: accountKey.viewPrivateKey),
                accountKey: accountKey)
    }

}
