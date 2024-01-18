//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable file_length multiline_function_chains force_unwrapping function_body_length

import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif
@testable import MobileCoin
import XCTest

extension Transaction {
    enum Fixtures {}
}

extension Transaction.Fixtures {
    struct BuildTx {
        let inputs: [PreparedTxInput]
        let accountKey: AccountKey
        let outputs: [TransactionOutput]
        let fee = Self.fee
        let tombstoneBlockIndex = Self.tombstoneBlockIndex
        let fogResolver: FogResolver
        let blockVersion = Self.defaultBlockVersion

        init() throws {
            self.inputs = try Self.inputs()
            self.accountKey = try Self.accountKey()
            self.outputs = try Self.outputs()
            self.fogResolver = try Self.fogResolver()
        }
    }

    struct ExactChange {
        let inputs: [PreparedTxInput]
        let accountKey: AccountKey
        let outputs: [TransactionOutput]
        let fee: Amount
        let tombstoneBlockIndex: UInt64
        let fogResolver: FogResolver
        let blockVersion = BlockVersion.minRTHEnabled

        init() throws {
            let buildTxFixture = try Transaction.Fixtures.BuildTxTestNet()
            self.fee = buildTxFixture.fee
            self.tombstoneBlockIndex = buildTxFixture.tombstoneBlockIndex
            self.inputs = buildTxFixture.inputs
            self.accountKey = buildTxFixture.accountKey
            self.outputs = try Self.outputs()
            self.fogResolver = buildTxFixture.fogResolver
            /*self.blockVersion = buildTxFixture.blockVersion*/
        }
    }

    struct BuildTxTestNet {
        let inputs: [PreparedTxInput]
        let accountKey: AccountKey
        let outputs: [TransactionOutput]
        let fee = Self.fee
        let tombstoneBlockIndex = Self.tombstoneBlockIndex
        let fogResolver: FogResolver
        let blockVersion = Self.defaultBlockVersion

        init() throws {
            self.inputs = try Self.inputs()
            self.accountKey = try Self.accountKey()
            self.outputs = try Self.outputs()
            self.fogResolver = try Self.fogResolver()
        }
    }

}

extension Transaction.Fixtures {
    struct Default {
        let transaction: Transaction

        let tx: External_Tx
        let inputKeyImages: Set<Data>
        let outputPublicKeys: Set<Data>
        let fee = Self.fee
        let tombstoneBlockIndex = Self.tombstoneBlockIndex

        init() throws {
            let serializedData = try Serialization.serializedData()
            self.transaction = try XCTUnwrap(Transaction(serializedData: serializedData))
            self.tx = External_Tx(transaction)
            self.inputKeyImages = try Self.inputKeyImages()
            self.outputPublicKeys = try Self.outputPublicKeys()
        }
    }
}

extension Transaction.Fixtures {
    struct Serialization {
        let transaction: Transaction
        let serializedData: Data

        init() throws {
            self.transaction = try Transaction.Fixtures.Default().transaction
            self.serializedData = try Self.serializedData()
        }
    }
}

extension Transaction.Fixtures.BuildTx {
    fileprivate static var defaultBlockVersion = BlockVersion.minRTHEnabled

    fileprivate static func inputs() throws -> [PreparedTxInput] {
        let knownTxOut = try XCTUnwrap(KnownTxOut(
            LedgerTxOut(
                PartialTxOut(
                    encryptedMemo: Data66(),
                    maskedAmount: MaskedAmount(
                        maskedValue: 2886556578342610519,
                        maskedTokenId: McConstants.LEGACY_MOB_MASKED_TOKEN_ID,
                        commitment: Data32(base64Encoded:
                            "uImiYd/FgPnNUbRkBu5+F61QNO4DXF8NNCPIzKy/2UA=")!,
                        version: .v1),
                    targetKey: RistrettoPublic(base64Encoded:
                        "VECBlIdhtmTFaXtlWphlqELpDL04EKMbbPWu3CoJ2UE=")!,
                    publicKey: RistrettoPublic(base64Encoded:
                        "OHyDzGA0vvts1Rkgsb2sAYfgCTBQqnOQ4cz5iI7JSh4=")!),
                globalIndex: 100011,
                block: BlockMetadata(
                    index: 2,
                    timestampStatus: .known(
                        timestamp: Date(timeIntervalSince1970: 1602883052.0)))),
            accountKey: try XCTUnwrap(AccountKey(serializedData: Data(base64Encoded: """
                CiIKIOehy72XOCsNdTLzG/RefRYoupEnA502UKNx5mdax7QNEiIKILuf18L68eT2bJeXd+3f153oGnliqOR\
                aT9pefNlL0LAAGilmb2c6Ly9mb2ctaW5nZXN0Lm1vYmlsZWRldi5tb2JpbGVjb2luLmNvbSoUI+nfq9r3TG\
                lCjsDfrBV4Tu3HRm4=
                """)!))))

        let ring: [(TxOut, TxOutMembershipProof)] = try [
            (
                """
                    Ci0KIgoguImiYd/FgPnNUbRkBu5+F61QNO4DXF8NNCPIzKy/2UARV6YtFOobDygSIgogVECBlIdhtmT\
                    FaXtlWphlqELpDL04EKMbbPWu3CoJ2UEaIgogOHyDzGA0vvts1Rkgsb2sAYfgCTBQqnOQ4cz5iI7JSh\
                    4iVgpUFDnmnE50RaxomaHM2Pr6R2NTrMdK4wEILd6fCqLjf8p2PgDbnphk2sEBUpKqf4broDg2qx9MN\
                    31M5GBQVcVK+BUdpY4T4wkT4SU/LFNJqZVWfwEA
                    """,
                """
                    CKuNBhCumQkaLgoICKuNBhCrjQYSIgogGKFP8jdRPcBssJ3qH60iJ8gXnqwn3uziW/KyknkifGsaLgo\
                    ICKqNBhCqjQYSIgogjK36vJ1F+3wX1tq9ps8k9Z/cb5IS0PT20J489/mVOHsaLgoICKiNBhCpjQYSIg\
                    ogRiPZVtRxM4VBd2WFb8WY3E62qxn4IN6W1kKKE/PBBM4aLgoICKyNBhCvjQYSIgogze9YatBYcx5/G\
                    uw430WbjtflaQiEM/SpOrZfOQV4/EkaLgoICKCNBhCnjQYSIgogWomMWzcorJNJ+PEJ0C3eaNNDGgK7\
                    IQMW9HfsGvcqRCkaLgoICLCNBhC/jQYSIgogBhs89gMNNfX7gvMkL4O+5f9CPjtp50TgckdQLDBotWE\
                    aLgoICICNBhCfjQYSIgogcaarxnWiFnidf5kuD5g5aHktAJHbtSUvYd3GDl+Xmc0aLgoICMCNBhD/jQ\
                    YSIgogEKR6aeMZQDmJFvUpuWliUAQgAwqPnNNpgKfGcoGCh8UaLgoICICMBhD/jAYSIgogIOHTMI1hm\
                    kSO9fqLWAdLeAURyA2562bRacSXE5DkdFEaLgoICICOBhD/jwYSIgog4QXBk/2YSW/7xJs7eFtkN5BP\
                    JygqBccqCwalzf/8AaAaLgoICICIBhD/iwYSIgog26Jrh3hoKIInouVD5ZUCmVphsq+DytwqkM5HljM\
                    1nRoaLgoICICABhD/hwYSIgogXi5tXDgpRQnjhjeCVFgdoVK2jQqDMH7Ty6xNSAjsdoYaLgoICICQBh\
                    D/nwYSIgogYNRpbsDLos93SCTzwWnv5NebGnwAlx8v0Boovea4jFAaLgoICICgBhD/vwYSIgogNKTBH\
                    Av1MykX99YCB4MQlCbas/v+stUdTXRb8Emt8aQaLgoICIDABhD//wYSIgogSjf2Q/LRy5VUwAOkqtIj\
                    Rmr/o18ZpB96TNt+2/hTO6IaLgoICICABxD//wcSIgogb3yeoumEEG8UJgj6sBUq07K1HsFsJJgw5s+\
                    ZSNRbWRcaLgoICICABBD//wUSIgogHHj77MOGpM4oFjdG2Mke1MkKp4t/YVkTvYLzyvpEaJ0aKgoEEP\
                    //AxIiCiDHA1UmtYroaXdipx+2xfiOad6aEFbtzhfEu2uTUXPM6xouCggIgIAIEP//DxIiCiChCfLXM\
                    66iL1JTrn5mPeS2lNGO9oJ5dBzqDCvBKIi+dg==
                    """
            ),
            (
                """
                    Ci0KIgogZLMpTUm3codYcrMIiokeWe7kNYy5lWDA5ykOwYV9AgURY2zBa0WXvVISIgogunrz4fo0z/k\
                    04C/7q6z6ffHTcLMHgXku3Lx7IK6xnEIaIgogOqF+vLrpwQFhJv657RJmG258vv7lhxhvfZ99f98TCH\
                    0iVgpUZSSUOAosJNxrMGlwOkwFbclxoPMjz/Mg7vjzmNjA+RcEhWxMRXxryIJt8bnYrWlbbRxhskeP4\
                    uCn6zzsslAxWXY5FnE87nfJ628u7Ti3AozxdgEA
                    """,
                """
                    CAkQrpkJGioKBAgJEAkSIgognKcDx/hu4iAlKyWkdCwgIYagjCWGZzVfCM/naGPvAZ4aKgoECAgQCBI\
                    iCiBAr62n9cfbTlmKxQkNEfWZNmLxi+hblOFG6/G/P/d18hoqCgQIChALEiIKIIn5OYPIj2hUREaxG8\
                    AvwpPWjBeUwZ2gV4wInAB88BnRGioKBAgMEA8SIgogTxjaTwHcjvTJsYuG6v4/ccOxJ5pP/R6s8uXOd\
                    aZra24aKAoCEAcSIgogjEJXP5CfpX/uv0pyEULGImed3sGiPqm/3Q6+n1vffXcaKgoECBAQHxIiCiDs\
                    P0PQ+y2+CNtnPWIXnH1IdeCkp2XpUU1F3RIoHiLQLxoqCgQIIBA/EiIKILVNW44xgYYzjs2IUJ4yTWH\
                    ocdGPvOQYTgXJg2cxM3W8GioKBAhAEH8SIgogJgbcJZdShPm9Nhuib7C2h/oHKZy/wDdR7nnDF2zjHa\
                    caLAoGCIABEP8BEiIKIPVW1wQMkbDPVQUoZRVDMEr+FH5UX56oXOHp6twz2M/oGiwKBgiAAhD/AxIiC\
                    iA8G1Cxb8rT5ZAeF2CoUm+oIlM68JCI+RigsRnFil4hbBosCgYIgAQQ/wcSIgogg7TzXAOU0ONaum+8\
                    FOoswHmTmzTI5duGHGLuwmRDZsYaLAoGCIAIEP8PEiIKICfuqbgHS0PO3hKNuUCHcgv5OJo9EN5Dodc\
                    wVKQV7EiiGiwKBgiAEBD/HxIiCiDlpWHI7wpVFw2EdAcig6qJVn2aBYdqLC6zB9z7Wq9wbBosCgYIgC\
                    AQ/z8SIgog1+MeQVNC0vlFd0NMGOvK65+0gil4bCGXxTuoeNyF2J0aLAoGCIBAEP9/EiIKIDfo4T8gy\
                    FYNoLKoiBqplZOAChbJn8aEQejr28Wfd5E1Gi4KCAiAgAEQ//8BEiIKIFyvq8TaJjXble16bZOOyo9v\
                    PrtDnSPrngR2C0aF4J10Gi4KCAiAgAIQ//8DEiIKIE7l402lC0ruffB1VkIQKe+2f6Sh/hE5gUDmY5Z\
                    xKIK7Gi4KCAiAgAQQ//8HEiIKIOTq52imyqFiZjil2jHXNtBx2BKZxSmw944x7i68ljgFGi4KCAiAgA\
                    gQ//8PEiIKIKEJ8tczrqIvUlOufmY95LaU0Y72gnl0HOoMK8EoiL52
                    """
            ),
            (
                """
                    Ci0KIgogRJwm18iyHr2hCjCq/QvGlbFST27ImGBUct9rcgn1XUgR1nrVJg0ckf4SIgogatL2qq9Cb3l\
                    fO5c4/V9suoxwijtYAyWiMoCZdA7RhQYaIgogOsOx3pQ5RaFVZNCatfQtygmFZxJjefWX9mB1DlrCrz\
                    oiVgpUKGCpebKIWBiTC4O1ykKPTyscIG+ZuQpHkJ7FXCh7//gF9mqsw7NnaFvhAKUSo9r6FGmyXis7x\
                    b2NisTiU8eEDnp3u+9Ytg8Fh4UqUQTQdWJPAAEA
                    """,
                """
                    CAMQrpkJGioKBAgDEAMSIgogGAK3qiA9ptHNKzPRElCq9+8mPrwUjQSpSvamEgtlcOkaKgoECAIQAhI\
                    iCiBWq8jIqCOu7SgBZv5DeOqnDAmEtlcbgIpkul7BgOnXIRooCgIQARIiCiDQPZiR2FSBtq2dlZmagn\
                    b6LbeW4BSCgg62mFTbgYjakBoqCgQIBBAHEiIKIJ0prgNhwF3q1oSSwUUsrzg9J1uVxmWHHlMW4Y77S\
                    OthGioKBAgIEA8SIgoglK9ax19fd1IDvoFptzzWi1B46sMiqsdI59/ZlArH35gaKgoECBAQHxIiCiDs\
                    P0PQ+y2+CNtnPWIXnH1IdeCkp2XpUU1F3RIoHiLQLxoqCgQIIBA/EiIKILVNW44xgYYzjs2IUJ4yTWH\
                    ocdGPvOQYTgXJg2cxM3W8GioKBAhAEH8SIgogJgbcJZdShPm9Nhuib7C2h/oHKZy/wDdR7nnDF2zjHa\
                    caLAoGCIABEP8BEiIKIPVW1wQMkbDPVQUoZRVDMEr+FH5UX56oXOHp6twz2M/oGiwKBgiAAhD/AxIiC\
                    iA8G1Cxb8rT5ZAeF2CoUm+oIlM68JCI+RigsRnFil4hbBosCgYIgAQQ/wcSIgogg7TzXAOU0ONaum+8\
                    FOoswHmTmzTI5duGHGLuwmRDZsYaLAoGCIAIEP8PEiIKICfuqbgHS0PO3hKNuUCHcgv5OJo9EN5Dodc\
                    wVKQV7EiiGiwKBgiAEBD/HxIiCiDlpWHI7wpVFw2EdAcig6qJVn2aBYdqLC6zB9z7Wq9wbBosCgYIgC\
                    AQ/z8SIgog1+MeQVNC0vlFd0NMGOvK65+0gil4bCGXxTuoeNyF2J0aLAoGCIBAEP9/EiIKIDfo4T8gy\
                    FYNoLKoiBqplZOAChbJn8aEQejr28Wfd5E1Gi4KCAiAgAEQ//8BEiIKIFyvq8TaJjXble16bZOOyo9v\
                    PrtDnSPrngR2C0aF4J10Gi4KCAiAgAIQ//8DEiIKIE7l402lC0ruffB1VkIQKe+2f6Sh/hE5gUDmY5Z\
                    xKIK7Gi4KCAiAgAQQ//8HEiIKIOTq52imyqFiZjil2jHXNtBx2BKZxSmw944x7i68ljgFGi4KCAiAgA\
                    gQ//8PEiIKIKEJ8tczrqIvUlOufmY95LaU0Y72gnl0HOoMK8EoiL52
                    """
            ),
            (
                """
                    Ci0KIgog/ktfF7xz1dXNmdmgLtBSUQUlRaSc+7CpXsDLmxQC81YRIO/xU2mLJFkSIgog3NZ7my81+bq\
                    ZzH9mXKNzyrPhnIpo5kGcuHPLkpJcHAYaIgogTA5KRyuFu+RZuYZKP9i1l533CiZILz0NbNFGgMnc4V\
                    MiVgpULeJwjU4b5KANeMCR/aHm897cb5VuRVwLgYAQ/T+CbqkV3uoF8dE4q2TYgD5BpK2yLbaALjjze\
                    mMGgKDWWOyOBnBdYdD7WVDrCoWBC4XsClX8MwEA
                    """,
                """
                    CAUQrpkJGioKBAgFEAUSIgog5OBhinRIZNLnVkVoINdeEMttYbdsan9yQFrJ9C5upboaKgoECAQQBBI\
                    iCiDL5KsDoVcmtHNkKp1Ul6+5Ki3v/hFZ6bDvu4bW193pGBoqCgQIBhAHEiIKIBzdtDBABzwQ79Cvwo\
                    2CkimC3N9lhLMIQbSojyNxMf/bGigKAhADEiIKIHzANt8/nHW7NYTk1eWF6LTv1bHBHIgXWDvGOYwFD\
                    wMrGioKBAgIEA8SIgoglK9ax19fd1IDvoFptzzWi1B46sMiqsdI59/ZlArH35gaKgoECBAQHxIiCiDs\
                    P0PQ+y2+CNtnPWIXnH1IdeCkp2XpUU1F3RIoHiLQLxoqCgQIIBA/EiIKILVNW44xgYYzjs2IUJ4yTWH\
                    ocdGPvOQYTgXJg2cxM3W8GioKBAhAEH8SIgogJgbcJZdShPm9Nhuib7C2h/oHKZy/wDdR7nnDF2zjHa\
                    caLAoGCIABEP8BEiIKIPVW1wQMkbDPVQUoZRVDMEr+FH5UX56oXOHp6twz2M/oGiwKBgiAAhD/AxIiC\
                    iA8G1Cxb8rT5ZAeF2CoUm+oIlM68JCI+RigsRnFil4hbBosCgYIgAQQ/wcSIgogg7TzXAOU0ONaum+8\
                    FOoswHmTmzTI5duGHGLuwmRDZsYaLAoGCIAIEP8PEiIKICfuqbgHS0PO3hKNuUCHcgv5OJo9EN5Dodc\
                    wVKQV7EiiGiwKBgiAEBD/HxIiCiDlpWHI7wpVFw2EdAcig6qJVn2aBYdqLC6zB9z7Wq9wbBosCgYIgC\
                    AQ/z8SIgog1+MeQVNC0vlFd0NMGOvK65+0gil4bCGXxTuoeNyF2J0aLAoGCIBAEP9/EiIKIDfo4T8gy\
                    FYNoLKoiBqplZOAChbJn8aEQejr28Wfd5E1Gi4KCAiAgAEQ//8BEiIKIFyvq8TaJjXble16bZOOyo9v\
                    PrtDnSPrngR2C0aF4J10Gi4KCAiAgAIQ//8DEiIKIE7l402lC0ruffB1VkIQKe+2f6Sh/hE5gUDmY5Z\
                    xKIK7Gi4KCAiAgAQQ//8HEiIKIOTq52imyqFiZjil2jHXNtBx2BKZxSmw944x7i68ljgFGi4KCAiAgA\
                    gQ//8PEiIKIKEJ8tczrqIvUlOufmY95LaU0Y72gnl0HOoMK8EoiL52
                    """
            ),
            (
                """
                    Ci0KIgogDNohyGL2/DCezioQv/Ue1x2LpcZ9s2y13CgNFxcaVVgR1U5EWVS1yysSIgogOttVHolhls9\
                    EpQxuHCBg3zT2u7swbIKKbVr01w/VxXcaIgogWGzYZTA45PoK1UeBPL7egAn3v9ZvT8VIm/8Zgy0HR1\
                    AiVgpUv9dqZZmbYvab6w++sl64TDN62Vpd7lqf+UMTUTYyl/e/9QYazT/nFbvA5M6i86EqcJWtwkbUM\
                    7wqfqOYQ+iJwFFYULx3vRDVUri5nMHIFFmeZQEA
                    """,
                """
                    CAcQrpkJGioKBAgHEAcSIgogd7+1GO045m8/MwW8BzJjdAS37OF/f7EHno4rQF1znDsaKgoECAYQBhI\
                    iCiAI6gBZk5XeJfSfJgMIe6natxaQzBXkDybhkupEVasD4RoqCgQIBBAFEiIKIK0BPLZ1ashlqRI0fI\
                    ofhQShArbArY01cy4/kmSsbnhVGigKAhADEiIKIHzANt8/nHW7NYTk1eWF6LTv1bHBHIgXWDvGOYwFD\
                    wMrGioKBAgIEA8SIgoglK9ax19fd1IDvoFptzzWi1B46sMiqsdI59/ZlArH35gaKgoECBAQHxIiCiDs\
                    P0PQ+y2+CNtnPWIXnH1IdeCkp2XpUU1F3RIoHiLQLxoqCgQIIBA/EiIKILVNW44xgYYzjs2IUJ4yTWH\
                    ocdGPvOQYTgXJg2cxM3W8GioKBAhAEH8SIgogJgbcJZdShPm9Nhuib7C2h/oHKZy/wDdR7nnDF2zjHa\
                    caLAoGCIABEP8BEiIKIPVW1wQMkbDPVQUoZRVDMEr+FH5UX56oXOHp6twz2M/oGiwKBgiAAhD/AxIiC\
                    iA8G1Cxb8rT5ZAeF2CoUm+oIlM68JCI+RigsRnFil4hbBosCgYIgAQQ/wcSIgogg7TzXAOU0ONaum+8\
                    FOoswHmTmzTI5duGHGLuwmRDZsYaLAoGCIAIEP8PEiIKICfuqbgHS0PO3hKNuUCHcgv5OJo9EN5Dodc\
                    wVKQV7EiiGiwKBgiAEBD/HxIiCiDlpWHI7wpVFw2EdAcig6qJVn2aBYdqLC6zB9z7Wq9wbBosCgYIgC\
                    AQ/z8SIgog1+MeQVNC0vlFd0NMGOvK65+0gil4bCGXxTuoeNyF2J0aLAoGCIBAEP9/EiIKIDfo4T8gy\
                    FYNoLKoiBqplZOAChbJn8aEQejr28Wfd5E1Gi4KCAiAgAEQ//8BEiIKIFyvq8TaJjXble16bZOOyo9v\
                    PrtDnSPrngR2C0aF4J10Gi4KCAiAgAIQ//8DEiIKIE7l402lC0ruffB1VkIQKe+2f6Sh/hE5gUDmY5Z\
                    xKIK7Gi4KCAiAgAQQ//8HEiIKIOTq52imyqFiZjil2jHXNtBx2BKZxSmw944x7i68ljgFGi4KCAiAgA\
                    gQ//8PEiIKIKEJ8tczrqIvUlOufmY95LaU0Y72gnl0HOoMK8EoiL52
                    """
            ),
            (
                """
                    Ci0KIgogMhh2S6d1d1GgBwBTiZH5FWpKzOEBRRkoQ7cei0wRcCgRMwLJvTnC0coSIgogGgdI8wsR4No\
                    BdekqxRwdKvkQbr12Oo+KlEn3crEIrzIaIgoghNKt6Nt6AVseYpqNFNVt3v/EEuaZDH5ceI+IyK4Wqk\
                    8iVgpUxPI7yAPeAwmoD2wEQzQbB/o6CA0gMjN/PLk/kKrbKj/VhKRinppI/ze3jfPggE0fpIySqI0Zx\
                    F+yyjAtUMt8dAV262JISu+yiqIUnZhWaWZlswEA
                    """,
                """
                    CAIQrpkJGioKBAgCEAISIgogVqvIyKgjru0oAWb+Q3jqpwwJhLZXG4CKZLpewYDp1yEaKgoECAMQAxI\
                    iCiAYAreqID2m0c0rM9ESUKr37yY+vBSNBKlK9qYSC2Vw6RooCgIQARIiCiDQPZiR2FSBtq2dlZmagn\
                    b6LbeW4BSCgg62mFTbgYjakBoqCgQIBBAHEiIKIJ0prgNhwF3q1oSSwUUsrzg9J1uVxmWHHlMW4Y77S\
                    OthGioKBAgIEA8SIgoglK9ax19fd1IDvoFptzzWi1B46sMiqsdI59/ZlArH35gaKgoECBAQHxIiCiDs\
                    P0PQ+y2+CNtnPWIXnH1IdeCkp2XpUU1F3RIoHiLQLxoqCgQIIBA/EiIKILVNW44xgYYzjs2IUJ4yTWH\
                    ocdGPvOQYTgXJg2cxM3W8GioKBAhAEH8SIgogJgbcJZdShPm9Nhuib7C2h/oHKZy/wDdR7nnDF2zjHa\
                    caLAoGCIABEP8BEiIKIPVW1wQMkbDPVQUoZRVDMEr+FH5UX56oXOHp6twz2M/oGiwKBgiAAhD/AxIiC\
                    iA8G1Cxb8rT5ZAeF2CoUm+oIlM68JCI+RigsRnFil4hbBosCgYIgAQQ/wcSIgogg7TzXAOU0ONaum+8\
                    FOoswHmTmzTI5duGHGLuwmRDZsYaLAoGCIAIEP8PEiIKICfuqbgHS0PO3hKNuUCHcgv5OJo9EN5Dodc\
                    wVKQV7EiiGiwKBgiAEBD/HxIiCiDlpWHI7wpVFw2EdAcig6qJVn2aBYdqLC6zB9z7Wq9wbBosCgYIgC\
                    AQ/z8SIgog1+MeQVNC0vlFd0NMGOvK65+0gil4bCGXxTuoeNyF2J0aLAoGCIBAEP9/EiIKIDfo4T8gy\
                    FYNoLKoiBqplZOAChbJn8aEQejr28Wfd5E1Gi4KCAiAgAEQ//8BEiIKIFyvq8TaJjXble16bZOOyo9v\
                    PrtDnSPrngR2C0aF4J10Gi4KCAiAgAIQ//8DEiIKIE7l402lC0ruffB1VkIQKe+2f6Sh/hE5gUDmY5Z\
                    xKIK7Gi4KCAiAgAQQ//8HEiIKIOTq52imyqFiZjil2jHXNtBx2BKZxSmw944x7i68ljgFGi4KCAiAgA\
                    gQ//8PEiIKIKEJ8tczrqIvUlOufmY95LaU0Y72gnl0HOoMK8EoiL52
                    """
            ),
            (
                """
                    Ci0KIgogILXm9RU1TrCsCipooMnzY4R9vKFe6MDDkB0QuhtM2mkRsuQP0bOMA0ASIgogxpwvORW4PeS\
                    roRWZaaiOMv/g2AC+zp4T3mlxLOTMh0AaIgogmP9LhFw3IVtMASLLVRmvuFCTDVCQfuPKI7ObX7oo8S\
                    IiVgpUNzrW1dfY4HfZxQYOMakL3ewLjVlxJQzLcSvX0iRqfMpsxzCdxSYNIWDvzsew2R9lgaq1iX17K\
                    r0IdpROjXUPNUY9gUiTXm2zwECshrR6LVzY4gEA
                    """,
                """
                    CAEQrpkJGioKBAgBEAESIgogen5UJWgJCWh9t42T4vsiG80oY0EdPOOvuV/bdD/ECiUaJgoAEiIKIBc\
                    yF1mQ38h+9QTe0j61UMpoDBh+ibhrEeUcfxZR1gX6GioKBAgCEAMSIgogx5HG9np4mN6FRS9spOpee/\
                    DPmUNkucr1UFlDear3EVEaKgoECAQQBxIiCiCdKa4DYcBd6taEksFFLK84PSdblcZlhx5TFuGO+0jrY\
                    RoqCgQICBAPEiIKIJSvWsdfX3dSA76Babc81otQeOrDIqrHSOff2ZQKx9+YGioKBAgQEB8SIgog7D9D\
                    0PstvgjbZz1iF5x9SHXgpKdl6VFNRd0SKB4i0C8aKgoECCAQPxIiCiC1TVuOMYGGM47NiFCeMk1h6HH\
                    Rj7zkGE4FyYNnMTN1vBoqCgQIQBB/EiIKICYG3CWXUoT5vTYbom+wtof6Bymcv8A3Ue55wxds4x2nGi\
                    wKBgiAARD/ARIiCiD1VtcEDJGwz1UFKGUVQzBK/hR+VF+eqFzh6ercM9jP6BosCgYIgAIQ/wMSIgogP\
                    BtQsW/K0+WQHhdgqFJvqCJTOvCQiPkYoLEZxYpeIWwaLAoGCIAEEP8HEiIKIIO081wDlNDjWrpvvBTq\
                    LMB5k5s0yOXbhhxi7sJkQ2bGGiwKBgiACBD/DxIiCiAn7qm4B0tDzt4SjblAh3IL+TiaPRDeQ6HXMFS\
                    kFexIohosCgYIgBAQ/x8SIgog5aVhyO8KVRcNhHQHIoOqiVZ9mgWHaiwuswfc+1qvcGwaLAoGCIAgEP\
                    8/EiIKINfjHkFTQtL5RXdDTBjryuuftIIpeGwhl8U7qHjchdidGiwKBgiAQBD/fxIiCiA36OE/IMhWD\
                    aCyqIgaqZWTgAoWyZ/GhEHo69vFn3eRNRouCggIgIABEP//ARIiCiBcr6vE2iY125Xtem2TjsqPbz67\
                    Q50j654EdgtGheCddBouCggIgIACEP//AxIiCiBO5eNNpQtK7n3wdVZCECnvtn+kof4ROYFA5mOWcSi\
                    CuxouCggIgIAEEP//BxIiCiDk6udopsqhYmY4pdox1zbQcdgSmcUpsPeOMe4uvJY4BRouCggIgIAIEP\
                    //DxIiCiChCfLXM66iL1JTrn5mPeS2lNGO9oJ5dBzqDCvBKIi+dg==
                    """
            ),
            (
                """
                    Ci0KIgogrr60Ucb4VG31yEnwQ5QPDp2aeHFLwAjEKpTxxY/cQWcRWh6K91+S5KsSIgogapTxe7NUEQj\
                    IlQiMdU7zQAElEpr/rIUTWY7qkzcciBQaIgogpIvHBLQ0G5qJggSUisbPe1zhKjYaaRIjkTdcmUofLz\
                    ciVgpUsOcFxWqHLQJvRtSEvtBZdW7NFFCL1eaDGT15nZNUmixoMJphUkxnIowkOo9WyEaU0a/1BegSZ\
                    bfhfQ/ouZgzOmtLFXyKng0gFiIV6y6umhm8VQEA
                    """,
                """
                    CAYQrpkJGioKBAgGEAYSIgogCOoAWZOV3iX0nyYDCHup2rcWkMwV5A8m4ZLqRFWrA+EaKgoECAcQBxI\
                    iCiB3v7UY7Tjmbz8zBbwHMmN0BLfs4X9/sQeejitAXXOcOxoqCgQIBBAFEiIKIK0BPLZ1ashlqRI0fI\
                    ofhQShArbArY01cy4/kmSsbnhVGigKAhADEiIKIHzANt8/nHW7NYTk1eWF6LTv1bHBHIgXWDvGOYwFD\
                    wMrGioKBAgIEA8SIgoglK9ax19fd1IDvoFptzzWi1B46sMiqsdI59/ZlArH35gaKgoECBAQHxIiCiDs\
                    P0PQ+y2+CNtnPWIXnH1IdeCkp2XpUU1F3RIoHiLQLxoqCgQIIBA/EiIKILVNW44xgYYzjs2IUJ4yTWH\
                    ocdGPvOQYTgXJg2cxM3W8GioKBAhAEH8SIgogJgbcJZdShPm9Nhuib7C2h/oHKZy/wDdR7nnDF2zjHa\
                    caLAoGCIABEP8BEiIKIPVW1wQMkbDPVQUoZRVDMEr+FH5UX56oXOHp6twz2M/oGiwKBgiAAhD/AxIiC\
                    iA8G1Cxb8rT5ZAeF2CoUm+oIlM68JCI+RigsRnFil4hbBosCgYIgAQQ/wcSIgogg7TzXAOU0ONaum+8\
                    FOoswHmTmzTI5duGHGLuwmRDZsYaLAoGCIAIEP8PEiIKICfuqbgHS0PO3hKNuUCHcgv5OJo9EN5Dodc\
                    wVKQV7EiiGiwKBgiAEBD/HxIiCiDlpWHI7wpVFw2EdAcig6qJVn2aBYdqLC6zB9z7Wq9wbBosCgYIgC\
                    AQ/z8SIgog1+MeQVNC0vlFd0NMGOvK65+0gil4bCGXxTuoeNyF2J0aLAoGCIBAEP9/EiIKIDfo4T8gy\
                    FYNoLKoiBqplZOAChbJn8aEQejr28Wfd5E1Gi4KCAiAgAEQ//8BEiIKIFyvq8TaJjXble16bZOOyo9v\
                    PrtDnSPrngR2C0aF4J10Gi4KCAiAgAIQ//8DEiIKIE7l402lC0ruffB1VkIQKe+2f6Sh/hE5gUDmY5Z\
                    xKIK7Gi4KCAiAgAQQ//8HEiIKIOTq52imyqFiZjil2jHXNtBx2BKZxSmw944x7i68ljgFGi4KCAiAgA\
                    gQ//8PEiIKIKEJ8tczrqIvUlOufmY95LaU0Y72gnl0HOoMK8EoiL52
                    """
            ),
            (
                """
                    Ci0KIgogqvIgtiuxQAqHxzv/VcLiLQlf+BK2GoP3nI+LUY4fh3wRyGwR1Q1+hGcSIgogbuh/V1ScuAV\
                    2mUulOdUsvUMEFRucCSQrV5J2PncHo2oaIgoguA6uOB6g8Mf/9ZqmC9Phk3+ShSfuTT1QaK1eDVBu1A\
                    4iVgpUEpXKMP+ltj+dGbetGv3IzVlVyzwZ+hCL4BgocsWxf0FE0E4+DLwxufdcy0WbqC8ZTumKAGFK0\
                    O2Ey8yOMBELartXClbRSescdXAIT80DrH0mCwEA
                    """,
                """
                    EK6ZCRomCgASIgogFzIXWZDfyH71BN7SPrVQymgMGH6JuGsR5Rx/FlHWBfoaKgoECAEQARIiCiB6flQ\
                    laAkJaH23jZPi+yIbzShjQR0846+5X9t0P8QKJRoqCgQIAhADEiIKIMeRxvZ6eJjehUUvbKTqXnvwz5\
                    lDZLnK9VBZQ3mq9xFRGioKBAgEEAcSIgognSmuA2HAXerWhJLBRSyvOD0nW5XGZYceUxbhjvtI62EaK\
                    goECAgQDxIiCiCUr1rHX193UgO+gWm3PNaLUHjqwyKqx0jn39mUCsffmBoqCgQIEBAfEiIKIOw/Q9D7\
                    Lb4I22c9YhecfUh14KSnZelRTUXdEigeItAvGioKBAggED8SIgogtU1bjjGBhjOOzYhQnjJNYehx0Y+\
                    85BhOBcmDZzEzdbwaKgoECEAQfxIiCiAmBtwll1KE+b02G6JvsLaH+gcpnL/AN1HuecMXbOMdpxosCg\
                    YIgAEQ/wESIgog9VbXBAyRsM9VBShlFUMwSv4UflRfnqhc4enq3DPYz+gaLAoGCIACEP8DEiIKIDwbU\
                    LFvytPlkB4XYKhSb6giUzrwkIj5GKCxGcWKXiFsGiwKBgiABBD/BxIiCiCDtPNcA5TQ41q6b7wU6izA\
                    eZObNMjl24YcYu7CZENmxhosCgYIgAgQ/w8SIgogJ+6puAdLQ87eEo25QIdyC/k4mj0Q3kOh1zBUpBX\
                    sSKIaLAoGCIAQEP8fEiIKIOWlYcjvClUXDYR0ByKDqolWfZoFh2osLrMH3Ptar3BsGiwKBgiAIBD/Px\
                    IiCiDX4x5BU0LS+UV3Q0wY68rrn7SCKXhsIZfFO6h43IXYnRosCgYIgEAQ/38SIgogN+jhPyDIVg2gs\
                    qiIGqmVk4AKFsmfxoRB6OvbxZ93kTUaLgoICICAARD//wESIgogXK+rxNomNduV7Xptk47Kj28+u0Od\
                    I+ueBHYLRoXgnXQaLgoICICAAhD//wMSIgogTuXjTaULSu598HVWQhAp77Z/pKH+ETmBQOZjlnEogrs\
                    aLgoICICABBD//wcSIgog5OrnaKbKoWJmOKXaMdc20HHYEpnFKbD3jjHuLryWOAUaLgoICICACBD//w\
                    8SIgogoQny1zOuoi9SU65+Zj3ktpTRjvaCeXQc6gwrwSiIvnY=
                    """
            ),
            (
                """
                    Ci0KIgog4AjVI2JEDOua3ZWQppBFMifhOiUIVwaRGbcihmTcDzcRu5AHLxzto3ISIgogitebMb1dXe6\
                    erA6jj1G0wuYSE9ZvqvB4KHBk34I6DzoaIgog3s29+r7yHHrDYY671ORDKq7SCwewHM/ceqgjgP8GrE\
                    giVgpUKd+nw3qBKRkTnh3RsxSgS2AvAFgdb+sFtUYRWwnm24gVUO65MAC2DlBDIhCtluEITRR+M/o25\
                    ELeCJ4RZ0HnTaBIEQ9i08LVYTdgwuMr7ByLkAEA
                    """,
                """
                    CAQQrpkJGioKBAgEEAQSIgogy+SrA6FXJrRzZCqdVJevuSot7/4RWemw77uG1tfd6RgaKgoECAUQBRI\
                    iCiDk4GGKdEhk0udWRWgg114Qy21ht2xqf3JAWsn0Lm6luhoqCgQIBhAHEiIKIBzdtDBABzwQ79Cvwo\
                    2CkimC3N9lhLMIQbSojyNxMf/bGigKAhADEiIKIHzANt8/nHW7NYTk1eWF6LTv1bHBHIgXWDvGOYwFD\
                    wMrGioKBAgIEA8SIgoglK9ax19fd1IDvoFptzzWi1B46sMiqsdI59/ZlArH35gaKgoECBAQHxIiCiDs\
                    P0PQ+y2+CNtnPWIXnH1IdeCkp2XpUU1F3RIoHiLQLxoqCgQIIBA/EiIKILVNW44xgYYzjs2IUJ4yTWH\
                    ocdGPvOQYTgXJg2cxM3W8GioKBAhAEH8SIgogJgbcJZdShPm9Nhuib7C2h/oHKZy/wDdR7nnDF2zjHa\
                    caLAoGCIABEP8BEiIKIPVW1wQMkbDPVQUoZRVDMEr+FH5UX56oXOHp6twz2M/oGiwKBgiAAhD/AxIiC\
                    iA8G1Cxb8rT5ZAeF2CoUm+oIlM68JCI+RigsRnFil4hbBosCgYIgAQQ/wcSIgogg7TzXAOU0ONaum+8\
                    FOoswHmTmzTI5duGHGLuwmRDZsYaLAoGCIAIEP8PEiIKICfuqbgHS0PO3hKNuUCHcgv5OJo9EN5Dodc\
                    wVKQV7EiiGiwKBgiAEBD/HxIiCiDlpWHI7wpVFw2EdAcig6qJVn2aBYdqLC6zB9z7Wq9wbBosCgYIgC\
                    AQ/z8SIgog1+MeQVNC0vlFd0NMGOvK65+0gil4bCGXxTuoeNyF2J0aLAoGCIBAEP9/EiIKIDfo4T8gy\
                    FYNoLKoiBqplZOAChbJn8aEQejr28Wfd5E1Gi4KCAiAgAEQ//8BEiIKIFyvq8TaJjXble16bZOOyo9v\
                    PrtDnSPrngR2C0aF4J10Gi4KCAiAgAIQ//8DEiIKIE7l402lC0ruffB1VkIQKe+2f6Sh/hE5gUDmY5Z\
                    xKIK7Gi4KCAiAgAQQ//8HEiIKIOTq52imyqFiZjil2jHXNtBx2BKZxSmw944x7i68ljgFGi4KCAiAgA\
                    gQ//8PEiIKIKEJ8tczrqIvUlOufmY95LaU0Y72gnl0HOoMK8EoiL52
                    """
            ),
            (
                """
                    Ci0KIgogvA4PvbpHrTensVBf0897C/ochZ0572kVLUXSKBeZJFMRwjpOuYk6KWkSIgog6nEnUo3DVNo\
                    5oMuWQbuCC+3mjSLiqSs54Z5i+QpFIkMaIgog+neKXgDk+w0aA02sNras9kjtfR8PfmIWaTe0+uMilX\
                    UiVgpUEYiDkL8tAB+Qow6z49Ve0rkLNj98fP6t9MUycACJn5paF37y6W5QuAGtGEJoF6rexHAaRnSqm\
                    2J7QYXjK7lwmSkXGde1ztKuJShDN/DJ1CMfhQEA
                    """,
                """
                    CAgQrpkJGioKBAgIEAgSIgogQK+tp/XH205ZisUJDRH1mTZi8YvoW5ThRuvxvz/3dfIaKgoECAkQCRI\
                    iCiCcpwPH+G7iICUrJaR0LCAhhqCMJYZnNV8Iz+doY+8BnhoqCgQIChALEiIKIIn5OYPIj2hUREaxG8\
                    AvwpPWjBeUwZ2gV4wInAB88BnRGioKBAgMEA8SIgogTxjaTwHcjvTJsYuG6v4/ccOxJ5pP/R6s8uXOd\
                    aZra24aKAoCEAcSIgogjEJXP5CfpX/uv0pyEULGImed3sGiPqm/3Q6+n1vffXcaKgoECBAQHxIiCiDs\
                    P0PQ+y2+CNtnPWIXnH1IdeCkp2XpUU1F3RIoHiLQLxoqCgQIIBA/EiIKILVNW44xgYYzjs2IUJ4yTWH\
                    ocdGPvOQYTgXJg2cxM3W8GioKBAhAEH8SIgogJgbcJZdShPm9Nhuib7C2h/oHKZy/wDdR7nnDF2zjHa\
                    caLAoGCIABEP8BEiIKIPVW1wQMkbDPVQUoZRVDMEr+FH5UX56oXOHp6twz2M/oGiwKBgiAAhD/AxIiC\
                    iA8G1Cxb8rT5ZAeF2CoUm+oIlM68JCI+RigsRnFil4hbBosCgYIgAQQ/wcSIgogg7TzXAOU0ONaum+8\
                    FOoswHmTmzTI5duGHGLuwmRDZsYaLAoGCIAIEP8PEiIKICfuqbgHS0PO3hKNuUCHcgv5OJo9EN5Dodc\
                    wVKQV7EiiGiwKBgiAEBD/HxIiCiDlpWHI7wpVFw2EdAcig6qJVn2aBYdqLC6zB9z7Wq9wbBosCgYIgC\
                    AQ/z8SIgog1+MeQVNC0vlFd0NMGOvK65+0gil4bCGXxTuoeNyF2J0aLAoGCIBAEP9/EiIKIDfo4T8gy\
                    FYNoLKoiBqplZOAChbJn8aEQejr28Wfd5E1Gi4KCAiAgAEQ//8BEiIKIFyvq8TaJjXble16bZOOyo9v\
                    PrtDnSPrngR2C0aF4J10Gi4KCAiAgAIQ//8DEiIKIE7l402lC0ruffB1VkIQKe+2f6Sh/hE5gUDmY5Z\
                    xKIK7Gi4KCAiAgAQQ//8HEiIKIOTq52imyqFiZjil2jHXNtBx2BKZxSmw944x7i68ljgFGi4KCAiAgA\
                    gQ//8PEiIKIKEJ8tczrqIvUlOufmY95LaU0Y72gnl0HOoMK8EoiL52
                    """
            ),
        ].map {
            (
                try XCTUnwrap(TxOut(serializedData: XCTUnwrap(Data(base64Encoded: $0.0)))),
                try XCTUnwrapSuccess(
                    TxOutMembershipProof.make(serializedData: XCTUnwrap(Data(base64Encoded: $0.1))))
            )
        }

        return [try PreparedTxInput.make(knownTxOut: knownTxOut, ring: ring).get()]
    }

    fileprivate static func accountKey() throws -> AccountKey {
        let rootAccountKey = try XCTUnwrap(AccountKey(serializedData: Data(base64Encoded: """
            CiIKIOehy72XOCsNdTLzG/RefRYoupEnA502UKNx5mdax7QNEiIKILuf18L68eT2bJeXd+3f153oGnliqORaT9p\
            efNlL0LAAGilmb2c6Ly9mb2ctaW5nZXN0Lm1vYmlsZWRldi5tb2JpbGVjb2luLmNvbSoUI+nfq9r3TGlCjsDfrB\
            V4Tu3HRm4=
            """)!))

        return try AccountKey.make(
            viewPrivateKey: rootAccountKey.viewPrivateKey,
            spendPrivateKey: rootAccountKey.spendPrivateKey,
            fogReportUrl: try AccountKey.Fixtures.TestNet().fogReportUrl,
            fogReportId: try AccountKey.Fixtures.TestNet().fogReportId,
            fogAuthoritySpki: try AccountKey.Fixtures.TestNet().fogAuthoritySpki).get()
    }

    fileprivate static func outputs() throws
        -> [TransactionOutput]
    {
        [
            TransactionOutput(
                recipient: try PublicAddress.Fixtures.Default(accountIndex: 1).publicAddress,
                amount: Amount(10, in: .MOB)
            ),
            TransactionOutput(
                recipient: try PublicAddress.Fixtures.Default(accountIndex: 2).publicAddress,
                amount: Amount(2499979999999990, in: .MOB)
            ),
        ]
    }

    fileprivate static let fee = Amount(10_000_000_000, in: .MOB)

    fileprivate static let tombstoneBlockIndex: UInt64 = 610

    private static func fogReportUrl() throws -> String {
        try AccountKey.Fixtures.Init().fogReportUrl
    }

    fileprivate static func fogResolver() throws -> FogResolver {
        let fogReportUrl = try self.fogReportUrl()
        return try FogResolver.Fixtures.Default(reportUrl: fogReportUrl).fogResolver
    }

}

extension Transaction.Fixtures.BuildTxTestNet {
    fileprivate static var defaultBlockVersion = BlockVersion.minRTHEnabled

    fileprivate static func inputs() throws -> [PreparedTxInput] {
        let encryptedMemo =
            """
            DcunL2+v248PqyQ7RG8AQKONJ+lA4wKIkOuIpcnOMKRDHl837UdMHllJgh1xQePulv0d\
            sHOZ7MCtWfiz5cKxTQT1
            """

        let accountKeyB64 =
            """
            CiIKIMM0eFjAenKpb/qWCpMpLBobETadGuaJCNy45N0Ej7sPEiIKIEU+8R66uCyb7xsV\
            bX9qAPUa6cTxIpeQNIEQFoPbWFUKGh1mb2c6Ly9mb2cudGVzdC5tb2JpbGVjb2luLmNv\
            bSqmBDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL5wfcE20zk+bqIs0WGm\
            G8O1yBJCJ5fBOzBjgEI/sZwvhdayF4gp3P7dfuSCFo20RoVs6O0QMCObEWo59rE+K0Z/\
            TV2zs2TLyKhOIZoZhM8tWEDQ53wCwFjUPlgW2BlvlaptyJULwBRY1TdWGCHWIWy4wD3Z\
            IHlbFn3Cw36Kx5+q0d0AWWGSJUgUEikTGP7csE8Xkwryts1nEtJG2xT7QXFbYe1RRVTw\
            GV4T4vcstQL55XTup+yi4rqVZqI5RDLb+BUJJOtOJ2pfo/3TqZUwE1fGvQCQWz0QWf8k\
            IOexBtmNjEYhzkInycdEuVWzcjJvW5EvEw+xqIufWglujk9YMnqLVsC4OtCUWU38ie5W\
            FgUjs4dDp2gsrUaUlrTWem2qz1Hjp37W5ybRPKxYRezOBeunrdCyP3Lr12HnMFcMpKLx\
            FQSkReBzivRoEpte5kDLc6w+3OefE22rnDlmm2EdOLoXQHN7NdDJLjjVhtMCEIYCAoWF\
            QBpxS70qadv2kBKt8a0UhE8bIsVCI7GcllkTpLgNCBZ3PHewJnJ1Ab0VuxU/+bYVspOW\
            oHWFBmfuwtaOvYoUdWMZqBoevXyzDyBDoWIee9vt3JIJdkmleLqPRr5M/DDBkQXDCDJU\
            Yq0sIQn6M1dkck+Vp9TYD6cnPMyS+0HToS+0MW/uVo5wla0GByNnAgMBAAE=
            """

        let knownTxOut_1 = try XCTUnwrap(KnownTxOut(
            LedgerTxOut(
                PartialTxOut(
                    encryptedMemo: Data66(base64Encoded: encryptedMemo)!,
                    maskedAmount: MaskedAmount(
                        maskedValue: 17792466809847936602,
                        maskedTokenId: Data(base64Encoded: "EC9Fg2/A4JE=")!,
                        commitment: Data32(base64Encoded:
                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=")!,
                        version: .v2),
                    targetKey: RistrettoPublic(base64Encoded:
                        "uI3cGUyMcR84o6le4TOGXQQAG2W5ewmiGtdS3ZIRY1s=")!,
                    publicKey: RistrettoPublic(base64Encoded:
                        "WjPg2BFIBHDstggSjcxRgifgtaOu1ovMV51zyAbMpUs=")!),
                globalIndex: 4533908,
                block: BlockMetadata(
                    index: 1493080,
                    timestampStatus: .known(
                        timestamp: Date(timeIntervalSince1970: 1677540712.0)))),
            accountKey: try XCTUnwrap(
                AccountKey(serializedData: Data(base64Encoded: accountKeyB64)!))))

        let ring_1: [(TxOut, TxOutMembershipProof)] = try [
            (
            """
            EiIKIGZuzGVrvVM9CbcYrjj5M20jEG0+TwuNfCxducyRw+NIGiIKIBCZouvwbB1ILBT8\
            OdoEM6+NsZdjE/NlVfaEVMcSr9h+IlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
            AAAAAAAAACpECkJIVZZJ0KKL4eGFUKpy7hf47pg/lQjG3Kp2Cp/PIIB5IK+8uhQF8MoV\
            qaNX/T1dElDK331b6Vq0f5AqzSkkbR79brYyNwoiCiB2U3R99vlGrd2zyCLDxHYdTrvl\
            OiSBJ43Zd52idKKgSxFQ6NzXJvKruRoIitXMw1stY1A=
            """,
            """
            CKLclAIQ14/JAxowCgoIotyUAhCi3JQCEiIKIC9UANL6cNDmKQBcMuzpitHcP4otLZJo\
            o+9SEUg9QGYxGjAKCgij3JQCEKPclAISIgogSBYI/r5Ln2IHbKHRspOEfsh55Jd1LeZa\
            /hpVnbXYpaYaMAoKCKDclAIQodyUAhIiCiCOv3CFE0CGmjCM2vy04rAnhxdAPOaNd7LV\
            vGijwa8zDhowCgoIpNyUAhCn3JQCEiIKIIPQlCd65NFQkafHqo93koJnrLS6pr54R7z6\
            7oTAEUVhGjAKCgio3JQCEK/clAISIgogcgLOlo9pM8wo7rExjomvH0gQA3mwwOb2vKfE\
            dmHzbOQaMAoKCLDclAIQv9yUAhIiCiBTiFa2+tAcA/CiV9A/okVBwMa49sZJ//JLALhP\
            JpGwHBowCgoIgNyUAhCf3JQCEiIKIJL38h3bULz8rl8WtOWcoNCAEJI6QdXiaegG+7bt\
            iybgGjAKCgjA3JQCEP/clAISIgogid4dV7iW9EuJlxGSuXTnagmXXpoH7ACvXRCADeSA\
            p74aMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32z\
            iRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKILzjajhY3nB+0i5wVy9gaOJbme5XNyXoBLJhnyk/xxEMGiIKIB47l3d3UG8rIZ6K\
            a199MNzhtC8et6mgNY9p8K+rZoIiIlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
            AAAAAAAAACpECkJwKCL+60AQ9Ej/cE5qcsR7TWNjHOhv4vFPeQGuJwboSl+t581mXt7f\
            xjw21Gs5TMc7FaP7iwxRo9SIHX8Lj0Erb08yNwoiCiDWjBwPB1ZteLq+ZpGD4OlgaKvj\
            C2oe1cBSxeLDYnxDIBFe9uLRUyLUlRoIK8SQeB3Pb0w=
            """,
            """
            CKvclAIQ14/JAxowCgoIq9yUAhCr3JQCEiIKICeQWDzUYJErbLDfkukjVzRmiP97v6nv\
            NY8bqirx3TFjGjAKCgiq3JQCEKrclAISIgogbyW8S7KTo6adtj9p0FcrUXBM7yxWsYu5\
            YqK3NwhebkoaMAoKCKjclAIQqdyUAhIiCiAfG+YfrDU3ubtUmuk8jjEbhM/DWIq+8le+\
            eNJ9YLkxwRowCgoIrNyUAhCv3JQCEiIKIAmIOF/pm6zzy9hvz9/Z56GLDoMBzyhs79kx\
            2H2go/jDGjAKCgig3JQCEKfclAISIgog2U0/udHGjCcYBdlQJhM5GMUtLif8RJof5ERH\
            SWTg0egaMAoKCLDclAIQv9yUAhIiCiBTiFa2+tAcA/CiV9A/okVBwMa49sZJ//JLALhP\
            JpGwHBowCgoIgNyUAhCf3JQCEiIKIJL38h3bULz8rl8WtOWcoNCAEJI6QdXiaegG+7bt\
            iybgGjAKCgjA3JQCEP/clAISIgogid4dV7iW9EuJlxGSuXTnagmXXpoH7ACvXRCADeSA\
            p74aMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32z\
            iRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKIDxuOfwJYZ7xzMiEuMMx4kxiMfV3vvmpFJQLSjtA1vBuGiIKIB57uXZg81PRAAfV\
            lwN6TSCfuia/vPxTbIbxC3UcUEVeIlYKVMNwBtnrCgcttGGmlev7MsMdczpFf3hRlzwj\
            +suqirxHm4TUtNytzlXeNV6Ya7VHgVsdDeCy0CFWIG39aTFmnCVwdbWh4m5BNgA5HVZM\
            QaLWTa4BACpECkLiqOdNqAzq0mMsyEwgwlg++VEGVGzn48Tn5p10PZeCU1UIYuTIwJti\
            Hnme9f1yHfwlXgkZsLaTHiPn81TXjZOB/g0yNwoiCiD4mPj8+MssJ8VhJ3lkWO0skHfA\
            CPJcWsoR8vATvJ/JKRFC2Ah/d13R5xoI1+C7C04d048=
            """,
            """
            CMPclAIQ14/JAxowCgoIw9yUAhDD3JQCEiIKIK3NGzwJl1CkCAcfrkoSCeZbIWfOFCoy\
            qKtjEhNjawD0GjAKCgjC3JQCEMLclAISIgogBNtNou+hF9YV2Cdu/my2+iTBS3lHr/qg\
            z/WrJQURVMEaMAoKCMDclAIQwdyUAhIiCiAhTe0uk/VWeF1tzobwOf1UnJOa+kgyCIOS\
            1/yDRRhPLxowCgoIxNyUAhDH3JQCEiIKIE9FT9hEJzdzAi7gnSQxhi/BmogU4SuXi12k\
            ji+4mlW9GjAKCgjI3JQCEM/clAISIgogXRW+NAee4Rzwk4W+qMEVJgatphNMhB/ARL2i\
            0POiySUaMAoKCNDclAIQ39yUAhIiCiBioFquQAe4rC/SY9iWXivmxC2D3ydQ0cODRg2V\
            6c1CGRowCgoI4NyUAhD/3JQCEiIKIDXYv597nUABiIoj10DFLze7C7L4GA9DdMm8h0EI\
            yvwrGjAKCgiA3JQCEL/clAISIgogr3Z7tfLq6a5kZQ8a9Qbtke9192uT6HXwYKAkPVxc\
            tjEaMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32z\
            iRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKIEY+z9mLX0twJoKjjgA7uqbJ2KQzHqGGhbzdaZNmhJtcGiIKIB7VSR67Xo66WZ25\
            ge1Y3+p44fdZgfA3E9e/U/oZEPFfIlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
            AAAAAAAAACpECkLAjO3Yo3xSmI34uju9eSxPaI8/8slB0CnREv6PWufCJ8gTB+w5SzLN\
            4001Ulw54g+CB9XaRx+3n+8Vj0rUrtZs05EyNwoiCiBO3EC/r+paU/xhLMbfDtGxXCbD\
            tZ5kz1RutwvO2KwkZBHUqC3yu/rgaBoI7rrR6YhYHr4=
            """,
            """
            CIbdlAIQ14/JAxowCgoIht2UAhCG3ZQCEiIKICoSNROvrqaVH6GHsLkUfIXykd5WlZ2w\
            mtAvTHILQbNoGjAKCgiH3ZQCEIfdlAISIgognS0b5gJb3K8iStqqPSYjRBViovPFvyK+\
            zod8v0bRNNIaMAoKCITdlAIQhd2UAhIiCiAjIT3SFBr4RadhkaI5k3wd0nno7E/PWajv\
            fsSyrQupwxowCgoIgN2UAhCD3ZQCEiIKIDA3sh29P+4gF9edq9OxgXUz/9prOWA5lSAy\
            YwXbpf7xGjAKCgiI3ZQCEI/dlAISIgog4fFhbvQHfLRSLNh2AXy9AGYH+nyjnUGo/mos\
            AiuzHLwaMAoKCJDdlAIQn92UAhIiCiAWAWnMA/T8f7LGzR7nPbO5tGDsQzvNsU6H3nhq\
            MsEafRowCgoIoN2UAhC/3ZQCEiIKIK4PwbvI3U+ej/ouOmAbU2hnj+vwz/bCKBR1/nhk\
            BTfQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp\
            7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAy\
            phowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKIHrx30sHo83Bj8wS6niby8xTyxCBe1ZLgV6wYwROBvkTGiIKICJSdozOzor3ej1G\
            SBtiuXMQroKGHcxqGOiXBV4Ge8U9IlYKVOGSQZN2jdQVUhXyQQph+O/f5G/FYtvyep/r\
            xluix6g9+1deaN/4a+xjqJAAfpKPq/Ih/Z+S3sgJL6zUsMB/Z3gNLA7ZB1suNjdxI7PY\
            Ud4xQMkBACpECkI2Z+c05jqopzsoJhpj5P+rhrEKTmVgicLbz9K3h2HV2oYtX4d5QD+4\
            kP93pu2avoF3YMi8WkhAK7V2qTbUpD4mVTsyNwoiCiDcLmCMesCuvjksGAao8YP7tp5e\
            WZNCDtjKIP76sQ5zaxHpozJFRLoSBBoIFvFyb8cqnJ8=
            """,
            """
            CP/clAIQ14/JAxowCgoI/9yUAhD/3JQCEiIKIHq12PHnd0KbUNMuVosX4Sm1Pob23qVP\
            Nu6TJvOZojlDGjAKCgj+3JQCEP7clAISIgogT6lq0mYbQf49hyrDWLXyKMcJ2iPXNowQ\
            FANOVISdxdMaMAoKCPzclAIQ/dyUAhIiCiCd/OGJ5w0svo9w2Cl6k5TQWQEVq792MAED\
            FvINlfydDRowCgoI+NyUAhD73JQCEiIKIJ0kussziqLwYsHaoTu+ew4J6y7cj/P3WH7a\
            CuXsW6huGjAKCgjw3JQCEPfclAISIgogPIt9a29QhSELfiVKhEHqiOI1o2OK7CzLucYo\
            29OnBlgaMAoKCODclAIQ79yUAhIiCiABXwDLrCE6aF/x7MFAvrQX+fpjQO2gmR3SNfDL\
            TZTowxowCgoIwNyUAhDf3JQCEiIKIHRuI8xC+qYgDWW2tvXZYbqSi3Z5u1PEQ+4JlUZO\
            09kwGjAKCgiA3JQCEL/clAISIgogr3Z7tfLq6a5kZQ8a9Qbtke9192uT6HXwYKAkPVxc\
            tjEaMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32z\
            iRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKIN7zrUjjI2rJxxafGBcLf7SO2IWJswjtm3BUPlAF6g1eGiIKIEQPdr7am4gk912d\
            JobCKB1BWfNZ0Evj5JU6U2mHjtk3IlYKVOflEXSkiuc6MjxjZaqqQVK6NekA6hRTkY9L\
            7E3SGN43moM8SFB5/Y5dNqiC8wUEQfipzpyf60SZEwENiBs04xtWC53ScmqZqAaJmH0f\
            RcMBNzYBACpECkIBiaKmk0/mqVgSmgwgS5yb66AAYcVZFz3Rx2UecwrMU72YHqyPLR8R\
            bQXCe5OncivvxGAM3cafQBvIheM986DzzLoyNwoiCiAokpD0Oa+8DnCak1KsAouCTFWF\
            HEpovANKw36TsNFuchE+3qI8i5vpihoIrgM0E+a2K3Q=
            """,
            """
            COvclAIQ14/JAxowCgoI69yUAhDr3JQCEiIKIIlQsnLE//ZTX5d+edrbW5rzlQYDTx/s\
            JgexY6Ct40LCGjAKCgjq3JQCEOrclAISIgogeEN6wdxHQ+gxfdcFTgDbZwJwm3Td4nJg\
            0zrqlBOa7VAaMAoKCOjclAIQ6dyUAhIiCiDbQRLEw7isxHUtW17RIja7C81ykZOgywOK\
            lbF842C7txowCgoI7NyUAhDv3JQCEiIKIKF5wN7VyxthHEltm6QQdfeeMZLewgWMbBQl\
            SXS2QUeAGjAKCgjg3JQCEOfclAISIgogZRuNIskb4vBIuTCMXISSHz0ZK9mrQAWpqkH0\
            O/p/3ncaMAoKCPDclAIQ/9yUAhIiCiC740M2yUqHjGay/SPe55WpDG3L/uzFJ3gKF8pd\
            eh9JMxowCgoIwNyUAhDf3JQCEiIKIHRuI8xC+qYgDWW2tvXZYbqSi3Z5u1PEQ+4JlUZO\
            09kwGjAKCgiA3JQCEL/clAISIgogr3Z7tfLq6a5kZQ8a9Qbtke9192uT6HXwYKAkPVxc\
            tjEaMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32z\
            iRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKILiN3BlMjHEfOKOpXuEzhl0EABtluXsJohrXUt2SEWNbGiIKIFoz4NgRSARw7LYI\
            Eo3MUYIn4LWjrtaLzFedc8gGzKVLIlYKVJuduk/rOC2UW3mha2lABGb+aWBsB+3sFPhY\
            HhS8c/xD9XOUrFm8EtEXmej389ZCiliRtbBCCN2Td8JAjMGNPxJ1DmwXFjSb+Keovov5\
            gUkWwbMBACpECkINy6cvb6/bjw+rJDtEbwBAo40n6UDjAoiQ64ilyc4wpEMeXzftR0we\
            WUmCHXFB4+6W/R2wc5nswK1Z+LPlwrFNBPUyNwoiCiBCsIdsaNtM+gW4eedzCzXZUZa+\
            qluXIvvGdXil33G0CBFa9umGS4rr9hoIEC9Fg2/A4JE=
            """,
            """
            CJTdlAIQ14/JAxowCgoIlN2UAhCU3ZQCEiIKIG7g61YiysaTfeuTRReMfP/AAue7+NOe\
            e1ywjP6KwH/GGjAKCgiV3ZQCEJXdlAISIgog7M4kvFAF9RqOsNQ7gH0cFdlkWR0u13WR\
            2t+GGRprhIYaMAoKCJbdlAIQl92UAhIiCiAYYMCCvyQZdI2ApjpGUThaVuuHvtm7P9Er\
            dOKQEfC68BowCgoIkN2UAhCT3ZQCEiIKIC9AeEEReXg44I2do2rQpvm5L/B/PCY0fQyd\
            N3IptInoGjAKCgiY3ZQCEJ/dlAISIgogSfoptOxb1J3TdKqNiF8M5bJSE4ilbKTtsvT0\
            0NuupeMaMAoKCIDdlAIQj92UAhIiCiAiips/UPOfwvvu9EV5mFWZlIyoQvAlvIMgGLqi\
            c4sRQRowCgoIoN2UAhC/3ZQCEiIKIK4PwbvI3U+ej/ouOmAbU2hnj+vwz/bCKBR1/nhk\
            BTfQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp\
            7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAy\
            phowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKIETI/00cJaVYMvn6LW6raBsOax5fVBBqBJBduevqeE4/GiIKIHh3lBH/eTSW5rSO\
            Br3I4ACORDvLvuk/YqcpHZUdiT5AIlYKVETf+pMzf4nx9BEAJv7CxO1i409XFpu5EBd7\
            ui0YXjG3YaVoHo2pLf97wDcLGP6GDv24x+Zn2Di4zqzB8s3+S0bRKqY/X3dB3dLCxR3z\
            KdSHax0BACpECkL9J45aC2RC8osjSjZXGAfHZ2B8Pj8LotPg80/PbLRK6gfcpxSgCTfS\
            p5R8fHeMaDzxRWEDTJu9fX+NnELoP6f5soYyNwoiCiCQl89bcW2Da5glYVhYQpOqBC3A\
            YR42udF69dfBYmmcKBEQ8akPknmTiBoIMIQJXhS3gRc=
            """,
            """
            CLPclAIQ14/JAxowCgoIs9yUAhCz3JQCEiIKIE8N7+j149YVcTJiRZ+r0RIEQaQmihDt\
            E65uhjxcie7uGjAKCgiy3JQCELLclAISIgog1x3mQC2O3hDIegdfTmaVc5Gl+0HC3CmG\
            i9OO6D+KYD0aMAoKCLDclAIQsdyUAhIiCiD1W0uBuqcws+ILzv1yJH2bTBDmyD54wXyC\
            lwkHQqIKdxowCgoItNyUAhC33JQCEiIKIPx2bxDpXNiQnCk7aRABjErAoYxBk7ll3e+4\
            r5kX7k7NGjAKCgi43JQCEL/clAISIgogt9pR7XguK2AmkuH8dfAahHvZwC1FOpAAQq8m\
            /ymIIbwaMAoKCKDclAIQr9yUAhIiCiAV8/6bGofq3Z0OpMTnOBkWGqsPa4PRKA0Oxg6Y\
            s+TGahowCgoIgNyUAhCf3JQCEiIKIJL38h3bULz8rl8WtOWcoNCAEJI6QdXiaegG+7bt\
            iybgGjAKCgjA3JQCEP/clAISIgogid4dV7iW9EuJlxGSuXTnagmXXpoH7ACvXRCADeSA\
            p74aMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32z\
            iRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKIL47vu7Ezlrh2F5AmYGzKOsTfjtcSEopeYUCUxe9d9suGiIKIHozoFIibeRDldcZ\
            6ewRMkruudPm2BJi3eKvQQKjdgJgIlYKVC24C09kZLx7kk32P29OtpgSlO2YV1L+90X6\
            f9NQJmXUwdU2FUMoR6/Y4/fNZhki3paH8sS3iqj0yCkqVEM1Y0rsCJSVTptSn9MuxnD/\
            XWBQEEEBACpECkKAmoIN/r6Bz8QOFjBdxpbOAVaeNhdvEq8gE7DtUMt4IYcyiOz/4i/m\
            RUAvf3wy8VKTo2X6eA42F46L/hPPyH4Wdy4yNwoiCiA6pYCWt4b7FvkZWXcF0TckZMjq\
            gHUH0tMPFd515bMoKRFgmleeD2AFJRoIXmJtPeSa7iw=
            """,
            """
            CJHclAIQ14/JAxowCgoIkdyUAhCR3JQCEiIKIJxFoNgPayDPPGx+5vvaIrne82BsAtMD\
            gxKRw+j/tpboGjAKCgiQ3JQCEJDclAISIgogNlSZzRU222WyawzqvutUnh96C0eyezAV\
            fXxrdl3oV2IaMAoKCJLclAIQk9yUAhIiCiBxc/+FGxpEUNrJDoFOhAEWEaUzsojAbuzU\
            oLxqYAJxVRowCgoIlNyUAhCX3JQCEiIKIAW4z0P+PDcYEbEmciI3wLDHqslQhrB5TKFq\
            Sfymkv6PGjAKCgiY3JQCEJ/clAISIgogNhxbJrdYd24Pf3G8l0pRTx54748ZJ5CeOSh8\
            AOTu9o0aMAoKCIDclAIQj9yUAhIiCiBFycLwJTbspsfssTivCk7kCGrA6Mr7jsWZ4u09\
            QmS5pBowCgoIoNyUAhC/3JQCEiIKIMWOOrJ6cYMtUf7GPZFC5u0suBa8uXbzcsyI3iXG\
            IDvXGjAKCgjA3JQCEP/clAISIgogid4dV7iW9EuJlxGSuXTnagmXXpoH7ACvXRCADeSA\
            p74aMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32z\
            iRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKID7zJYODGcFfTqpKgfdeK7/iRSROJu5ajjCTOTkEPKJSGiIKILQPKM8g4EWltlgr\
            0XteyDasQkTtdwYv+2uH+ZoIQ4cQIlYKVHz3gFIUeM02FA5PRGFDdiVIyb3KryY9RRMt\
            KdUKrK4evxlG/EoqNbqDNw67+uZmJdpGSV5NEEtDBzC5+ay047koahnlGOo3NEdNO431\
            ui6eiRABACpECkJP2O6I12TTzcH5OZo5YAcFkB7ufVfnXs7mWfNlekLMyQs3vmZ75RNY\
            oH6jgaK8OWe4czhCqvoT6lgLjOwXbfOto9MyNwoiCiDa19NkQDcJl2nmNrz/FSM/Ttno\
            GfUqn1lZSnDZeBzJShFfd+cX7bWrzRoIGhQKdaGYJQE=
            """,
            """
            CKTdlAIQ14/JAxowCgoIpN2UAhCk3ZQCEiIKILPcc1heNyPbyys8hc6rGZ3b/mV3/pce\
            PxIBQU8dBUZyGjAKCgil3ZQCEKXdlAISIgogIIowzVKoq22e3hULi1VPceo8J5nu/jI7\
            qnQsYrrVCcsaMAoKCKbdlAIQp92UAhIiCiBm1Uu8BA3w3LWaLsT7IdvVog8htls17L9F\
            IOp5Hjbj3RowCgoIoN2UAhCj3ZQCEiIKID2wLKcnKirh20Th2+j/oLNgD6oVv+ziqaqK\
            b+qjXNbcGjAKCgio3ZQCEK/dlAISIgogpncMnZCW+CwxdbFeHffdxqRQEPfWX8o2lBbh\
            AKLH8ncaMAoKCLDdlAIQv92UAhIiCiBbyjsB1YrqaxzP47F4mQP2X40T/fcIsFgU+COf\
            QIaa9xowCgoIgN2UAhCf3ZQCEiIKIDGc83EOoCbkDpZdqP7Gc9M2hKR04PZGH+l+/8Xl\
            6DkQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp\
            7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAy\
            phowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKIMKlXvE3K1p9pve1gM2rJHzyJvusTp3DcQuYw7QK1Rd3GiIKINiBQtU9lixXTniM\
            TgWkux+P3hUE6aY2nMd3v39OAsM3IlYKVHWD8AI+vBGdP+VbKzLPZpc7AcK64E/JE/Nm\
            PJpowkDMyCuO1861/pDEw55TfXsj7/aB3oNIQdw3wuEOmuC2SUriDKDCiJK+ClgdNJCj\
            4nfjnucBACpECkLkMI6i9HXhLq3dN12gF47L7ajO8XWIUJPMf/hLIorHt0E9mX6C0SEO\
            0ok1ouTru4QEG04CPf9wV9nT5Cz2SG72GtkyNwoiCiD0NHGtRrGncsbsEPxTh7z3aWTs\
            KxuDgqCLZxQgNeLBbhEww7nzHg1M7xoItltPe+s50U8=
            """,
            """
            CKHdlAIQ14/JAxowCgoIod2UAhCh3ZQCEiIKIFS4/5cL4tGM8kjqdsZWJiEQMju8DkDc\
            sWfOyf0BTCq5GjAKCgig3ZQCEKDdlAISIgogvy1GklhwfRZ307EHJ/HXQO5f2xiNZ2Pv\
            hi0yEuQPT0EaMAoKCKLdlAIQo92UAhIiCiAEqzFcrc5ZpA9l3tQ+FEV1n1mPqzrNBMv0\
            DgGv8gKoQBowCgoIpN2UAhCn3ZQCEiIKID8zdv7ND0o/Gpy3+81sPR0ODSfSzlwjUOZI\
            wwqvC4ccGjAKCgio3ZQCEK/dlAISIgogpncMnZCW+CwxdbFeHffdxqRQEPfWX8o2lBbh\
            AKLH8ncaMAoKCLDdlAIQv92UAhIiCiBbyjsB1YrqaxzP47F4mQP2X40T/fcIsFgU+COf\
            QIaa9xowCgoIgN2UAhCf3ZQCEiIKIDGc83EOoCbkDpZdqP7Gc9M2hKR04PZGH+l+/8Xl\
            6DkQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp\
            7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAy\
            phowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),
        ].map {
            (
                try XCTUnwrap(TxOut(serializedData: XCTUnwrap(Data(base64Encoded: $0.0)))),
                try XCTUnwrapSuccess(
                    TxOutMembershipProof.make(serializedData: XCTUnwrap(Data(base64Encoded: $0.1))))
            )
        }

        let encryptedMemo2 =
            """
            /hpC0EFCnzx2WLLSORctFy/a15YkNAZv04NFU9EJZuhdJI+CtfZDcAEz+6tPtpb45THn\
            T1rydm48sjsdmhd1Q2xQ
            """

        let accountKey2B64 =
            """
            CiIKIMM0eFjAenKpb/qWCpMpLBobETadGuaJCNy45N0Ej7sPEiIKIEU+8R66uCyb7xsV\
            bX9qAPUa6cTxIpeQNIEQFoPbWFUKGh1mb2c6Ly9mb2cudGVzdC5tb2JpbGVjb2luLmNv\
            bSqmBDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL5wfcE20zk+bqIs0WGm\
            G8O1yBJCJ5fBOzBjgEI/sZwvhdayF4gp3P7dfuSCFo20RoVs6O0QMCObEWo59rE+K0Z/\
            TV2zs2TLyKhOIZoZhM8tWEDQ53wCwFjUPlgW2BlvlaptyJULwBRY1TdWGCHWIWy4wD3Z\
            IHlbFn3Cw36Kx5+q0d0AWWGSJUgUEikTGP7csE8Xkwryts1nEtJG2xT7QXFbYe1RRVTw\
            GV4T4vcstQL55XTup+yi4rqVZqI5RDLb+BUJJOtOJ2pfo/3TqZUwE1fGvQCQWz0QWf8k\
            IOexBtmNjEYhzkInycdEuVWzcjJvW5EvEw+xqIufWglujk9YMnqLVsC4OtCUWU38ie5W\
            FgUjs4dDp2gsrUaUlrTWem2qz1Hjp37W5ybRPKxYRezOBeunrdCyP3Lr12HnMFcMpKLx\
            FQSkReBzivRoEpte5kDLc6w+3OefE22rnDlmm2EdOLoXQHN7NdDJLjjVhtMCEIYCAoWF\
            QBpxS70qadv2kBKt8a0UhE8bIsVCI7GcllkTpLgNCBZ3PHewJnJ1Ab0VuxU/+bYVspOW\
            oHWFBmfuwtaOvYoUdWMZqBoevXyzDyBDoWIee9vt3JIJdkmleLqPRr5M/DDBkQXDCDJU\
            Yq0sIQn6M1dkck+Vp9TYD6cnPMyS+0HToS+0MW/uVo5wla0GByNnAgMBAAE=
            """

        let knownTxOut_2 = try XCTUnwrap(KnownTxOut(
            LedgerTxOut(
                PartialTxOut(
                    encryptedMemo: Data66(base64Encoded: encryptedMemo2)!,
                    maskedAmount: MaskedAmount(
                        maskedValue: 11011028853111894764,
                        maskedTokenId: Data(base64Encoded: "8E2s/zEhK4w=")!,
                        commitment: Data32(base64Encoded:
                            "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=")!,
                        version: .v2),
                    targetKey: RistrettoPublic(base64Encoded:
                        "ND4wz0VuSGPWjYUWxhsdy11IaZJIiangAOaIGH/em00=")!,
                    publicKey: RistrettoPublic(base64Encoded:
                        "mjCqnh4DbYPVLkWqEAyVHH16WHpK1E8tTyxEPyDe728=")!),
                globalIndex: 4533909,
                block: BlockMetadata(
                    index: 1493080,
                    timestampStatus: .known(
                        timestamp: Date(timeIntervalSince1970: 1677540712.0)))),
            accountKey: try XCTUnwrap(
                AccountKey(serializedData: Data(base64Encoded: accountKey2B64)!))))

        let ring_2: [(TxOut, TxOutMembershipProof)] = try [
            (
            """
            EiIKIG6Diemoz8w4HSoMJO2nITieRsd65eVoCklt608ipJ0qGiIKIAbdrFjSBsV7c661\
            YLjMQqaehC3yvPsyrC7qFzgHTl4cIlYKVBke2SVfiLLliD3XET1cuWQ3Mewn0DTl/lj6\
            xWCZu+4etFVIFSzn7jWB+5O+9Cs6zFQiPfblwW+uHR+y6vhonqb5fynvUX3aMJWQWk6Z\
            oPAqZvUBACpECkJRBTJpLPF1qsJfmREzHOp5V+ucRiGR0BhYQhQsGUfP/ZW4UWhZgZQr\
            +Geve3Ue5HM/qpYcsvtyTxAUU2pUgnBbHIkyNwoiCiCQKrFSB3SGVsjqDp/gnI6CNzvN\
            vgiROEZAOBEJlFXafhFrzFnE4GDA+RoIrCdJzHbFr5k=
            """,
            """
            CKXclAIQ14/JAxowCgoIpdyUAhCl3JQCEiIKIPK9IH5gg7MjOMgsktPT5yt9BnH608Rc\
            kmtHmV1zgYiPGjAKCgik3JQCEKTclAISIgogRcEpIWA56oybt8WRWAOz4gRDNUCMIrb+\
            cYupIku3jLIaMAoKCKbclAIQp9yUAhIiCiA2O6i330WZXJ6WqNPmHLNUe23HOeC62YmF\
            rZJwoyFogBowCgoIoNyUAhCj3JQCEiIKIDgZem2yTBHllizy6MbBmDiq+CAizxxYN1Mo\
            MGs8KWf8GjAKCgio3JQCEK/clAISIgogcgLOlo9pM8wo7rExjomvH0gQA3mwwOb2vKfE\
            dmHzbOQaMAoKCLDclAIQv9yUAhIiCiBTiFa2+tAcA/CiV9A/okVBwMa49sZJ//JLALhP\
            JpGwHBowCgoIgNyUAhCf3JQCEiIKIJL38h3bULz8rl8WtOWcoNCAEJI6QdXiaegG+7bt\
            iybgGjAKCgjA3JQCEP/clAISIgogid4dV7iW9EuJlxGSuXTnagmXXpoH7ACvXRCADeSA\
            p74aMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32z\
            iRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKIKoitR9JT0jlgeG57AojzQFPU8fep5FdMgdY2Lxl5SU4GiIKIAxi2cIZD5x4CQUn\
            +FDAbP8GbIytGCDxNcyQ+3RtZFdwIlYKVMYQGrhv3XLeci2kQjn8ea6fwrC0CBrdD0Bx\
            47kyzBmpa0yAimYD/w/Zrqu2H/ts1GeMOgaNMQpCQW/EdO8FIDYtGE/AKPyT+Rrm4jaZ\
            WJVtL+ABACpECkLBfs6TS/z9dB0T9rSLVWGUPu0/ZHW2SpSfFbjbyfy/PNq9XbmY2KZ9\
            pfua/9IuDqtdzwgZkNtv0bTg3aw8DsytjscyNwoiCiDobIMUoSNvORzJXNxFLxqpDXqu\
            6Mn0juhW3CDca5zcZRFslOvOAh4xFRoI1Jlx/Z5CYZs=
            """,
            """
            CPbclAIQ14/JAxowCgoI9tyUAhD23JQCEiIKIADUuBAgDZDN9BWmVN+v6xwTHHzw2THu\
            yJig+ky3tC4UGjAKCgj33JQCEPfclAISIgogK5HEoLRYLfcZYSdu8O84pm3aKkeOd+2q\
            DHHtm271AUAaMAoKCPTclAIQ9dyUAhIiCiDcWFQM+U3aFNIBqipbComNjvSNY4QvE2GY\
            /bpl07oN9xowCgoI8NyUAhDz3JQCEiIKIMfqwRcbrSB9ObvJ6Hc6G9SHbzPZF8gfOiVr\
            ptRWWTU1GjAKCgj43JQCEP/clAISIgogxPHyEeB1KpZ7lGBG6dns8h0t8b63grD4NisD\
            VdlChrUaMAoKCODclAIQ79yUAhIiCiABXwDLrCE6aF/x7MFAvrQX+fpjQO2gmR3SNfDL\
            TZTowxowCgoIwNyUAhDf3JQCEiIKIHRuI8xC+qYgDWW2tvXZYbqSi3Z5u1PEQ+4JlUZO\
            09kwGjAKCgiA3JQCEL/clAISIgogr3Z7tfLq6a5kZQ8a9Qbtke9192uT6HXwYKAkPVxc\
            tjEaMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32z\
            iRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKIABSVbapXFT+EAlxQi2EsMkAqfIgv3Ztc14GATmt9LlsGiIKIGS4ayV04+sTvfn5\
            BeLKOyvGEUtEkqmFHN54BXg8U71iIlYKVI1hKbJMCdbVp9wquHo9i4Y00hvbxQMFv5B+\
            kDcJZhB+80pEHIgSybvjadCCjf3462YZlpcBiq8e5aBIimmAlDovegugcHyweyO3HiaA\
            lzHq1xcBACpECkJFGBMAOfv/gFt2ebnQMoLUtfbZW41jab5njb2F9Z+EusfN+Jmcv6tR\
            SjeslYzbAAYChU17xaij34Xntlxvk1yH/I0yNwoiCiA8LZdfiWHAlKDx1ffQMX+no2JZ\
            TZgdMML1Af0eGkczWhEMgxDhF5nsAxoIwt9i0LrhymY=
            """,
            """
            CLHclAIQ14/JAxowCgoIsdyUAhCx3JQCEiIKILMNYcjigywKIkzGj8ba/3rYAR6F1BOV\
            xkCx5YOCJtJuGjAKCgiw3JQCELDclAISIgog8XY4hFAWs+565h10ux7CgTnLeKHCdzkg\
            BOZ3W8aPgYwaMAoKCLLclAIQs9yUAhIiCiBnJyjxjlk+EJOlTGGPDfC0V2Oukg89uGI5\
            0G4ailFtoBowCgoItNyUAhC33JQCEiIKIPx2bxDpXNiQnCk7aRABjErAoYxBk7ll3e+4\
            r5kX7k7NGjAKCgi43JQCEL/clAISIgogt9pR7XguK2AmkuH8dfAahHvZwC1FOpAAQq8m\
            /ymIIbwaMAoKCKDclAIQr9yUAhIiCiAV8/6bGofq3Z0OpMTnOBkWGqsPa4PRKA0Oxg6Y\
            s+TGahowCgoIgNyUAhCf3JQCEiIKIJL38h3bULz8rl8WtOWcoNCAEJI6QdXiaegG+7bt\
            iybgGjAKCgjA3JQCEP/clAISIgogid4dV7iW9EuJlxGSuXTnagmXXpoH7ACvXRCADeSA\
            p74aMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32z\
            iRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKIBj+tM6rDm2arrFwq43AejAFMWZwLihYl06Rm0589uQgGiIKIIBIKQvBLIfiKvi7\
            0rniiUq6ofVAe2czZcLNiC2CpO9GIlYKVMx2R9XhyiTgSiVZCe7D+Yk81TQYhW5SlwWf\
            guSik+LLYKnAAdFZ0971ngD2Ajf2MbZY2r2q5F9yeJUSqA8kyE7ZU8DUznLORAm1NoBW\
            9YKnZQABACpECkKit8L70OsDGVx+/6fryVjAl5KYQu3JM5+K6tZ+f4lzIhE4oee+CRkK\
            pLEiCaHbmSskB2z60PqquuoyyIHVrOVNV1YyNwoiCiCYK3h575z52pyU51SMVkvC9l4w\
            3vQtgeW56TvviovhYBGwoiGglCerpRoIyg/dW2jbbLI=
            """,
            """
            CPTclAIQ14/JAxowCgoI9NyUAhD03JQCEiIKIKSgZ9rKSmLSGo3lmOj26fXcs0HFH5a4\
            zKc82ozo0MUSGjAKCgj13JQCEPXclAISIgog+F5iKk8uDsv6JCJasXYlX5UHS7OA0DAo\
            pPni+t06VZoaMAoKCPbclAIQ99yUAhIiCiCl3UMUBQ+istOSaluJ8LpZ5pd1qDymE8Gv\
            +SqewY/+mxowCgoI8NyUAhDz3JQCEiIKIMfqwRcbrSB9ObvJ6Hc6G9SHbzPZF8gfOiVr\
            ptRWWTU1GjAKCgj43JQCEP/clAISIgogxPHyEeB1KpZ7lGBG6dns8h0t8b63grD4NisD\
            VdlChrUaMAoKCODclAIQ79yUAhIiCiABXwDLrCE6aF/x7MFAvrQX+fpjQO2gmR3SNfDL\
            TZTowxowCgoIwNyUAhDf3JQCEiIKIHRuI8xC+qYgDWW2tvXZYbqSi3Z5u1PEQ+4JlUZO\
            09kwGjAKCgiA3JQCEL/clAISIgogr3Z7tfLq6a5kZQ8a9Qbtke9192uT6HXwYKAkPVxc\
            tjEaMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32z\
            iRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKIDQ+MM9Fbkhj1o2FFsYbHctdSGmSSImp4ADmiBh/3ptNGiIKIJowqp4eA22D1S5F\
            qhAMlRx9elh6StRPLU8sRD8g3u9vIlYKVO9lsvCG3yXbPlpeDNiZYICASkPp27vpRgeb\
            J7QeoTSwM/biSBBUiqADVMl2JksYZ8vdjUVHd3UUKJzlwXcfBuE5O/m9NuUd3OG5cjiy\
            h25K+j8BACpECkL+GkLQQUKfPHZYstI5Fy0XL9rXliQ0Bm/Tg0VT0Qlm6F0kj4K19kNw\
            ATP7q0+2lvjlMedPWvJ2bjyyOx2aF3VDbFAyNwoiCiD6iC1NNTYS+jBRjjwx5X1Ng837\
            FFbRqbGggDemC9iNKRHssk8pZwjPmBoI8E2s/zEhK4w=
            """,
            """
            CJXdlAIQ14/JAxowCgoIld2UAhCV3ZQCEiIKIOzOJLxQBfUajrDUO4B9HBXZZFkdLtd1\
            kdrfhhkaa4SGGjAKCgiU3ZQCEJTdlAISIgogbuDrViLKxpN965NFF4x8/8AC57v40557\
            XLCM/orAf8YaMAoKCJbdlAIQl92UAhIiCiAYYMCCvyQZdI2ApjpGUThaVuuHvtm7P9Er\
            dOKQEfC68BowCgoIkN2UAhCT3ZQCEiIKIC9AeEEReXg44I2do2rQpvm5L/B/PCY0fQyd\
            N3IptInoGjAKCgiY3ZQCEJ/dlAISIgogSfoptOxb1J3TdKqNiF8M5bJSE4ilbKTtsvT0\
            0NuupeMaMAoKCIDdlAIQj92UAhIiCiAiips/UPOfwvvu9EV5mFWZlIyoQvAlvIMgGLqi\
            c4sRQRowCgoIoN2UAhC/3ZQCEiIKIK4PwbvI3U+ej/ouOmAbU2hnj+vwz/bCKBR1/nhk\
            BTfQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp\
            7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAy\
            phowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKIIZarv+FjMetf0UydxrqpoxHigS0TdPB7iME9080w11xGiIKIJ75jlQlzdooQCzY\
            sNp5EVaKS5SfdcsY+xHpxHK/cz5cIlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
            AAAAAAAAACpECkJGUNbqH3p9IJbZMXvgz3gv5AfJO298LET45wIvv4kd+YFh4fbbAvQ9\
            BTN1tZfJiRW/OlsGzlLmzwISENNo8D+1b/0yNwoiCiACU4fQPnaCCjOluqEk+khDtE7b\
            sdSfTpE9fty1SkNLPxGHxJOWKA4xvhoIzjLY0XWaML4=
            """,
            """
            COfclAIQ14/JAxowCgoI59yUAhDn3JQCEiIKIAsvdhl5QXrP2/bDSnBcWY6RoJxLAZgQ\
            MOonn3kZTNMRGjAKCgjm3JQCEObclAISIgogK4Mcj1ZtcXx53ibLK33U8CstjBfzCYrv\
            9pAwM20oB8MaMAoKCOTclAIQ5dyUAhIiCiBluff4LUO5NLNp9WGTwG6zNL3tJNLMU6OS\
            UE6eYQtlwhowCgoI4NyUAhDj3JQCEiIKIOx5kWjpIeSRdIjhZjmK0CuRlg0E3MUW4FiO\
            2hhFWpdVGjAKCgjo3JQCEO/clAISIgog1WwYGvxg/rpEfExG9Br8KhVyCanmF2wDRha2\
            aMa9NSIaMAoKCPDclAIQ/9yUAhIiCiC740M2yUqHjGay/SPe55WpDG3L/uzFJ3gKF8pd\
            eh9JMxowCgoIwNyUAhDf3JQCEiIKIHRuI8xC+qYgDWW2tvXZYbqSi3Z5u1PEQ+4JlUZO\
            09kwGjAKCgiA3JQCEL/clAISIgogr3Z7tfLq6a5kZQ8a9Qbtke9192uT6HXwYKAkPVxc\
            tjEaMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32z\
            iRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKIGrkOP3QxEPGkiaz9CWUp4yH3yFEq47DdJI+IYKnEQ9FGiIKILC0lSBPhljGmHOP\
            g5Qt9rL48R51bLrJDOrjXgTjcDpFIlYKVH9QugtdzoNIs+9SqH9Huum+n0lP0h4qEDtO\
            Xou0Al7qY/ok/82IOuWpNKhCiXTxouHWSisKXBHImE3Ag5GM/EFtbdhEIdpzwfKSPqSD\
            SKubQ18BACpECkJKMGTCLD41Y3Q+sHKDaXSIjayclXjOUZtvx5mwyaHqYLyN4R9AB7si\
            fpEFtvVtlRl2yn9Frl4Mc6GpkKYqwDXAg0YyNwoiCiB4BxuYfUEpdbkX6dPTXV3UnOqq\
            gPkyhsUeW8K9yQtBChHP2QO2oQ5IrRoI38Z66Og7F8g=
            """,
            """
            CKzdlAIQ14/JAxowCgoIrN2UAhCs3ZQCEiIKIEDpOT2+THTEtqQY4ZlCOm8e8H+kGgf3\
            9gUUtU/4VKdnGjAKCgit3ZQCEK3dlAISIgogik6yiI0DrIEFR1LIeYU4PiqCuebIrazT\
            3jZyBo+9Y7AaMAoKCK7dlAIQr92UAhIiCiD771G9zwC9zEdKG02f4hjTVvP7X7Lk3uk2\
            7i21hgkSxBowCgoIqN2UAhCr3ZQCEiIKIPNdZl6QU2jMkSWkyhhXHoKWCk//TqmNC1lA\
            LiAE7RbzGjAKCgig3ZQCEKfdlAISIgogwDt1jrEfGV0+WM160VzXkw8DaAhfo75yzvF3\
            Nzl43P4aMAoKCLDdlAIQv92UAhIiCiBbyjsB1YrqaxzP47F4mQP2X40T/fcIsFgU+COf\
            QIaa9xowCgoIgN2UAhCf3ZQCEiIKIDGc83EOoCbkDpZdqP7Gc9M2hKR04PZGH+l+/8Xl\
            6DkQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp\
            7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAy\
            phowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKIE6ntSgTV45YjsweeP2tjxyDS0E2Fq3jgWy0D6ok24wqGiIKILIGPNkYfFenXxVK\
            ZikOYn0++maO6jLVxBdebklyyDpLIlYKVLfP7guTX3AtkgM31ANBpO0N7uckvnlFSVro\
            zTmdwH+cVF36JinGWr97ZBkz+seHx8YEfNjQYqq2LDIU2NYPbwMxCQg3PWyr+jaEMXEb\
            UiDIjRkBACpECkJBRquA4A5eV50s12Ioaq4CtLTmxn2v+hajhomyYX7vYPB5TU7LSRF0\
            xoBmmdxOf4LmiwMK6m2RRloUR71VUXF0vDYyNwoiCiB8e7nIL+4YzhCwdg+fpYJp1aQ4\
            w/5+UGLbO29/JzwsaBFjt8+0HAeIvhoI4096oiz4WVo=
            """,
            """
            CO7clAIQ14/JAxowCgoI7tyUAhDu3JQCEiIKIGxUce7Rs1UoXRL5hYIKIid6fMySnyVE\
            clHQc8AA++smGjAKCgjv3JQCEO/clAISIgog5WpLtBFSVxbcOFhM/jhyjpfUhpbMzbcW\
            RFt3gLkqIIoaMAoKCOzclAIQ7dyUAhIiCiBazHqZgMM1/0efWGSrIr8XSY3QOqZagusE\
            oAQxgYJHMBowCgoI6NyUAhDr3JQCEiIKIKoHzUjR+bdQ6pH5k+alNGp1x5zkUQpVZewb\
            FOivNA+BGjAKCgjg3JQCEOfclAISIgogZRuNIskb4vBIuTCMXISSHz0ZK9mrQAWpqkH0\
            O/p/3ncaMAoKCPDclAIQ/9yUAhIiCiC740M2yUqHjGay/SPe55WpDG3L/uzFJ3gKF8pd\
            eh9JMxowCgoIwNyUAhDf3JQCEiIKIHRuI8xC+qYgDWW2tvXZYbqSi3Z5u1PEQ+4JlUZO\
            09kwGjAKCgiA3JQCEL/clAISIgogr3Z7tfLq6a5kZQ8a9Qbtke9192uT6HXwYKAkPVxc\
            tjEaMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32z\
            iRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKIIzkd5BsevvnlyWtNTwu7eA2pvy06s3f2WVaSpaHoRwSGiIKILTlImGXdwIIMAq8\
            1I8HHASb8kAzTt6OpeL6+0fubqsOIlYKVNEHAl2HN7qcikrkIfmy7Fkjq5IfN1qBSd7e\
            tkC6XDv43AJYxnZ51gUVaVXSey8uLTiWyjFEzhXRd+vHRowjNrYSekk6IrKFpT2HikhO\
            dVUniK0BACpECkKec05KgQaboTZT3fcOGnr0Uke0HN1i24KcU+ZehfnDghiGOK3O1+iR\
            S8UCrZydbHvDprOo4IyhshBKeivDrQegAKkyNwoiCiDk4JbkHdSzCYR/DreIk+mQtKZH\
            vOk7mWQjzEm5CBCSLBHM/ZF506pBxxoIQzglyNQ9oVo=
            """,
            """
            CKrdlAIQ14/JAxowCgoIqt2UAhCq3ZQCEiIKII/o2iar5A0H1KBIQ3T8K2A4Wob8hHpv\
            hjcT6nD1zn3nGjAKCgir3ZQCEKvdlAISIgog485acEEo9l+dwMXKk3LdHhEHVoLiza7O\
            mPusn5zCUogaMAoKCKjdlAIQqd2UAhIiCiC3VJWfzxvIWPHTOnR3fDJ1Spk1avhwfYSG\
            0hkJ0T615xowCgoIrN2UAhCv3ZQCEiIKICOHIgCAP1ma8dybYuwSlTifQwOGV4J0+Can\
            rCP4AydGGjAKCgig3ZQCEKfdlAISIgogwDt1jrEfGV0+WM160VzXkw8DaAhfo75yzvF3\
            Nzl43P4aMAoKCLDdlAIQv92UAhIiCiBbyjsB1YrqaxzP47F4mQP2X40T/fcIsFgU+COf\
            QIaa9xowCgoIgN2UAhCf3ZQCEiIKIDGc83EOoCbkDpZdqP7Gc9M2hKR04PZGH+l+/8Xl\
            6DkQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp\
            7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAy\
            phowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKIH4HYq/yZRBYR9iiSmJ4feEJN88ZzYYQmSvw2exlWlJwGiIKINTN9leuCLfaJPfv\
            y7EslA1ul59ovrQThJyOj5d6XkMTIlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
            AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\
            AAAAAAAAACpECkIUxx1nkTtLtscQo+8kxTh0Ov4CEQ57Vs/8ot2lUOiFGgf02yUebk8G\
            Vfg0wl7ojYhJNIV1AOLpIscEj0Yk4L0+QcIyNwoiCiA0/TWfUPKOPyaqNCXyCQ7/3ajH\
            7vFkCQAnmC0hKbZwIxF4zmkO1caophoIIepCSQMdr9o=
            """,
            """
            CNPclAIQ14/JAxowCgoI09yUAhDT3JQCEiIKIBNuEygrsVhHrpSx6sEJ11b5nukXC+T8\
            8rrLzvTY8vg8GjAKCgjS3JQCENLclAISIgogoeW+Xx6p3tZ9JfgI16249Vnnc/Uputda\
            CACkrov2CLUaMAoKCNDclAIQ0dyUAhIiCiBmGFkhrLNvgeGdfn3Aj6b8DYKeB03pvXKi\
            yB9WN7O8VxowCgoI1NyUAhDX3JQCEiIKILt9xhySoY0U/rjcav5YfOZoNEtO1M61fJK5\
            My1E5swWGjAKCgjY3JQCEN/clAISIgog/KpgCFKD1f5tPXX/giIX11oULb4w6RMsZKQG\
            Y++qhAkaMAoKCMDclAIQz9yUAhIiCiCTjavBee+eRRfeTRUZmnO8iPLPAViSbeqhUJsA\
            R+GEIxowCgoI4NyUAhD/3JQCEiIKIDXYv597nUABiIoj10DFLze7C7L4GA9DdMm8h0EI\
            yvwrGjAKCgiA3JQCEL/clAISIgogr3Z7tfLq6a5kZQ8a9Qbtke9192uT6HXwYKAkPVxc\
            tjEaMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32z\
            iRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),

            (
            """
            EiIKINJiIojyX64qfR1LANvkzTa4RW+021vHp3FwfygYZdQ7GiIKIObHVZcpyvwvaMsc\
            bpm6S3R7ungIL+91T7mqIPR2Yow8IlYKVEmmwBFLQ6aKBffAHbkAWL3z89JRSb3ntwhI\
            RXI8Bx1D5jDiWyMgoHj9tkZ4Gt/fLuGVp6YvP2qejZN5HgnKYyD0HMd9wqJrceTsC9bq\
            FflbqEABACpECkITj/Xsqev3arv513sqtR5rqJR4TvPPUoV7jhly9cNQNsnKp380OavB\
            snsGxHw5hJkrGtcgRHhMt1zqi53/RD7ICr8yNwoiCiC2RBg86tpDYTOGbOE/V7oXo0GW\
            JA/PcCUM6vfVpqKRPBFHkTTGMcfkLxoI1MZUxQpkb0I=
            """,
            """
            CL/clAIQ14/JAxowCgoIv9yUAhC/3JQCEiIKIB/bTC4mQzdaWUwrBJVC78YZjqs7124N\
            O5rHlwCnuM4OGjAKCgi+3JQCEL7clAISIgog4oU0ZLUh9THG/3EcMfS5RlJAYctHxJst\
            cPtkNjeuGbwaMAoKCLzclAIQvdyUAhIiCiDkkSboYFPHh1Gg7ZyfifCscyU02VAj8Aev\
            BdykTiVoBxowCgoIuNyUAhC73JQCEiIKINrriD9yTKKhUP8EaJ7azajeadWewTSe4JAh\
            62SwyFClGjAKCgiw3JQCELfclAISIgogXfzVLEYCCAKv3msg2UFKTzAdYEWHO5t5Y90s\
            RxdQz4gaMAoKCKDclAIQr9yUAhIiCiAV8/6bGofq3Z0OpMTnOBkWGqsPa4PRKA0Oxg6Y\
            s+TGahowCgoIgNyUAhCf3JQCEiIKIJL38h3bULz8rl8WtOWcoNCAEJI6QdXiaegG+7bt\
            iybgGjAKCgjA3JQCEP/clAISIgogid4dV7iW9EuJlxGSuXTnagmXXpoH7ACvXRCADeSA\
            p74aMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32z\
            iRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9n\
            GjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQa\
            MAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRow\
            CgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAK\
            CgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoK\
            CICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoI\
            gICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiA\
            gJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICA\
            kAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICY\
            AhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIAC\
            EP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ\
            //+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD/\
            //8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP//\
            /wMSIgogrMzpmpE78e1byPLkQO5Fwx5intgbXf5t9iDReu90wc4aKwoFEP///wESIgog\
            5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
            """
            ),
        ].map {
            (
                try XCTUnwrap(TxOut(serializedData: XCTUnwrap(Data(base64Encoded: $0.0)))),
                try XCTUnwrapSuccess(
                    TxOutMembershipProof.make(serializedData: XCTUnwrap(Data(base64Encoded: $0.1))))
            )
        }

        return [
            try PreparedTxInput.make(knownTxOut: knownTxOut_1, ring: ring_1).get(),
            try PreparedTxInput.make(knownTxOut: knownTxOut_2, ring: ring_2).get(),
        ]
    }

    fileprivate static func accountKey() throws -> AccountKey {
        let rootAccountKeyB64 =
            """
            CiIKIMM0eFjAenKpb/qWCpMpLBobETadGuaJCNy45N0Ej7sPEiIKIEU+8R66uCyb7xsV\
            bX9qAPUa6cTxIpeQNIEQFoPbWFUKGh1mb2c6Ly9mb2cudGVzdC5tb2JpbGVjb2luLmNv\
            bSqmBDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL5wfcE20zk+bqIs0WGm\
            G8O1yBJCJ5fBOzBjgEI/sZwvhdayF4gp3P7dfuSCFo20RoVs6O0QMCObEWo59rE+K0Z/\
            TV2zs2TLyKhOIZoZhM8tWEDQ53wCwFjUPlgW2BlvlaptyJULwBRY1TdWGCHWIWy4wD3Z\
            IHlbFn3Cw36Kx5+q0d0AWWGSJUgUEikTGP7csE8Xkwryts1nEtJG2xT7QXFbYe1RRVTw\
            GV4T4vcstQL55XTup+yi4rqVZqI5RDLb+BUJJOtOJ2pfo/3TqZUwE1fGvQCQWz0QWf8k\
            IOexBtmNjEYhzkInycdEuVWzcjJvW5EvEw+xqIufWglujk9YMnqLVsC4OtCUWU38ie5W\
            FgUjs4dDp2gsrUaUlrTWem2qz1Hjp37W5ybRPKxYRezOBeunrdCyP3Lr12HnMFcMpKLx\
            FQSkReBzivRoEpte5kDLc6w+3OefE22rnDlmm2EdOLoXQHN7NdDJLjjVhtMCEIYCAoWF\
            QBpxS70qadv2kBKt8a0UhE8bIsVCI7GcllkTpLgNCBZ3PHewJnJ1Ab0VuxU/+bYVspOW\
            oHWFBmfuwtaOvYoUdWMZqBoevXyzDyBDoWIee9vt3JIJdkmleLqPRr5M/DDBkQXDCDJU\
            Yq0sIQn6M1dkck+Vp9TYD6cnPMyS+0HToS+0MW/uVo5wla0GByNnAgMBAAE=
            """

        let rootAccountKey = try XCTUnwrap(
            AccountKey(serializedData: Data(base64Encoded: rootAccountKeyB64)!))

        return try AccountKey.make(
            viewPrivateKey: rootAccountKey.viewPrivateKey,
            spendPrivateKey: rootAccountKey.spendPrivateKey,
            fogReportUrl: try AccountKey.Fixtures.TestNet().fogReportUrl,
            fogReportId: try AccountKey.Fixtures.TestNet().fogReportId,
            fogAuthoritySpki: try AccountKey.Fixtures.TestNet().fogAuthoritySpki).get()
    }

    fileprivate static func outputs() throws
        -> [TransactionOutput]
    {
        let publicAddressB64 =
            """
            CiIKILJgHbpuWJZ6abjlsUrrOQb30Y1VYocTSl4mmf2W4IpQEiIKILQV1C5Bb60d0cwY\
            Iwuh5qXks7MtNe4wdL/x6KEHehMBGh1mb2c6Ly9mb2cudGVzdC5tb2JpbGVjb2luLmNv\
            bSpA5PqNG7wSNvSF67qGDfhKujwO0x+RWzbwR7WW4qH01VXBOwPw0m+z/Z4bb8ZjoyAU\
            aHjbtcAG7NLjSVVLR2/Niw==
            """

        return [
            TransactionOutput(
                recipient: PublicAddress(
                    serializedData: Data(base64Encoded: publicAddressB64)!)!,
                amount: Amount(100, in: .MOB)
            ),
        ]
    }

    fileprivate static let fee = Amount(400000000, in: .MOB)

    fileprivate static let tombstoneBlockIndex: UInt64 = 2411349

    private static func fogReportUrl() throws -> String {
        try AccountKey.Fixtures.TestNet().fogReportUrl
    }

    fileprivate static func fogResolver() throws -> FogResolver {
        let fogReportUrl = try self.fogReportUrl()
        return try FogResolver.Fixtures.TestNet(reportUrl: fogReportUrl).fogResolver
    }

}
extension Transaction.Fixtures.ExactChange {
    fileprivate static func outputs() throws
        -> [TransactionOutput]
    {
        let posAmt = try XCTUnwrap(PositiveUInt64(605199997600 + 100))
        let publicAddressB64 =
            """
            CiIKILJgHbpuWJZ6abjlsUrrOQb30Y1VYocTSl4mmf2W4IpQEiIKILQV1C5Bb60d0cwY\
            Iwuh5qXks7MtNe4wdL/x6KEHehMBGh1mb2c6Ly9mb2cudGVzdC5tb2JpbGVjb2luLmNv\
            bSpA5PqNG7wSNvSF67qGDfhKujwO0x+RWzbwR7WW4qH01VXBOwPw0m+z/Z4bb8ZjoyAU\
            aHjbtcAG7NLjSVVLR2/Niw==
            """

        let output =
            TransactionOutput(
                recipient: PublicAddress(serializedData: Data(base64Encoded: publicAddressB64)!)!,
                amount: Amount(posAmt.value, in: .MOB)
            )
        return [output]
    }

}

extension Transaction.Fixtures.Serialization {

    fileprivate static func serializedData() throws -> Data {
        #if canImport(LibMobileCoinHTTP)
        try Data(
            contentsOf: Bundle.testDataModuleUrl("TransactionSerializedData", withExtension: "bin")
        )
        #else
        try Data(contentsOf: Bundle.url("TransactionSerializedData", "bin"))
        #endif
    }

}

extension Transaction.Fixtures.Default {

    fileprivate static func inputKeyImages() throws -> Set<Data> {
        [
            try XCTUnwrap(Data(base64Encoded: "Mpi0OpU4JeTN3YGZyJDQakADLTe7SkrrzK3be3kn6xk==")),
        ]
    }

    fileprivate static func outputPublicKeys() throws -> Set<Data> {
        [
            try XCTUnwrap(Data(base64Encoded: "OEDBnfDWxrm88MEFvilrE1Qtcc2yDjUiFX3psxK3BxQ=")),
            try XCTUnwrap(Data(base64Encoded: "/HeqjlElnYDDMxtRA4LmmwbO9qKqZfAuRzm5jELJagE=")),
        ]
    }

    fileprivate static let fee = Amount(10_000_000_000, in: .MOB)

    fileprivate static let tombstoneBlockIndex: UInt64 = 634

}

extension Transaction.Fixtures {
    struct Commitment {
        let txOutRecord: FogView_TxOutRecord
        let viewKey: RistrettoPrivate
        let crc32: UInt32

        init() throws {
            self.txOutRecord = try Transaction.Fixtures.Commitment.txOutRecord()
            self.viewKey = try Transaction.Fixtures.Commitment.viewKey()
            self.crc32 = Transaction.Fixtures.Commitment.crc32
        }
    }
}

extension Transaction.Fixtures.Commitment {
    fileprivate static func txOutRecord() throws -> FogView_TxOutRecord {
        try FogView_TxOutRecord(serializedData:
            Data(base64Encoded: """
                CiC8HYxDXAB0BpSatEBt/RcAdja827WrGfSC98r440a3XREaIvW6wgVWCxogZibWmZBUztVVwmEVEoOH\
                wHc3ydGNf/SoJ1neF74DbzMiII4hgWxY3bCY62xi29I73rLWbWJiSIYM+1JzMAhDFud6KTlhBwAAAAAA\
                MYZ2AgAAAAAAOaEeH2EAAAAA
                """)!)
    }

    fileprivate static func viewKey() throws -> RistrettoPrivate {
        RistrettoPrivate(
                Data(base64Encoded: "gW54IsiCGiBKupPtPRQnoCZNqEz1jmS6IF2gazK50ws=")!)!
    }

    fileprivate static var crc32: UInt32 = 2481745913

}
