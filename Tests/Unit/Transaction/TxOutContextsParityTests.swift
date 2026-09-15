//
//  Copyright (c) 2020-2026 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

/// Pins the TxOut public keys one seed derives, as a vector shared verbatim
/// with android-sdk's `TxOutContextsParityTest`.
///
/// Sentz seals a TxOut public key into offramp credentials on whichever
/// platform the user happens to be on, and the transaction that has to carry
/// that key is built later. Each SDK proving itself self-consistent does not
/// cover that: both can be internally stable and still derive different keys
/// from the same seed, and the mismatch would surface as credentials naming
/// an output that never reaches the chain, after funds have moved.
///
/// `TxOutContextsDerivationTests` covers what the derivation ignores — amounts,
/// fees, memos, token id, block version. This covers the one thing those
/// cannot: that the other platform agrees.
///
/// Every input here is shared with the Android test. A deliberate change moves
/// the constants on both sides in the same change; edited on one side alone,
/// the vector proves nothing.
class TxOutContextsParityTests: XCTestCase {

    /// Arbitrary, and fixed only so both platforms draw from the same stream.
    /// 32 bytes: 31 of ASCII and a trailing zero.
    private static let seedBytes = Data("goto https://buy.mobilecoin.com".utf8) + Data([0])

    /// Serialized `AccountKey` and `PublicAddress` protobufs, the wire form
    /// both SDKs deserialize, so the two run the same sender and recipient.
    private static let accountKeyB64 = """
        CiIKIMM0eFjAenKpb/qWCpMpLBobETadGuaJCNy45N0Ej7sPEiIKIEU+8R66uCyb7xsVbX9qAPUa6cTxIpeQNIEQ\
        FoPbWFUKGh1mb2c6Ly9mb2cudGVzdC5tb2JpbGVjb2luLmNvbSqmBDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCC\
        AgoCggIBAL5wfcE20zk+bqIs0WGmG8O1yBJCJ5fBOzBjgEI/sZwvhdayF4gp3P7dfuSCFo20RoVs6O0QMCObEWo5\
        9rE+K0Z/TV2zs2TLyKhOIZoZhM8tWEDQ53wCwFjUPlgW2BlvlaptyJULwBRY1TdWGCHWIWy4wD3ZIHlbFn3Cw36K\
        x5+q0d0AWWGSJUgUEikTGP7csE8Xkwryts1nEtJG2xT7QXFbYe1RRVTwGV4T4vcstQL55XTup+yi4rqVZqI5RDLb\
        +BUJJOtOJ2pfo/3TqZUwE1fGvQCQWz0QWf8kIOexBtmNjEYhzkInycdEuVWzcjJvW5EvEw+xqIufWglujk9YMnqL\
        VsC4OtCUWU38ie5WFgUjs4dDp2gsrUaUlrTWem2qz1Hjp37W5ybRPKxYRezOBeunrdCyP3Lr12HnMFcMpKLxFQSk\
        ReBzivRoEpte5kDLc6w+3OefE22rnDlmm2EdOLoXQHN7NdDJLjjVhtMCEIYCAoWFQBpxS70qadv2kBKt8a0UhE8b\
        IsVCI7GcllkTpLgNCBZ3PHewJnJ1Ab0VuxU/+bYVspOWoHWFBmfuwtaOvYoUdWMZqBoevXyzDyBDoWIee9vt3JIJ\
        dkmleLqPRr5M/DDBkQXDCDJUYq0sIQn6M1dkck+Vp9TYD6cnPMyS+0HToS+0MW/uVo5wla0GByNnAgMBAAE=
        """

    private static let recipientB64 = """
        CiIKILJgHbpuWJZ6abjlsUrrOQb30Y1VYocTSl4mmf2W4IpQEiIKILQV1C5Bb60d0cwYIwuh5qXks7MtNe4wdL/x\
        6KEHehMBGh1mb2c6Ly9mb2cudGVzdC5tb2JpbGVjb2luLmNvbSpA5PqNG7wSNvSF67qGDfhKujwO0x+RWzbwR7WW\
        4qH01VXBOwPw0m+z/Z4bb8ZjoyAUaHjbtcAG7NLjSVVLR2/Niw==
        """

    /// What the inputs above must produce, on either platform.
    private static let expectedPayloadKeyB64 = "xArSo1TSmrdSOO5z/ChxT1A/asuGT7z3/4I0tTylKH4="
    private static let expectedChangeKeyB64 = "vnTuxXXogiaGAWcaU5HUZ1VYzaP+mjnJbMudemo3qAA="

    func testSeedDerivesTheKeysAndroidDerives() throws {
        let fixture = try Transaction.Fixtures.BuildTxTestNet()
        let seed = try XCTUnwrap(RngSeed(Self.seedBytes))

        // Deserialized rather than taken from the fixture, so the sender and
        // recipient this asserts on are the bytes the Android test reads too,
        // not two fixtures that happen to agree today.
        let accountKey = try XCTUnwrap(AccountKey(
            serializedData: try XCTUnwrap(Data(base64Encoded: Self.accountKeyB64))))
        let recipient = try XCTUnwrap(PublicAddress(
            serializedData: try XCTUnwrap(Data(base64Encoded: Self.recipientB64))))

        // The hop `MobileCoinClient.txOutContexts` makes before the builder
        // sees a seed, and `MobileCoinClient.getTxOutContexts` makes on the
        // other side. `TransactionBuilder.txOutContexts` sits below it and
        // takes `context.rngSeed` verbatim, so entering here without the hop
        // would pin keys for a builder seed no caller can reach — and the
        // Android test, which enters at its client, could never match them.
        let builderSeed = try XCTUnwrap(MobileCoinChaCha20Rng(rngSeed: seed).generateRngSeed())

        let derived = try XCTUnwrapSuccess(TransactionBuilder.txOutContexts(
            context: TransactionBuilder.Context(
                accountKey: accountKey,
                blockVersion: .versionOne,
                fogResolver: fixture.fogResolver,
                memoType: .recoverable,
                tombstoneBlockIndex: fixture.tombstoneBlockIndex,
                fee: Amount(0, in: .MOB),
                rngSeed: builderSeed),
            recipient: recipient))

        XCTAssertEqual(
            derived.payload.txOutPublicKey.data.base64EncodedString(),
            Self.expectedPayloadKeyB64)
        XCTAssertEqual(
            derived.change.txOutPublicKey.data.base64EncodedString(),
            Self.expectedChangeKeyB64)
    }
}
