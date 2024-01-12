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
            let buildTxFixture = try Transaction.Fixtures.BuildTx()
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
/*
 2024-01-11T16:24:49-0800 debug com.mobilecoin : TransactionBuilder.swift:184:build(context:inputs:possibleTransaction:presignedInput:) -
 2024-01-11T16:24:49-0800 debug com.mobilecoin : TransactionBuilder.swift:185:build(context:inputs:possibleTransaction:presignedInput:) - PreparedTxInputs:::

 2024-01-11T16:24:49-0800 debug com.mobilecoin : TransactionBuilder.swift:187:build(context:inputs:possibleTransaction:presignedInput:) - PreparedTxInput:

 knownTxOut:
 KnownTxOut:

 ledgerTxOut: LedgerTxOut
 LedgetTxOut:

 txOut: PartialTxOut:
 PartialTxOut

 encryptedMemo: Data66 base 64 DcunL2+v248PqyQ7RG8AQKONJ+lA4wKIkOuIpcnOMKRDHl837UdMHllJgh1xQePulv0dsHOZ7MCtWfiz5cKxTQT1
 maskedAmount: MaskedAmount:
 MaskedAmount:

 maskedValue: UInt64 17792466809847936602
 maskedTokenId: Data base64 8 bytes
 commitment: Data32 base64 32 bytes
 version: Version Version 2

 targetKey: RistrettoPublic base64 uI3cGUyMcR84o6le4TOGXQQAG2W5ewmiGtdS3ZIRY1s=
 publicKey: RistrettoPublic base64 WjPg2BFIBHDstggSjcxRgifgtaOu1ovMV51zyAbMpUs=
 commitment: Data32 base64 { AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA= }

 globalIndex: UInt64 4533908
 block: BlockMetadata
 BlockMetadata:

 index 1493080
 timestamp unix Optional(1677540712.0)


 accountKey serializedData base64:
 CiIKIMM0eFjAenKpb/qWCpMpLBobETadGuaJCNy45N0Ej7sPEiIKIEU+8R66uCyb7xsVbX9qAPUa6cTxIpeQNIEQFoPbWFUKGh1mb2c6Ly9mb2cudGVzdC5tb2JpbGVjb2luLmNvbSqmBDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL5wfcE20zk+bqIs0WGmG8O1yBJCJ5fBOzBjgEI/sZwvhdayF4gp3P7dfuSCFo20RoVs6O0QMCObEWo59rE+K0Z/TV2zs2TLyKhOIZoZhM8tWEDQ53wCwFjUPlgW2BlvlaptyJULwBRY1TdWGCHWIWy4wD3ZIHlbFn3Cw36Kx5+q0d0AWWGSJUgUEikTGP7csE8Xkwryts1nEtJG2xT7QXFbYe1RRVTwGV4T4vcstQL55XTup+yi4rqVZqI5RDLb+BUJJOtOJ2pfo/3TqZUwE1fGvQCQWz0QWf8kIOexBtmNjEYhzkInycdEuVWzcjJvW5EvEw+xqIufWglujk9YMnqLVsC4OtCUWU38ie5WFgUjs4dDp2gsrUaUlrTWem2qz1Hjp37W5ybRPKxYRezOBeunrdCyP3Lr12HnMFcMpKLxFQSkReBzivRoEpte5kDLc6w+3OefE22rnDlmm2EdOLoXQHN7NdDJLjjVhtMCEIYCAoWFQBpxS70qadv2kBKt8a0UhE8bIsVCI7GcllkTpLgNCBZ3PHewJnJ1Ab0VuxU/+bYVspOWoHWFBmfuwtaOvYoUdWMZqBoevXyzDyBDoWIee9vt3JIJdkmleLqPRr5M/DDBkQXDCDJUYq0sIQn6M1dkck+Vp9TYD6cnPMyS+0HToS+0MW/uVo5wla0GByNnAgMBAAE=

 ring:
 txOut serializedData base64:
 EiIKIFiel6PR/jtuVE9i2VVjxZjzNG/nvzQvp4EZb8npKN90GiIKICju8yQ4YND672yeyw5HZCoZFkJc+k7BcY5Iq2EgjPxPIlYKVMiZ11Y7G7WVt/0Gw1lYmO8pZaKhbsmZw5yECs9ojc3hynoSdsXAIsBHBbJNKCmD7yE7d5BtKMNRKr6+B7RbzF6ieOygeNPqO2MwdMsM/ZRRXqYBACpECkJvxQTUgYCVf2sLcfXmdyrMQoWFRPxAj7eBvuU6BxPzRPaWsIxwqtF87KppriqYoZcBJQZA2RPCLleIxcImbZ+A9pAyNwoiCiDmGkg/CMTo+x7vbeEaK6iwlsr4gxMG+c7X80yA41lwAxGi562Vk5GJWxoIBl595JuNZ20=

 membershipProof base64:
 CNfdlAIQ3IvJAxowCgoI192UAhDX3ZQCEiIKINOlYPY4GlQys8t8BmR7MT0KDiC2bD75uGJomnNB9zZwGjAKCgjW3ZQCENbdlAISIgogEA+3EaB2ctuZyKDU7yVsS005cduE9kqyXd7gmf+uMDkaMAoKCNTdlAIQ1d2UAhIiCiBiObXC1nLhf3gs+w8iWKwC6MB5LaOwt+qKobyZm9H3AxowCgoI0N2UAhDT3ZQCEiIKIKPJWrYPamaZZzfOqEKRw77JKo9s5fO3GKfLmEEC57UbGjAKCgjY3ZQCEN/dlAISIgogbOQjzvs+zWFZGkywL8CFRWI0k/23LvkRYRfbbB77rP4aMAoKCMDdlAIQz92UAhIiCiAMbUIMwjm8Lxx82wj/bma+kXHt+4VcCQX90D9dnMxcQBowCgoI4N2UAhD/3ZQCEiIKILvhh4/+pNKDDoNqpNcYOMIZppCizGXRmIE/Q6q9VgXCGjAKCgiA3ZQCEL/dlAISIgoguoxg/LSs5MZlgv2ueFXeXrOZJ7HMLaKP8H/Wrf3mH7QaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKILiN3BlMjHEfOKOpXuEzhl0EABtluXsJohrXUt2SEWNbGiIKIFoz4NgRSARw7LYIEo3MUYIn4LWjrtaLzFedc8gGzKVLIlYKVJuduk/rOC2UW3mha2lABGb+aWBsB+3sFPhYHhS8c/xD9XOUrFm8EtEXmej389ZCiliRtbBCCN2Td8JAjMGNPxJ1DmwXFjSb+Keovov5gUkWwbMBACpECkINy6cvb6/bjw+rJDtEbwBAo40n6UDjAoiQ64ilyc4wpEMeXzftR0weWUmCHXFB4+6W/R2wc5nswK1Z+LPlwrFNBPUyNwoiCiBCsIdsaNtM+gW4eedzCzXZUZa+qluXIvvGdXil33G0CBFa9umGS4rr9hoIEC9Fg2/A4JE=

 membershipProof base64:
 CJTdlAIQ3IvJAxowCgoIlN2UAhCU3ZQCEiIKIG7g61YiysaTfeuTRReMfP/AAue7+NOee1ywjP6KwH/GGjAKCgiV3ZQCEJXdlAISIgog7M4kvFAF9RqOsNQ7gH0cFdlkWR0u13WR2t+GGRprhIYaMAoKCJbdlAIQl92UAhIiCiAYYMCCvyQZdI2ApjpGUThaVuuHvtm7P9ErdOKQEfC68BowCgoIkN2UAhCT3ZQCEiIKIC9AeEEReXg44I2do2rQpvm5L/B/PCY0fQydN3IptInoGjAKCgiY3ZQCEJ/dlAISIgogSfoptOxb1J3TdKqNiF8M5bJSE4ilbKTtsvT00NuupeMaMAoKCIDdlAIQj92UAhIiCiAiips/UPOfwvvu9EV5mFWZlIyoQvAlvIMgGLqic4sRQRowCgoIoN2UAhC/3ZQCEiIKIK4PwbvI3U+ej/ouOmAbU2hnj+vwz/bCKBR1/nhkBTfQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKILJolhmV1lskrCdempy7KtubUwdeJ6+cued1aQEbESg8GiIKIIQHulSf/2jDyOlyRG7/2G5BUqO/FtBC111FZFUmbgQYIlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACpECkJd13nWKWQPmsHc0wY+U0t5x6+r08KHhK0ML2gh19bkAfRDTMc3DsaZ9e03rC7jXzeTR7z+wtF663K8WMSqAOK2/aEyNwoiCiAa3lNmyHXJIpSoqH7n2B9DhGFe9GVCiwcxUEzS6eMfRRHcizESn1UqKBoIeCYB4L9QZqI=

 membershipProof base64:
 CMfdlAIQ3IvJAxowCgoIx92UAhDH3ZQCEiIKIOlbNxH07ZvIBXf3lwjAUDfM5lCYmoOVf5ReBh9Rzb3/GjAKCgjG3ZQCEMbdlAISIgogarY0/5L+yBdtiT7dd9mSKIKxxhy8mcyiNPlxyANIc8EaMAoKCMTdlAIQxd2UAhIiCiBIqgJJYD/OtivaV8c1kKTDou6EDJ36FFUpPPDP5gL8DxowCgoIwN2UAhDD3ZQCEiIKIDI3jcrt889gCgxwJQtXYXE6MUBlPQfgIOZ4kxiBNJK4GjAKCgjI3ZQCEM/dlAISIgogHcy3OkrJojCpM7VDN9+rgxSwCx6oZdHGglcDXZKEriYaMAoKCNDdlAIQ392UAhIiCiBSfExE2qKyt6zUMfS4uFnV/t2uS6UQZ8hM2vSgq8X3NhowCgoI4N2UAhD/3ZQCEiIKILvhh4/+pNKDDoNqpNcYOMIZppCizGXRmIE/Q6q9VgXCGjAKCgiA3ZQCEL/dlAISIgoguoxg/LSs5MZlgv2ueFXeXrOZJ7HMLaKP8H/Wrf3mH7QaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKIOKahD9folJzR6FR/eGB0LBPrpGhZdkXfcZIOPlhijZCGiIKIIbVfC3TQ3yHadvxgxYZR8eIGPm6QXga6Aq8N2dLwjYpIlYKVPUAjddDiPyhh3uMd/RZIIKEomM9ZGuhwMy5Y8nHiNKcr/+uRy04Sweng76j+WAa3D8BKstiXzPx2Ay7a7Eim6iABal3WRd02kat8rRNlgvv2p4BACpECkJuhsL1E0+r5ZeCPUVddz8Ep69lh3eJALSPpJBKJmrDrp+7XZaWm5zKarZPOWsyvZEuQAF5wdSvl8dh7zq97H8v0qsyNwoiCiAcolURIxFIBV6FpZgSy1sV+63Kiy/J+5X+sHIrdXY1XBGqrJPUX8L0zRoInvDpF/sF1wM=

 membershipProof base64:
 CJjdlAIQ3IvJAxowCgoImN2UAhCY3ZQCEiIKIISOqIkBpW8GrASuKD90ndIM4EvpwCx8J5ij0JdLkdAmGjAKCgiZ3ZQCEJndlAISIgogi1loXSRxZ7RN5HRdrXJWEko92BPvthiR25tV83QmxTUaMAoKCJrdlAIQm92UAhIiCiA6vYqNghv94ehD1XoK5iTxuA31B9yqfo0vZ5XvzN4SPxowCgoInN2UAhCf3ZQCEiIKIHEfL6yXiNDxkqNlvso3aV1Y2VgQLmGEPuu0Vzk5x0VlGjAKCgiQ3ZQCEJfdlAISIgogrkdvHxiYJgLvJPE2raLF09Bz7LcET0InUPjbyw4D6qEaMAoKCIDdlAIQj92UAhIiCiAiips/UPOfwvvu9EV5mFWZlIyoQvAlvIMgGLqic4sRQRowCgoIoN2UAhC/3ZQCEiIKIK4PwbvI3U+ej/ouOmAbU2hnj+vwz/bCKBR1/nhkBTfQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKIMpSmpGBMzd3UD2Mig/8UQef3b0CFR44x2nZllHcpeZhGiIKIIj8zimWewx0Z73gVOJyLVN4gTjJEmm/xTYbMgKwXvgsIlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACpECkL3NmyAzFJpalrNdsmoicazukVbKzSbLFgdRcWIAPonToaNbnVC/Si452dKzfx1zbrowdbJU5SlRPImp6Y1OcAVmykyNwoiCiBcizxNjVmMo7USaiAoxTnOfsZnNigsPFDeweq7v3i+XxF2N3/6j2vgUhoIjrR0uqSWh+U=

 membershipProof base64:
 CIvdlAIQ3IvJAxowCgoIi92UAhCL3ZQCEiIKIJOQpE9QYwSYbBG/5a8reZK/VOcD8LnNqBUhbyaV2MQkGjAKCgiK3ZQCEIrdlAISIgogwyLzZ12l2H5RlSieuMy1kfDSz0tXcOxmHTcNT226PbMaMAoKCIjdlAIQid2UAhIiCiB+JoERRosmm9cietueZxsDnciLfJv3octgJgTCxH8XnBowCgoIjN2UAhCP3ZQCEiIKIPcIF/zb7uTH5LnaE8fEzgR+ucenWTVjRaQUDTNfX6exGjAKCgiA3ZQCEIfdlAISIgogDkRZ856OtA3uqhbtb1oZB2ezrXflgcru2wGlu9IyGUEaMAoKCJDdlAIQn92UAhIiCiAWAWnMA/T8f7LGzR7nPbO5tGDsQzvNsU6H3nhqMsEafRowCgoIoN2UAhC/3ZQCEiIKIK4PwbvI3U+ej/ouOmAbU2hnj+vwz/bCKBR1/nhkBTfQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKIDx7K/gGR949PyDIP5HJd4pHwcmfVR3Up1HBy3AzvmwXGiIKIJ7vF0Dg8NB9xA3GfL0gi1+rOsdPD+Tp45h4tPF+S+Y8IlYKVHExxnp+dXhH6QgOMU1+judxkdLwdYtV60JteTuIdot2gKigEF9P3higi307+uBxIkDKJ5B3hJy94GwbtspzNFV2QvT5fRPM9W5aamfq0HqW4t4BACpECkJXSpMDn3+jbpkI585BngRokQDz3fGkE/UIWpi87Keuw9UUKWSReLdOmmBangtcUYEItnumtqa6N6F3swOv1IFDjT0yNwoiCiCC+Bf0yhwtoI5eVvrDkIll1xx3BkEp+lTSxydpGWITSxHZJOrrGZj4lxoIjsTVzMbDsCY=

 membershipProof base64:
 CMzdlAIQ3IvJAxowCgoIzN2UAhDM3ZQCEiIKIMocGZvUyh6CPU0+SqASU3uuTLLz0eBWlULXWPes1qVxGjAKCgjN3ZQCEM3dlAISIgogvOSLfMOi1RfSRSAxtlTQp9RoKDrkPY05SKylKuonYUMaMAoKCM7dlAIQz92UAhIiCiBaM4laFvNivaWv47jwn44Rxwk44XkxdVDCx6QLnWnCZRowCgoIyN2UAhDL3ZQCEiIKIEdtAMMjaNu3mP0msGKO6J2hROTHc9BfJzEgIjtXgXZTGjAKCgjA3ZQCEMfdlAISIgogfVTDgSVOixRdCu40VHRnnK113PvgB5VAJ5PNYXUw+KAaMAoKCNDdlAIQ392UAhIiCiBSfExE2qKyt6zUMfS4uFnV/t2uS6UQZ8hM2vSgq8X3NhowCgoI4N2UAhD/3ZQCEiIKILvhh4/+pNKDDoNqpNcYOMIZppCizGXRmIE/Q6q9VgXCGjAKCgiA3ZQCEL/dlAISIgoguoxg/LSs5MZlgv2ueFXeXrOZJ7HMLaKP8H/Wrf3mH7QaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKIIZarv+FjMetf0UydxrqpoxHigS0TdPB7iME9080w11xGiIKIJ75jlQlzdooQCzYsNp5EVaKS5SfdcsY+xHpxHK/cz5cIlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACpECkJGUNbqH3p9IJbZMXvgz3gv5AfJO298LET45wIvv4kd+YFh4fbbAvQ9BTN1tZfJiRW/OlsGzlLmzwISENNo8D+1b/0yNwoiCiACU4fQPnaCCjOluqEk+khDtE7bsdSfTpE9fty1SkNLPxGHxJOWKA4xvhoIzjLY0XWaML4=

 membershipProof base64:
 COfclAIQ3IvJAxowCgoI59yUAhDn3JQCEiIKIAsvdhl5QXrP2/bDSnBcWY6RoJxLAZgQMOonn3kZTNMRGjAKCgjm3JQCEObclAISIgogK4Mcj1ZtcXx53ibLK33U8CstjBfzCYrv9pAwM20oB8MaMAoKCOTclAIQ5dyUAhIiCiBluff4LUO5NLNp9WGTwG6zNL3tJNLMU6OSUE6eYQtlwhowCgoI4NyUAhDj3JQCEiIKIOx5kWjpIeSRdIjhZjmK0CuRlg0E3MUW4FiO2hhFWpdVGjAKCgjo3JQCEO/clAISIgog1WwYGvxg/rpEfExG9Br8KhVyCanmF2wDRha2aMa9NSIaMAoKCPDclAIQ/9yUAhIiCiC740M2yUqHjGay/SPe55WpDG3L/uzFJ3gKF8pdeh9JMxowCgoIwNyUAhDf3JQCEiIKIHRuI8xC+qYgDWW2tvXZYbqSi3Z5u1PEQ+4JlUZO09kwGjAKCgiA3JQCEL/clAISIgogr3Z7tfLq6a5kZQ8a9Qbtke9192uT6HXwYKAkPVxctjEaMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32ziRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKICCnBWPBDNe2uRzHlAJoIstPPyXCLrWJbhRbg7B8hj10GiIKILTZTiBE5jDW63X0DtCz8Z39fsxKIvooogsh8eMxjtV6IlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACpECkKLG7kRSCS+yclhXNkhEsdxagTDcj6lg6dh43EKtyiv7h/cScoKjHDw30LmWC2fEGik0XPwNRg/N8rrL1McxwO7B6IyNwoiCiDMjhIAa+0c2dymaYF8W/b/SPYsm/CyjR4xamiJHzeAOBE194lbE6kDnBoIy9tugr3Qfyo=

 membershipProof base64:
 CJPdlAIQ3IvJAxowCgoIk92UAhCT3ZQCEiIKIEaSZO1JDmnr2+epqYsVuDOvfsLViu23uzN7/rsbtEgdGjAKCgiS3ZQCEJLdlAISIgog1zag542IF2DStKGBhGohdVL/+KCa5Aa9NKc8ChwDLwsaMAoKCJDdlAIQkd2UAhIiCiAA5dsL0cOgR2a2tauGQeIPL/+oSw5qZqfsRBcEES87jxowCgoIlN2UAhCX3ZQCEiIKIHaQaA7lVxRSy3iAR0SqYC8CfAj/MHGCAFsqfg75u09wGjAKCgiY3ZQCEJ/dlAISIgogSfoptOxb1J3TdKqNiF8M5bJSE4ilbKTtsvT00NuupeMaMAoKCIDdlAIQj92UAhIiCiAiips/UPOfwvvu9EV5mFWZlIyoQvAlvIMgGLqic4sRQRowCgoIoN2UAhC/3ZQCEiIKIK4PwbvI3U+ej/ouOmAbU2hnj+vwz/bCKBR1/nhkBTfQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKIMK4GERrCCTNuXCYKvjZhjq5W7YWBbs7tHClbul4HoQ7GiIKILqz+5Ma2LNmZZ9cSUa12tAPwCktp+S3kGn6cTrM0PYcIlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACpECkIbAQQCgLs4ltufJQ2oh0724zIH5qq9we9qY8rz+qFipaTFeL9R633egyNjuIBAoNgMk/GBVq2/dr+eymSPRn1n5j0yNwoiCiA+CPRR6Y0AB4eliIzkc4OvDTvspRHfPluQ84L0lnkzLBH++1BnwuliAhoI2bwCjSlvtrQ=

 membershipProof base64:
 CO/clAIQ3IvJAxowCgoI79yUAhDv3JQCEiIKIOVqS7QRUlcW3DhYTP44co6X1IaWzM23FkRbd4C5KiCKGjAKCgju3JQCEO7clAISIgogbFRx7tGzVShdEvmFggoiJ3p8zJKfJURyUdBzwAD76yYaMAoKCOzclAIQ7dyUAhIiCiBazHqZgMM1/0efWGSrIr8XSY3QOqZagusEoAQxgYJHMBowCgoI6NyUAhDr3JQCEiIKIKoHzUjR+bdQ6pH5k+alNGp1x5zkUQpVZewbFOivNA+BGjAKCgjg3JQCEOfclAISIgogZRuNIskb4vBIuTCMXISSHz0ZK9mrQAWpqkH0O/p/3ncaMAoKCPDclAIQ/9yUAhIiCiC740M2yUqHjGay/SPe55WpDG3L/uzFJ3gKF8pdeh9JMxowCgoIwNyUAhDf3JQCEiIKIHRuI8xC+qYgDWW2tvXZYbqSi3Z5u1PEQ+4JlUZO09kwGjAKCgiA3JQCEL/clAISIgogr3Z7tfLq6a5kZQ8a9Qbtke9192uT6HXwYKAkPVxctjEaMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32ziRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKILrZLwqSfKlwJRT2cTEk2BNhdhY+p0ApjFfNs48+RyBcGiIKIMDPANWyKlzoY3F0i1c9Pp8HNGnvvpbzNqwNKstCxON6IlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACpECkKTqHa+PNhP359m7enWyWz9JNt9GDv7/1WZTLTVjx5sJpH+2c07ztfHnf/abGpoY1t/7psizO1Hq6IBFghJ75qnqq8yNwoiCiBUb+Cjjpbnqtcl6mGP8PMB/FXmI37OUNN0dPpRyOC9DREmWYPLEwE4shoIlguHt3e/ICU=

 membershipProof base64:
 CMjclAIQ3IvJAxowCgoIyNyUAhDI3JQCEiIKIIpLJOO4KGWr/u/fh8GH1WHqQB34Wn0haHvkKWw3VNJ5GjAKCgjJ3JQCEMnclAISIgogWtatm//m1pV7NFushskrR0pBx419333Q/+zJCm4Kz5IaMAoKCMrclAIQy9yUAhIiCiCMKvnRjg8DvW9Hjxy22Vpzt8UQjaG5pZiUfvv9pl2/vxowCgoIzNyUAhDP3JQCEiIKILdXWbZIJOU2qX+hbjquLg1ZIY0KXNv/+tE12rWZu7TZGjAKCgjA3JQCEMfclAISIgog7zAUx1T41+zxpj+P6yHhY2MkkW2yC2gjgoPXUmBW1GIaMAoKCNDclAIQ39yUAhIiCiBioFquQAe4rC/SY9iWXivmxC2D3ydQ0cODRg2V6c1CGRowCgoI4NyUAhD/3JQCEiIKIDXYv597nUABiIoj10DFLze7C7L4GA9DdMm8h0EIyvwrGjAKCgiA3JQCEL/clAISIgogr3Z7tfLq6a5kZQ8a9Qbtke9192uT6HXwYKAkPVxctjEaMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32ziRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKIBR+YEcAIxS/Brl4cwd0NXUieenPctmpjTSUMLr4jlt3GiIKIPiwdemDyHIMRH+zAFrMYKV8b9kFQY+Iw3636bCFYB40IlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACpECkIVoAyQtw5182mvB/GpRovdF5HjILEglKBZJALUtBjKyLLk5101BRMsCNGo3IytqKdvt0JvOKa2bKoepyhq9JpEel0yNwoiCiDe4UZqCMGlrspxoFunTfXz9urRe1J4XeacAJ8pQ7BOFBECJTJT5PLwcRoIhgQYpcie77I=

 membershipProof base64:
 CLLdlAIQ3IvJAxowCgoIst2UAhCy3ZQCEiIKINr9YzWu/ZKp23B1PWX0E8Fj4J088S+6rtD39gg45Mk4GjAKCgiz3ZQCELPdlAISIgogD6bQmKqPdrvvIfuzN9x/TMud7H8/OQ0QJurSf7UtfooaMAoKCLDdlAIQsd2UAhIiCiBQxPHmCGLd3WrnHoxgJW7jZwjDOXAvLlTbXMz0Ny1TVBowCgoItN2UAhC33ZQCEiIKICz4+Lzq0dUE5psKqiV0B2eb43EHjr1k/tr3+IWM1AdqGjAKCgi43ZQCEL/dlAISIgogTtx/huTfDwu4XPDwVIiFXkr7VHjIX9B5RV9aLD/TU5oaMAoKCKDdlAIQr92UAhIiCiDS/ksdZP12WlXAZiJFJh0x5AKSUP9T56s5Y9fl57Nz0BowCgoIgN2UAhCf3ZQCEiIKIDGc83EOoCbkDpZdqP7Gc9M2hKR04PZGH+l+/8Xl6DkQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 2024-01-11T16:24:49-0800 debug com.mobilecoin : TransactionBuilder.swift:187:build(context:inputs:possibleTransaction:presignedInput:) - PreparedTxInput:

 knownTxOut:
 KnownTxOut:

 ledgerTxOut: LedgerTxOut
 LedgetTxOut:

 txOut: PartialTxOut:
 PartialTxOut

 encryptedMemo: Data66 base 64 /hpC0EFCnzx2WLLSORctFy/a15YkNAZv04NFU9EJZuhdJI+CtfZDcAEz+6tPtpb45THnT1rydm48sjsdmhd1Q2xQ
 maskedAmount: MaskedAmount:
 MaskedAmount:

 maskedValue: UInt64 11011028853111894764
 maskedTokenId: Data base64 8 bytes
 commitment: Data32 base64 32 bytes
 version: Version Version 2

 targetKey: RistrettoPublic base64 ND4wz0VuSGPWjYUWxhsdy11IaZJIiangAOaIGH/em00=
 publicKey: RistrettoPublic base64 mjCqnh4DbYPVLkWqEAyVHH16WHpK1E8tTyxEPyDe728=
 commitment: Data32 base64 { AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA= }

 globalIndex: UInt64 4533909
 block: BlockMetadata
 BlockMetadata:

 index 1493080
 timestamp unix Optional(1677540712.0)


 accountKey serializedData base64:
 CiIKIMM0eFjAenKpb/qWCpMpLBobETadGuaJCNy45N0Ej7sPEiIKIEU+8R66uCyb7xsVbX9qAPUa6cTxIpeQNIEQFoPbWFUKGh1mb2c6Ly9mb2cudGVzdC5tb2JpbGVjb2luLmNvbSqmBDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL5wfcE20zk+bqIs0WGmG8O1yBJCJ5fBOzBjgEI/sZwvhdayF4gp3P7dfuSCFo20RoVs6O0QMCObEWo59rE+K0Z/TV2zs2TLyKhOIZoZhM8tWEDQ53wCwFjUPlgW2BlvlaptyJULwBRY1TdWGCHWIWy4wD3ZIHlbFn3Cw36Kx5+q0d0AWWGSJUgUEikTGP7csE8Xkwryts1nEtJG2xT7QXFbYe1RRVTwGV4T4vcstQL55XTup+yi4rqVZqI5RDLb+BUJJOtOJ2pfo/3TqZUwE1fGvQCQWz0QWf8kIOexBtmNjEYhzkInycdEuVWzcjJvW5EvEw+xqIufWglujk9YMnqLVsC4OtCUWU38ie5WFgUjs4dDp2gsrUaUlrTWem2qz1Hjp37W5ybRPKxYRezOBeunrdCyP3Lr12HnMFcMpKLxFQSkReBzivRoEpte5kDLc6w+3OefE22rnDlmm2EdOLoXQHN7NdDJLjjVhtMCEIYCAoWFQBpxS70qadv2kBKt8a0UhE8bIsVCI7GcllkTpLgNCBZ3PHewJnJ1Ab0VuxU/+bYVspOWoHWFBmfuwtaOvYoUdWMZqBoevXyzDyBDoWIee9vt3JIJdkmleLqPRr5M/DDBkQXDCDJUYq0sIQn6M1dkck+Vp9TYD6cnPMyS+0HToS+0MW/uVo5wla0GByNnAgMBAAE=

 ring:
 txOut serializedData base64:
 EiIKIIr/M/xM/yATwyWzIXRRT3BcEGX6dfE0GO0bID1LO+I3GiIKIDqQe3sZu+h/V4mQMl+D9rJWhmTmGv0Y9T7MwIA0HvBAIlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACpECkK5qi07/eETudxaj2G8qPUyYOsk8XMBQBmY6dmzvOjQ48pq4Cn2QSb/maXUwgHUt+dnOlOfXynfT2PmFCW7kAkFn4wyNwoiCiDeS1Xm4s2xjATNlkvX2xqE0sscHScmIr5z+E5/w8s5QxEuRd81XvzmyxoInbLRNRa8FKs=

 membershipProof base64:
 CLbdlAIQ3IvJAxowCgoItt2UAhC23ZQCEiIKILU3y70/tqgzdp0TRIPS+RNH+MuIa1HzChY7ZVFWMlYUGjAKCgi33ZQCELfdlAISIgogqwpv6e6S324ar3V+Z19kU8sTNlg6G1BMm/7mRct7CJIaMAoKCLTdlAIQtd2UAhIiCiCNWg8uZG+cpZ79C289dnhc1udFyTUocQm31ztq5gO5XhowCgoIsN2UAhCz3ZQCEiIKIO5C6y35rA9abBf18HAk9e0C4PmiPKDo15w6sHpPyLNNGjAKCgi43ZQCEL/dlAISIgogTtx/huTfDwu4XPDwVIiFXkr7VHjIX9B5RV9aLD/TU5oaMAoKCKDdlAIQr92UAhIiCiDS/ksdZP12WlXAZiJFJh0x5AKSUP9T56s5Y9fl57Nz0BowCgoIgN2UAhCf3ZQCEiIKIDGc83EOoCbkDpZdqP7Gc9M2hKR04PZGH+l+/8Xl6DkQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKIFDxre10v+sIBer6VC/kOUJKXygBsepf9rpxijGYoEdmGiIKIGRrfFooJJwRSUjFhgGOt9G6svZvPEikaWzhd6GAJXllIlYKVGxtzA4D8xCvEjjT+bc66DeT5rlpy6e8Xjy+yREcblBmHQh2aeEq3FIpfv9CdzIKshrBoJXEPJ98MAWYhzqeEoilevq1f1efbrNaIwcVCxx3LKkBACpECkK+ypds4zuiCfd9uIv7ua0++FI1UxP+iRKJd5Nyq+PU7Okp3WRkVuOWwe1ZT43aqqUS8+nWjZ4p5O9r1z6HcWQ/Rc8yNwoiCiBktRfY2gX+UMyJHzpbBnVwGINIyZ3PvPrC/Kxo4hGZFBEfXabSC+PoORoI1CUPysrvz5Q=

 membershipProof base64:
 CJ3dlAIQ3IvJAxowCgoInd2UAhCd3ZQCEiIKIChLasvwRdNshRzkxs4rtcrEYjSIrHkbXAq50LF/dQ4yGjAKCgic3ZQCEJzdlAISIgogRyRZZveue6VuSNjr3zNHCGevDUYFWcGV4Dc0Wuw3WvgaMAoKCJ7dlAIQn92UAhIiCiBeElI72GdDtsQFsrZ1c6AzTMQZmOmH2DQElN6ek8q5YBowCgoImN2UAhCb3ZQCEiIKIKJBk7zNc153Zlbm+nZEz/6xrQ/xkrZQmZ+4mLlsXIcJGjAKCgiQ3ZQCEJfdlAISIgogrkdvHxiYJgLvJPE2raLF09Bz7LcET0InUPjbyw4D6qEaMAoKCIDdlAIQj92UAhIiCiAiips/UPOfwvvu9EV5mFWZlIyoQvAlvIMgGLqic4sRQRowCgoIoN2UAhC/3ZQCEiIKIK4PwbvI3U+ej/ouOmAbU2hnj+vwz/bCKBR1/nhkBTfQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKICIJFBMBJRdofx8J5d1daDrrj74lrmgjxCv/TNli8xYGGiIKIHIjBEVuTJjJWeniBDphqoYObWdJgdTVko9oZbdRXn01IlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACpECkIcN4DJxEB44yjGlAeap2WOkDZGdjRikTQ/mGxm9R/6UVWU/k5OzZrggyZaLcm4SBgItStyuTBczrHszL90tyizrmIyNwoiCiA8mNpIqnumLIro4ZrEyErMvW90/JcrAJ5/+iS4nvkYVhFuam52vhYk0hoIUo89VnzTHtI=

 membershipProof base64:
 CI7elAIQ3IvJAxowCgoIjt6UAhCO3pQCEiIKIJnSCqGlVGH14qwG1fDWp5xAjRcPI3xY0VZMJ51usVZ4GjAKCgiP3pQCEI/elAISIgogemeyLk7gJVT193FduGB4Jv60qmSH+zsf3TPDW8SVFpEaMAoKCIzelAIQjd6UAhIiCiAwNKKB8DaoGaryinuTIcdLgNBizJTTARqWSyNTOhb3bxowCgoIiN6UAhCL3pQCEiIKIHeL5F0IinSHxQaNJQPJpDbP6kIDQC+7AidTuhW3NyWmGjAKCgiA3pQCEIfelAISIgogqMshqJ89vRepYNomZYm8T1bC5cfr9gGKHhIiO85Le54aMAoKCJDelAIQn96UAhIiCiAuF6EC1Qj7sfERgzkO9q14Bva/jBpZIpKQDNlYgauJFRowCgoIoN6UAhC/3pQCEiIKIEf20XGd+vH4CHkL/wtzxldjlrDQ/dqR4znM+1DtW/sEGjAKCgjA3pQCEP/elAISIgogOpJ0cDFEiKOPwyI8JDAOB/wGtmSOAOe3pQxs1BbpOeoaMAoKCIDflAIQ/9+UAhIiCiD6koX5S4/N1FWSm3CWhLnqdPojuZTM+UP4RWW80aRXiBowCgoIgNyUAhD/3ZQCEiIKIAZPt0fMRG2BHchB3qG8ZkmNOVDud1ESYikZzbr2j/RnGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKIM4d4knBhS5DTx/uD+lW6AqfqfZLhfbE5zuRtvWXZxZ/GiIKIIgqhtkGKuwrgF2syHau2UfDk0IWgx2m7DfUDUYsRyV+IlYKVO+DJ/RUI69feYIFRsVDt82pMCog6GaGJt4RHnL9goFax6Sir7R2bflwit+KxM71SdqcxQVIK7zUpk/YwPBeti+ZWh1je0DGy6qYglLBYwWEBBUBACpECkKNOzI9s+uGZiNsIk/+s+NczArRw4jh30PFYSuI+BdR+ahVCq+q1exdiQudAAJ9MTxZNdYRGQfHhkvma6N8Bg37SGgyNwoiCiBaAv9zsslb0a+XaBH0cdI3ZFNoqNSxI78evMRfGQrLDhE4WHxCM3Eh0xoIQVSLVjqWiUk=

 membershipProof base64:
 CN3dlAIQ3IvJAxowCgoI3d2UAhDd3ZQCEiIKICBwzxWmKSQY3vd9ZZur26dnWfxHcllGnziSaCyTMUDgGjAKCgjc3ZQCENzdlAISIgogBGpQLIDG6UyFi+OQ8LGR9NKkRkN2VFnr+b5fww59JtIaMAoKCN7dlAIQ392UAhIiCiA4Zp7eqrajDemFx5tONHyaX6Bq0CFXQ2Y6kYnaJfWL1xowCgoI2N2UAhDb3ZQCEiIKIPXTZxTfRXzQUNpp4r9umcyQkjsnNUR5WiaOxrUvJ+JMGjAKCgjQ3ZQCENfdlAISIgog36IIemjQgHL8Wp9iPVVnGyftQbRIqiyYKvwqv+pUOSsaMAoKCMDdlAIQz92UAhIiCiAMbUIMwjm8Lxx82wj/bma+kXHt+4VcCQX90D9dnMxcQBowCgoI4N2UAhD/3ZQCEiIKILvhh4/+pNKDDoNqpNcYOMIZppCizGXRmIE/Q6q9VgXCGjAKCgiA3ZQCEL/dlAISIgoguoxg/LSs5MZlgv2ueFXeXrOZJ7HMLaKP8H/Wrf3mH7QaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKIDQ+MM9Fbkhj1o2FFsYbHctdSGmSSImp4ADmiBh/3ptNGiIKIJowqp4eA22D1S5FqhAMlRx9elh6StRPLU8sRD8g3u9vIlYKVO9lsvCG3yXbPlpeDNiZYICASkPp27vpRgebJ7QeoTSwM/biSBBUiqADVMl2JksYZ8vdjUVHd3UUKJzlwXcfBuE5O/m9NuUd3OG5cjiyh25K+j8BACpECkL+GkLQQUKfPHZYstI5Fy0XL9rXliQ0Bm/Tg0VT0Qlm6F0kj4K19kNwATP7q0+2lvjlMedPWvJ2bjyyOx2aF3VDbFAyNwoiCiD6iC1NNTYS+jBRjjwx5X1Ng837FFbRqbGggDemC9iNKRHssk8pZwjPmBoI8E2s/zEhK4w=

 membershipProof base64:
 CJXdlAIQ3IvJAxowCgoIld2UAhCV3ZQCEiIKIOzOJLxQBfUajrDUO4B9HBXZZFkdLtd1kdrfhhkaa4SGGjAKCgiU3ZQCEJTdlAISIgogbuDrViLKxpN965NFF4x8/8AC57v40557XLCM/orAf8YaMAoKCJbdlAIQl92UAhIiCiAYYMCCvyQZdI2ApjpGUThaVuuHvtm7P9ErdOKQEfC68BowCgoIkN2UAhCT3ZQCEiIKIC9AeEEReXg44I2do2rQpvm5L/B/PCY0fQydN3IptInoGjAKCgiY3ZQCEJ/dlAISIgogSfoptOxb1J3TdKqNiF8M5bJSE4ilbKTtsvT00NuupeMaMAoKCIDdlAIQj92UAhIiCiAiips/UPOfwvvu9EV5mFWZlIyoQvAlvIMgGLqic4sRQRowCgoIoN2UAhC/3ZQCEiIKIK4PwbvI3U+ej/ouOmAbU2hnj+vwz/bCKBR1/nhkBTfQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKID7zJYODGcFfTqpKgfdeK7/iRSROJu5ajjCTOTkEPKJSGiIKILQPKM8g4EWltlgr0XteyDasQkTtdwYv+2uH+ZoIQ4cQIlYKVHz3gFIUeM02FA5PRGFDdiVIyb3KryY9RRMtKdUKrK4evxlG/EoqNbqDNw67+uZmJdpGSV5NEEtDBzC5+ay047koahnlGOo3NEdNO431ui6eiRABACpECkJP2O6I12TTzcH5OZo5YAcFkB7ufVfnXs7mWfNlekLMyQs3vmZ75RNYoH6jgaK8OWe4czhCqvoT6lgLjOwXbfOto9MyNwoiCiDa19NkQDcJl2nmNrz/FSM/TtnoGfUqn1lZSnDZeBzJShFfd+cX7bWrzRoIGhQKdaGYJQE=

 membershipProof base64:
 CKTdlAIQ3IvJAxowCgoIpN2UAhCk3ZQCEiIKILPcc1heNyPbyys8hc6rGZ3b/mV3/pcePxIBQU8dBUZyGjAKCgil3ZQCEKXdlAISIgogIIowzVKoq22e3hULi1VPceo8J5nu/jI7qnQsYrrVCcsaMAoKCKbdlAIQp92UAhIiCiBm1Uu8BA3w3LWaLsT7IdvVog8htls17L9FIOp5Hjbj3RowCgoIoN2UAhCj3ZQCEiIKID2wLKcnKirh20Th2+j/oLNgD6oVv+ziqaqKb+qjXNbcGjAKCgio3ZQCEK/dlAISIgogpncMnZCW+CwxdbFeHffdxqRQEPfWX8o2lBbhAKLH8ncaMAoKCLDdlAIQv92UAhIiCiBbyjsB1YrqaxzP47F4mQP2X40T/fcIsFgU+COfQIaa9xowCgoIgN2UAhCf3ZQCEiIKIDGc83EOoCbkDpZdqP7Gc9M2hKR04PZGH+l+/8Xl6DkQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKIAQ0JenLnUOeRrJT043B0euulvJMCUQDwvNI3lisCMVIGiIKILjloIPZLzma3SmCtU4eeuNJJD2K1kh+LWhtJrd23dALIlYKVLGk65g+u7Q3bbuxSgPy8tHfru1AIQbYXS2VrNxyyqAmrseipwcRZ4VhC58n7sbEkw9zxdzmjBQ1F5Z4/uw6IWfRIVaOi+bQlNJqA5p6Tv7r+ZQBACpECkJ+i/HiNvwemNVKw0Lpjy7XsCVMaraMzBvWvHQa8o8OFpWo/P5uhwRKirIybliHu6bYEx+3YP765eMk/hhACG64Q30yNwoiCiCIHcoMMJfBGu0i55Yd+XdvUcigOe9mtMV+2YwEKeG1cBFxJbCKgILjYBoI9qvDXWbczag=

 membershipProof base64:
 CLXelAIQ3IvJAxowCgoItd6UAhC13pQCEiIKIKIhWipp/tVEb2NHihYneJLwJ1i9Y8Dnqgv1ckph1vW9GjAKCgi03pQCELTelAISIgogQJ7QueURQ6Zov7j+YzMd1zetjcVuoo6flnvoYA32Ym0aMAoKCLbelAIQt96UAhIiCiBgTex9Qkm8wQW+2zfIlJKpq0wp5X+ow4L4U54bYTdhdBowCgoIsN6UAhCz3pQCEiIKIGxzSCRuOFl7xwhubV5mHGXP3cRoRHl7X3mxLIpK2/lAGjAKCgi43pQCEL/elAISIgogjHo2N3OFjy4yqN/2XS/HTbE2bZ3k7thryNcU5bb1k+0aMAoKCKDelAIQr96UAhIiCiAscLun98nN2+ZIq8IDbdBxOYDp/miDh2bSeuzCMHYtvRowCgoIgN6UAhCf3pQCEiIKIGA+qeLokB53eXN0c1DQ58sf+u2Dp3QD2zwaEB9UDHp0GjAKCgjA3pQCEP/elAISIgogOpJ0cDFEiKOPwyI8JDAOB/wGtmSOAOe3pQxs1BbpOeoaMAoKCIDflAIQ/9+UAhIiCiD6koX5S4/N1FWSm3CWhLnqdPojuZTM+UP4RWW80aRXiBowCgoIgNyUAhD/3ZQCEiIKIAZPt0fMRG2BHchB3qG8ZkmNOVDud1ESYikZzbr2j/RnGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKIA4cY1dSBQkPYt5Lwf5UfkZPOxNPvslf39DJh8NrVcVeGiIKILqNcsJ0L81KkLcLDtfFtWCg3IeC0CE9D9me3ObbVLYIIlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACpECkIcpPM6GhWGhP+O39ZbeQq3tegBnOBQ6NKs+tL4QZyp3qU3mTkp5lN5vhC36kfqEUpTOQ69WlQ7wrOSmDU/CNM+PBgyNwoiCiD+DRfVbK4mOHoAk8Wg94qP0Rcf9fokitq66rhl3vguYRGAKoYeFXA0ZBoIPp5pEpeciCU=

 membershipProof base64:
 CJbdlAIQ3IvJAxowCgoIlt2UAhCW3ZQCEiIKIBS9xr5rbrGyLNXjrd7I3wU3UuT72t7sMQlc8kBqxmISGjAKCgiX3ZQCEJfdlAISIgog2I10Ghdrpjg+uoyvQ+y95Qxb/B7uo3uhC2/KA3zB2U4aMAoKCJTdlAIQld2UAhIiCiD/o/lcxTXFfXYEP7TR0U9GUAPZF0R9cdFWoAGjHDw3sxowCgoIkN2UAhCT3ZQCEiIKIC9AeEEReXg44I2do2rQpvm5L/B/PCY0fQydN3IptInoGjAKCgiY3ZQCEJ/dlAISIgogSfoptOxb1J3TdKqNiF8M5bJSE4ilbKTtsvT00NuupeMaMAoKCIDdlAIQj92UAhIiCiAiips/UPOfwvvu9EV5mFWZlIyoQvAlvIMgGLqic4sRQRowCgoIoN2UAhC/3ZQCEiIKIK4PwbvI3U+ej/ouOmAbU2hnj+vwz/bCKBR1/nhkBTfQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKIKjeo+9ZbmZpyQPayglP0+IYQ/uyb4J9FBWlj/nIVXVyGiIKIOzDdUIyyANAnfqs3sWQuvXYwRpFQkVHarN+qmibkQIBIlYKVK6P2D+Xj1fkeaXZyNWRVAhB7M9guyl1/YNGGnraI1q8uxuQDic0VW8r2Jl6iUhjHPASMwyhP0RxQWrhVuSFNYdEV6z+LLVd1MKDOY6iDRG70RQBACpECkLecy6h4QV/L5tC/wIXjRH/NKGvV+pYzA3rfneWv6l2eIVzhNIpfX0jKBaishcKSaA9ynAq0krVqwpnClhNHQro2uQyNwoiCiDwLLmPt+F07jMi9IYrhaiTdSQI2cykv7riwE712z1gOxE27n4czVojJxoIqY+QOKAl/zQ=

 membershipProof base64:
 CPrdlAIQ3IvJAxowCgoI+t2UAhD63ZQCEiIKIAM6dEBMTeEd9HcByiymv/y06auw75gvyoIlPvje/xCUGjAKCgj73ZQCEPvdlAISIgogBNZ9wTIanS0Dn9nsPRqKV26+CNjbOshsAMwvue9S6YQaMAoKCPjdlAIQ+d2UAhIiCiAIuW3oeW43msgzrFMbgCq4gK6FYjvDj/YMiIqkFthejBowCgoI/N2UAhD/3ZQCEiIKIE3TewBPm5ytAxbm8YDevOAf+I0237i9R6nqMaO3pNF4GjAKCgjw3ZQCEPfdlAISIgog9hCx+8qPP+8ZDXEgAaXO+8gOnrfLl68z6FmbWFBgXP4aMAoKCODdlAIQ792UAhIiCiDMRIXs5sbRQzByYrIWm1wiwqW9sK3MJkeJDf1oqdmdyxowCgoIwN2UAhDf3ZQCEiIKIPVClmMX6R8LQxsCoiu83M+jfdNkJeWAxcWPchSa6j9fGjAKCgiA3ZQCEL/dlAISIgoguoxg/LSs5MZlgv2ueFXeXrOZJ7HMLaKP8H/Wrf3mH7QaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKILYd4omynw8PpEsVuO17wi9G0vk1cycjXNE0L9oh8S57GiIKIPT5VxK73iV+oIG7uOfhP5LRBJyjGuTh1s27AgvmtY8JIlYKVL4Tgc7kES6rhW9h5losK8dGnDgGM3RegFRMRaqh9BiNpysWIuAL+C53Yplt7ncOvfjf4gnFuMjtIqMIKJRVClVdLB5W/lHg3lzYCfGuFb1z/f8BACpECkLDVj/HcRRgF7UCN7I+s9Y06H24hI9CKb2imzsndBglT30Y1jEecJDkyl0MP8b+QkAYDMuiVZ6LuDQufCtxh7219tgyNwoiCiB24KJBLfM+CzzIVvsat/HIczoqWtq9l6MTVkJy2tUAVBG9gscj6YPjAhoI6KD4ll8iNuI=

 membershipProof base64:
 CPTdlAIQ3IvJAxowCgoI9N2UAhD03ZQCEiIKIGr73HyTXePCs767oyquqyKAp84CRH7kcyFuV0N68IRrGjAKCgj13ZQCEPXdlAISIgogi6PE7yZnBV53HzDrIbG+Y5eKvrPydUI/ePHqJz+kf7kaMAoKCPbdlAIQ992UAhIiCiAp8ICrga2q4k2vV12etDJQ4yJijVFKS4U/8kRy+hIA3RowCgoI8N2UAhDz3ZQCEiIKIJnuWZtxOCi8nzD5Lg8Y9o5AQEjJcKPKH5iVwgduflvQGjAKCgj43ZQCEP/dlAISIgog9ZcDYG1QY17KxNse98cC/Wnn72dS18d47hczRZCQ6/gaMAoKCODdlAIQ792UAhIiCiDMRIXs5sbRQzByYrIWm1wiwqW9sK3MJkeJDf1oqdmdyxowCgoIwN2UAhDf3ZQCEiIKIPVClmMX6R8LQxsCoiu83M+jfdNkJeWAxcWPchSa6j9fGjAKCgiA3ZQCEL/dlAISIgoguoxg/LSs5MZlgv2ueFXeXrOZJ7HMLaKP8H/Wrf3mH7QaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 txOut serializedData base64:
 EiIKINqr/AbeVo9yfjFl0dRzPZZ8Su2K+IWFmfULR6buOEAVGiIKIPoRN8alUuKW1T+3I98xeehlUivGMpwIF6Iephn6RTIBIlYKVM1PBj3x26yBu0qXD7l5Cty4k7WV4AjCMTnfFQGhdhnnc9mQAt6mN/3GnAsFZGShR7CvVfylV6pwCfBC45dcdEpCeNrN4bQ0Gcu8DWtigLQb1NcBACpECkIdaQGM4wn7WFkTxDiYkwhU3Jf1/mx6yhIrIc1SoO/yjfFKHnTmphYoAsXUWr9QuOTpP/aoJWb8jaCCyAF35unh7dEyNwoiCiDEqsZDfGbDfDpCqMfiKOTDYlfPSDcMgG7eI3st7qX3URHKvT+4sALsNRoICzf8Q+4dgEY=

 membershipProof base64:
 CIDelAIQ3IvJAxowCgoIgN6UAhCA3pQCEiIKIPuZl7w6Ucl2TxD8R7ND8S9HBE6JDUDB3E6CsqmQpoelGjAKCgiB3pQCEIHelAISIgogxa2dYkfV7nychc/NU2DRJnpNpFAnMkoXph8Gaegzz2YaMAoKCILelAIQg96UAhIiCiB7+xZ25qvXcl/3au4IKxBjSheA5BoyituV7kOdAgP4uRowCgoIhN6UAhCH3pQCEiIKILGslLJRMWTSEC28UZhXjEdtRhUvC1SVpGOuI9GXJkWMGjAKCgiI3pQCEI/elAISIgoggVia5Vvi4D8zWcAL5o7TUOd5un3ljsYVExPxsC8WnTwaMAoKCJDelAIQn96UAhIiCiAuF6EC1Qj7sfERgzkO9q14Bva/jBpZIpKQDNlYgauJFRowCgoIoN6UAhC/3pQCEiIKIEf20XGd+vH4CHkL/wtzxldjlrDQ/dqR4znM+1DtW/sEGjAKCgjA3pQCEP/elAISIgogOpJ0cDFEiKOPwyI8JDAOB/wGtmSOAOe3pQxs1BbpOeoaMAoKCIDflAIQ/9+UAhIiCiD6koX5S4/N1FWSm3CWhLnqdPojuZTM+UP4RWW80aRXiBowCgoIgNyUAhD/3ZQCEiIKIAZPt0fMRG2BHchB3qG8ZkmNOVDud1ESYikZzbr2j/RnGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogXrvvuZebK1SJ22Ttvl/9F61g2DoegvwupocJMdjiRu4aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k=
 2024-01-11T16:24:49-0800 debug com.mobilecoin : TransactionBuilder.swift:189:build(context:inputs:possibleTransaction:presignedInput:) - :::PreparedTxInput
 2024-01-11T16:24:49-0800 debug com.mobilecoin : TransactionBuilder.swift:190:build(context:inputs:possibleTransaction:presignedInput:) -
 */
extension Transaction.Fixtures.BuildTxTestNet {
    fileprivate static var defaultBlockVersion = BlockVersion.minRTHEnabled

    // TODO
    /**
    
     2024-01-11T16:54:19-0800 debug com.mobilecoin : TransactionBuilder.swift:187:build(context:inputs:possibleTransaction:presignedInput:) - PreparedTxInput:
     knownTxOut:
     KnownTxOut:

     ledgerTxOut: LedgerTxOut
     LedgetTxOut:

     txOut: PartialTxOut:
     PartialTxOut

     encryptedMemo: Data66 base 64 DcunL2+v248PqyQ7RG8AQKONJ+lA4wKIkOuIpcnOMKRDHl837UdMHllJgh1xQePulv0dsHOZ7MCtWfiz5cKxTQT1
     maskedAmount: MaskedAmount:
     MaskedAmount:

     maskedValue: UInt64 17792466809847936602
     maskedTokenId: Data base64 EC9Fg2/A4JE=
     commitment: Data32 base64 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
     version: Version Version 2

     targetKey: RistrettoPublic base64 uI3cGUyMcR84o6le4TOGXQQAG2W5ewmiGtdS3ZIRY1s=
     publicKey: RistrettoPublic base64 WjPg2BFIBHDstggSjcxRgifgtaOu1ovMV51zyAbMpUs=
     commitment: Data32 base64 { AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA= }

     globalIndex: UInt64 4533908
     block: BlockMetadata
     BlockMetadata:

     index 1493080
     timestamp unix Optional(1677540712.0)

     
     */
    fileprivate static func inputs() throws -> [PreparedTxInput] {
        let knownTxOut_1 = try XCTUnwrap(KnownTxOut(
            LedgerTxOut(
                PartialTxOut(
                    encryptedMemo: Data66(base64Encoded: "DcunL2+v248PqyQ7RG8AQKONJ+lA4wKIkOuIpcnOMKRDHl837UdMHllJgh1xQePulv0dsHOZ7MCtWfiz5cKxTQT1")!,
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
            accountKey: try XCTUnwrap(AccountKey(serializedData: Data(base64Encoded: "CiIKIMM0eFjAenKpb/qWCpMpLBobETadGuaJCNy45N0Ej7sPEiIKIEU+8R66uCyb7xsVbX9qAPUa6cTxIpeQNIEQFoPbWFUKGh1mb2c6Ly9mb2cudGVzdC5tb2JpbGVjb2luLmNvbSqmBDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL5wfcE20zk+bqIs0WGmG8O1yBJCJ5fBOzBjgEI/sZwvhdayF4gp3P7dfuSCFo20RoVs6O0QMCObEWo59rE+K0Z/TV2zs2TLyKhOIZoZhM8tWEDQ53wCwFjUPlgW2BlvlaptyJULwBRY1TdWGCHWIWy4wD3ZIHlbFn3Cw36Kx5+q0d0AWWGSJUgUEikTGP7csE8Xkwryts1nEtJG2xT7QXFbYe1RRVTwGV4T4vcstQL55XTup+yi4rqVZqI5RDLb+BUJJOtOJ2pfo/3TqZUwE1fGvQCQWz0QWf8kIOexBtmNjEYhzkInycdEuVWzcjJvW5EvEw+xqIufWglujk9YMnqLVsC4OtCUWU38ie5WFgUjs4dDp2gsrUaUlrTWem2qz1Hjp37W5ybRPKxYRezOBeunrdCyP3Lr12HnMFcMpKLxFQSkReBzivRoEpte5kDLc6w+3OefE22rnDlmm2EdOLoXQHN7NdDJLjjVhtMCEIYCAoWFQBpxS70qadv2kBKt8a0UhE8bIsVCI7GcllkTpLgNCBZ3PHewJnJ1Ab0VuxU/+bYVspOWoHWFBmfuwtaOvYoUdWMZqBoevXyzDyBDoWIee9vt3JIJdkmleLqPRr5M/DDBkQXDCDJUYq0sIQn6M1dkck+Vp9TYD6cnPMyS+0HToS+0MW/uVo5wla0GByNnAgMBAAE=")!))))

        // TODO
        let ring_1: [(TxOut, TxOutMembershipProof)] = try [
            (
            "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"
            ),

            (
            "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"
            ),

            (
            "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"
            ),

            (
            "EiIKIBKNPlhpB+MS6xGRAiY+4cmqqyKGd6V4hnoXLtwVctIDGiIKIFCecgH/rItax+7b8RPDgCEtiYv1doemZEYAXtvNTRlSIlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACpECkKReUqbQRzgoicm5q5RSGR9wpx+DoIQhedwBRE0F7Tlpcs8rPitRSydtOoFs/iifcTuBS2YtVdk4cKnBf1/k7ievQsyNwoiCiBaoS3AaMTJkMJHwH/bUO+VwsG2D06kOWsSlvbgTsKuKRE3mDinDASiKRoI9fc25pXeqTE=",
            "COXclAIQio3JAxowCgoI5dyUAhDl3JQCEiIKIG+PTYGMMove+K5oWbe4rxYU5vtrXdXXYY4Vi8WiIZ99GjAKCgjk3JQCEOTclAISIgogFIpNxFOxHldaInIYo+8V7V74lLfgrN4ZE7tqcmt4GoMaMAoKCObclAIQ59yUAhIiCiC7tULEoxwEubfIl0ZZI8XTpx+gtZClD2V/6qGiAIKFZRowCgoI4NyUAhDj3JQCEiIKIOx5kWjpIeSRdIjhZjmK0CuRlg0E3MUW4FiO2hhFWpdVGjAKCgjo3JQCEO/clAISIgog1WwYGvxg/rpEfExG9Br8KhVyCanmF2wDRha2aMa9NSIaMAoKCPDclAIQ/9yUAhIiCiC740M2yUqHjGay/SPe55WpDG3L/uzFJ3gKF8pdeh9JMxowCgoIwNyUAhDf3JQCEiIKIHRuI8xC+qYgDWW2tvXZYbqSi3Z5u1PEQ+4JlUZO09kwGjAKCgiA3JQCEL/clAISIgogr3Z7tfLq6a5kZQ8a9Qbtke9192uT6HXwYKAkPVxctjEaMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32ziRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogny4V0Z3jAicBsS9t9rXHTmeYRKNqvwqT0vBR5o5jLW8aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k="
            ),

            (
            "EiIKILiN3BlMjHEfOKOpXuEzhl0EABtluXsJohrXUt2SEWNbGiIKIFoz4NgRSARw7LYIEo3MUYIn4LWjrtaLzFedc8gGzKVLIlYKVJuduk/rOC2UW3mha2lABGb+aWBsB+3sFPhYHhS8c/xD9XOUrFm8EtEXmej389ZCiliRtbBCCN2Td8JAjMGNPxJ1DmwXFjSb+Keovov5gUkWwbMBACpECkINy6cvb6/bjw+rJDtEbwBAo40n6UDjAoiQ64ilyc4wpEMeXzftR0weWUmCHXFB4+6W/R2wc5nswK1Z+LPlwrFNBPUyNwoiCiBCsIdsaNtM+gW4eedzCzXZUZa+qluXIvvGdXil33G0CBFa9umGS4rr9hoIEC9Fg2/A4JE=",
            "CJTdlAIQio3JAxowCgoIlN2UAhCU3ZQCEiIKIG7g61YiysaTfeuTRReMfP/AAue7+NOee1ywjP6KwH/GGjAKCgiV3ZQCEJXdlAISIgog7M4kvFAF9RqOsNQ7gH0cFdlkWR0u13WR2t+GGRprhIYaMAoKCJbdlAIQl92UAhIiCiAYYMCCvyQZdI2ApjpGUThaVuuHvtm7P9ErdOKQEfC68BowCgoIkN2UAhCT3ZQCEiIKIC9AeEEReXg44I2do2rQpvm5L/B/PCY0fQydN3IptInoGjAKCgiY3ZQCEJ/dlAISIgogSfoptOxb1J3TdKqNiF8M5bJSE4ilbKTtsvT00NuupeMaMAoKCIDdlAIQj92UAhIiCiAiips/UPOfwvvu9EV5mFWZlIyoQvAlvIMgGLqic4sRQRowCgoIoN2UAhC/3ZQCEiIKIK4PwbvI3U+ej/ouOmAbU2hnj+vwz/bCKBR1/nhkBTfQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogny4V0Z3jAicBsS9t9rXHTmeYRKNqvwqT0vBR5o5jLW8aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k="
            ),

            (
            "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"
            ),

            (
            "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"
            ),

            (
            "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"
            ),

            (
            "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"
            ),

            (
            "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"
            ),

            (
            "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"
            ),
        ].map {
            (
                try XCTUnwrap(TxOut(serializedData: XCTUnwrap(Data(base64Encoded: $0.0)))),
                try XCTUnwrapSuccess(
                    TxOutMembershipProof.make(serializedData: XCTUnwrap(Data(base64Encoded: $0.1))))
            )
        }

        let knownTxOut_2 = try XCTUnwrap(KnownTxOut(
            LedgerTxOut(
                PartialTxOut(
                    encryptedMemo: Data66(base64Encoded: "/hpC0EFCnzx2WLLSORctFy/a15YkNAZv04NFU9EJZuhdJI+CtfZDcAEz+6tPtpb45THnT1rydm48sjsdmhd1Q2xQ")!,
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
            accountKey: try XCTUnwrap(AccountKey(serializedData: Data(base64Encoded: "CiIKIMM0eFjAenKpb/qWCpMpLBobETadGuaJCNy45N0Ej7sPEiIKIEU+8R66uCyb7xsVbX9qAPUa6cTxIpeQNIEQFoPbWFUKGh1mb2c6Ly9mb2cudGVzdC5tb2JpbGVjb2luLmNvbSqmBDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL5wfcE20zk+bqIs0WGmG8O1yBJCJ5fBOzBjgEI/sZwvhdayF4gp3P7dfuSCFo20RoVs6O0QMCObEWo59rE+K0Z/TV2zs2TLyKhOIZoZhM8tWEDQ53wCwFjUPlgW2BlvlaptyJULwBRY1TdWGCHWIWy4wD3ZIHlbFn3Cw36Kx5+q0d0AWWGSJUgUEikTGP7csE8Xkwryts1nEtJG2xT7QXFbYe1RRVTwGV4T4vcstQL55XTup+yi4rqVZqI5RDLb+BUJJOtOJ2pfo/3TqZUwE1fGvQCQWz0QWf8kIOexBtmNjEYhzkInycdEuVWzcjJvW5EvEw+xqIufWglujk9YMnqLVsC4OtCUWU38ie5WFgUjs4dDp2gsrUaUlrTWem2qz1Hjp37W5ybRPKxYRezOBeunrdCyP3Lr12HnMFcMpKLxFQSkReBzivRoEpte5kDLc6w+3OefE22rnDlmm2EdOLoXQHN7NdDJLjjVhtMCEIYCAoWFQBpxS70qadv2kBKt8a0UhE8bIsVCI7GcllkTpLgNCBZ3PHewJnJ1Ab0VuxU/+bYVspOWoHWFBmfuwtaOvYoUdWMZqBoevXyzDyBDoWIee9vt3JIJdkmleLqPRr5M/DDBkQXDCDJUYq0sIQn6M1dkck+Vp9TYD6cnPMyS+0HToS+0MW/uVo5wla0GByNnAgMBAAE=")!))))

        // TODO
        let ring_2: [(TxOut, TxOutMembershipProof)] = try [
            (
            "EiIKIEyIknNZxwGOaVh1psufdiFQWYDkLraYOIdkH653O7YjGiIKICgpXb6rJcz8qVyLO9M6UgHWtsW6cju0CMjEHDj7XHMfIlYKVFeCqwEocFEWh7gbDBBflySBkhxns3tWO10Yw6/P+u27Ix+CEO5mB9JTL5MmndEsaxrTLR543YQcKvQyGUwF2dVffqWNTdxgRXYJJQEdr/iobRwBACpECkIyy6pyrsmyZuQMp+YVWne16vMqZLo0aYA48raWgk3GBWD6L4iQH5VlgP6xK3hT0YeFDUTZoj8ec1AQFHEORwKdvOsyNwoiCiCC8srlRf0pikHw62V98qkTUpXHFR98vTk+ZalJhj8eahHydIdVqImFwxoIqhcxR/C2mOY=",
            "CMjdlAIQio3JAxowCgoIyN2UAhDI3ZQCEiIKIKEku54N2oVq6LvKFTdCqBjJu7QRnhvjM/ExInD+df9hGjAKCgjJ3ZQCEMndlAISIgogbvZ8cBrJ1mqhVxf49z5u2lH08auvmgWQI4Qg+tmByYYaMAoKCMrdlAIQy92UAhIiCiBe7wPEe7YBY99+8EyP7lAJft6nRboUAOhbIpWxg0kSahowCgoIzN2UAhDP3ZQCEiIKII/W/Fw5gHmZjGpYM5uVtWivEfWPmeUAzOtA5PGMGggtGjAKCgjA3ZQCEMfdlAISIgogfVTDgSVOixRdCu40VHRnnK113PvgB5VAJ5PNYXUw+KAaMAoKCNDdlAIQ392UAhIiCiBSfExE2qKyt6zUMfS4uFnV/t2uS6UQZ8hM2vSgq8X3NhowCgoI4N2UAhD/3ZQCEiIKILvhh4/+pNKDDoNqpNcYOMIZppCizGXRmIE/Q6q9VgXCGjAKCgiA3ZQCEL/dlAISIgoguoxg/LSs5MZlgv2ueFXeXrOZJ7HMLaKP8H/Wrf3mH7QaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogny4V0Z3jAicBsS9t9rXHTmeYRKNqvwqT0vBR5o5jLW8aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k="
            ),

            (
            "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"
            ),

            (
            "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"
            ),

            (
            "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"
            ),

            (
            "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"
            ),

            (
            "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"
            ),

            (
            "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"
            ),

            (
            "EiIKINa6i94DqN8F5VeydRe5JPsPzMcB3TzBwmxWb2sol+kUGiIKINoFy0xIXGAoPsjks+R3Gyq+PxYH5dQKXTV5rhFRb10tIlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACpECkKEjeoFB4HIEgvJ8D5nYA/4xcRZX5a6NvtXeWjAJCwF9T2tSIKsRRmUknj5dUFFZbWz3DFTsffa/CcLafvB5wugXrEyNwoiCiBgOyVtKzNopGcb+TWsIqc2aG+jC0i94+L1HIpJgxBVHBH41PIgMr/sGRoIcSWRyZcOqvA=",
            "CL3clAIQio3JAxowCgoIvdyUAhC93JQCEiIKIGKFzxfIH8Izr384kHTyct7zUZWMhuSh2r0ML33lyqbgGjAKCgi83JQCELzclAISIgogPGDPolbBYUvgzI2k/S4ZPtW1WiV/RIqwA8dryVwhakgaMAoKCL7clAIQv9yUAhIiCiC1FCM7gFJoGZHcKpaX7dddY0MgsD9ZE6BXPQYulPV+/BowCgoIuNyUAhC73JQCEiIKINrriD9yTKKhUP8EaJ7azajeadWewTSe4JAh62SwyFClGjAKCgiw3JQCELfclAISIgogXfzVLEYCCAKv3msg2UFKTzAdYEWHO5t5Y90sRxdQz4gaMAoKCKDclAIQr9yUAhIiCiAV8/6bGofq3Z0OpMTnOBkWGqsPa4PRKA0Oxg6Ys+TGahowCgoIgNyUAhCf3JQCEiIKIJL38h3bULz8rl8WtOWcoNCAEJI6QdXiaegG+7btiybgGjAKCgjA3JQCEP/clAISIgogid4dV7iW9EuJlxGSuXTnagmXXpoH7ACvXRCADeSAp74aMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32ziRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogny4V0Z3jAicBsS9t9rXHTmeYRKNqvwqT0vBR5o5jLW8aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k="
            ),

            (
            "EiIKIIQI7Lkryx+71k00Umv8TCfOYSrniWCBmG+HkPyMUWAAGiIKIORR7LOdU2xwtdGTYBonQQumifX3TihmrxGcmiAmYdQcIlYKVHpZ91CEobGtmdEH8mtMqFxoKk5QrctU57GIgCPltGSgyURmxxmtnzQGgy69TnvEZXsRms7OgyVQcQuO6a4MOXKuXtEkxmkO4L/076jaIfE20M4BACpECkLpSTK6IocHk3k8hVHbfTpCXccj1gYsFxGAsz+ax4eASaOGJB2FR6fNqVc1IDf+BMCJ3M9t1TIqIBF/CLd9XiyQtOUyNwoiCiDuO5ntPyhM9c8PAGa38ha51u24cQpc6R2IwLOzxmK8eBFzYiuXAOIMERoIQH4cNWOyo1k=",
            "CNHclAIQio3JAxowCgoI0dyUAhDR3JQCEiIKIBUrDiWS9Z7QIdzUNvOZ61/m4Iuhl4sjcwYyPQyFUd+rGjAKCgjQ3JQCENDclAISIgogzkXREUGZm9a7mGGPB06kuPf3DkyJWR3ceGEg0L8LX3QaMAoKCNLclAIQ09yUAhIiCiBLl/8IqRhjXU8b5R08GDdcStBmzJPoWtcCu6CmMwdKuhowCgoI1NyUAhDX3JQCEiIKILt9xhySoY0U/rjcav5YfOZoNEtO1M61fJK5My1E5swWGjAKCgjY3JQCEN/clAISIgog/KpgCFKD1f5tPXX/giIX11oULb4w6RMsZKQGY++qhAkaMAoKCMDclAIQz9yUAhIiCiCTjavBee+eRRfeTRUZmnO8iPLPAViSbeqhUJsAR+GEIxowCgoI4NyUAhD/3JQCEiIKIDXYv597nUABiIoj10DFLze7C7L4GA9DdMm8h0EIyvwrGjAKCgiA3JQCEL/clAISIgogr3Z7tfLq6a5kZQ8a9Qbtke9192uT6HXwYKAkPVxctjEaMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32ziRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogny4V0Z3jAicBsS9t9rXHTmeYRKNqvwqT0vBR5o5jLW8aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k="
            ),

            (
            "EiIKIKqPEroVZIaWW6V/ELsdB7jwMAZHaaf9q/Yf9leU4ntiGiIKIPpUIVEGu/99BFgQg3llo+Raxb3BfucwbF3tC7JfmzkNIlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACpECkKhof2MyKjKXfm8KTmdS7B1FBZBZRDO6b8JYL7SSbKHgL4uZ3hOlK7Aj3/IbUOJ9BdyIGSCG3wvJtO3DwvYvBfxre4yNwoiCiB0VVmpQrAzX1YXVdhiduk04384TDDSXn6M0sXCjGwHUxE/gi8Z06y6IRoI9+/7gLJpjlM=",
            "CJndlAIQio3JAxowCgoImd2UAhCZ3ZQCEiIKIItZaF0kcWe0TeR0Xa1yVhJKPdgT77YYkdubVfN0JsU1GjAKCgiY3ZQCEJjdlAISIgoghI6oiQGlbwasBK4oP3Sd0gzgS+nALHwnmKPQl0uR0CYaMAoKCJrdlAIQm92UAhIiCiA6vYqNghv94ehD1XoK5iTxuA31B9yqfo0vZ5XvzN4SPxowCgoInN2UAhCf3ZQCEiIKIHEfL6yXiNDxkqNlvso3aV1Y2VgQLmGEPuu0Vzk5x0VlGjAKCgiQ3ZQCEJfdlAISIgogrkdvHxiYJgLvJPE2raLF09Bz7LcET0InUPjbyw4D6qEaMAoKCIDdlAIQj92UAhIiCiAiips/UPOfwvvu9EV5mFWZlIyoQvAlvIMgGLqic4sRQRowCgoIoN2UAhC/3ZQCEiIKIK4PwbvI3U+ej/ouOmAbU2hnj+vwz/bCKBR1/nhkBTfQGjAKCgjA3ZQCEP/dlAISIgoggTxwcviL7TSMDl5EJPMstA3s/C+m4zKulfoCZStp7vkaMAoKCIDclAIQ/9yUAhIiCiD3hi+Xbp3EOjMZvHFjeHojWznTF6UzkDYCNo5m4cAyphowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogny4V0Z3jAicBsS9t9rXHTmeYRKNqvwqT0vBR5o5jLW8aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k="
            ),

            (
            "EiIKIBig0DDeJM8CKzwtEXX9ssru23JLPNUOAHCk56SbnE16GiIKIPzi9TBJ+sJOvaXclf3bwr2GEa2xMsF13gN/LeLvPXsYIlYKVAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACpECkJ1KArLFxhg/WWicJcQfoyKfW+dMQBZuC0OWgrQpxCicjKT5zHkFRzTJwldJcAqkFJyvkMIiZS7tO1f6eb/oeBkGZoyNwoiCiCO5n/xjbjWtFgEChfkf+aWnkK7hb5jLYTYzKp77MY+dxH8UQovsrp7yRoI/nLG0CsD/4U=",
            "COzclAIQio3JAxowCgoI7NyUAhDs3JQCEiIKIOKtt49VRNzZveHQOCQ9sz/wEkUjJvxldJqolZoFt+B+GjAKCgjt3JQCEO3clAISIgoginbAgyckGS3W+HQ/GfQRbHfJXO4d9RQjndix6TJfuYcaMAoKCO7clAIQ79yUAhIiCiAKelZaa+waTKeIuHGe4+f3PPDtfYAQ2z98KTo4xBWmMxowCgoI6NyUAhDr3JQCEiIKIKoHzUjR+bdQ6pH5k+alNGp1x5zkUQpVZewbFOivNA+BGjAKCgjg3JQCEOfclAISIgogZRuNIskb4vBIuTCMXISSHz0ZK9mrQAWpqkH0O/p/3ncaMAoKCPDclAIQ/9yUAhIiCiC740M2yUqHjGay/SPe55WpDG3L/uzFJ3gKF8pdeh9JMxowCgoIwNyUAhDf3JQCEiIKIHRuI8xC+qYgDWW2tvXZYbqSi3Z5u1PEQ+4JlUZO09kwGjAKCgiA3JQCEL/clAISIgogr3Z7tfLq6a5kZQ8a9Qbtke9192uT6HXwYKAkPVxctjEaMAoKCIDdlAIQ/92UAhIiCiDTfLeuccfyHkaBZPfhg0YIeGWkxIlxbhx+KJKVk32ziRowCgoIgN6UAhD/35QCEiIKIBwEw0motZtNt6XFN5D+Wo/AS8AyDGy/P7q6PRKDFN9nGjAKCgiA2JQCEP/blAISIgogZGeJNzqwbEZNyTcEAcvj8IX9V4312sDkRQSTH7gb4UQaMAoKCIDQlAIQ/9eUAhIiCiB7z29AbdZm7GATv9O5bSEzi2U9bFi2k/1M4++dXgUukRowCgoIgMCUAhD/z5QCEiIKINhEIC4bPsgEsHgEoDTPOTW74pCUcyhViMjf9WxgJRfZGjAKCgiA4JQCEP//lAISIgog1Vg9A8Jl9DnGv+GpDvCXnoprYr0IDEq3uJo0i4SKB74aMAoKCICAlAIQ/7+UAhIiCiAihgBa4TL2CNLc9dXDJ+wudr6mOE2JIr+OGiDyx7WGLxowCgoIgICVAhD//5UCEiIKIMRnrZbAi8durDbxeIlRXZAVA3KcqZajWoDybZXAX+SxGjAKCgiAgJYCEP//lwISIgogCGY3hKTok+6SQSagIjGAljuexVMH2dIpfs7zf0jJ2MwaMAoKCICAkAIQ//+TAhIiCiD3pwUiZ1G3bbQXsuFQEITMDEpjq/epchKMMpZE84RpZxowCgoIgICYAhD//58CEiIKIL2ZuHwyEjygKYxa23PalV8u6TuKScv0xkTErHvb4V6/GjAKCgiAgIACEP//jwISIgogOuWOifZLxZdnHM9cJRNxt7klsgf5RS8kBk/aVbnol8YaMAoKCICAoAIQ//+/AhIiCiBiyOUxbUKOdinjnsdLiIQLf9IcsdSXiWBNOfz7F0Ej3howCgoIgIDAAhD///8CEiIKIGdQOJFwmHWMImpOZfLnCXJt4Z4X1nEDXuaQFZQZimirGjAKCgiAgIADEP///wMSIgogny4V0Z3jAicBsS9t9rXHTmeYRKNqvwqT0vBR5o5jLW8aKwoFEP///wESIgog5ShKUJJkphosZeKgYNWqZ0XGnItivJ8FzYeNyfWka4k="
            )
        ].map {
            (
                try XCTUnwrap(TxOut(serializedData: XCTUnwrap(Data(base64Encoded: $0.0)))),
                try XCTUnwrapSuccess(
                    TxOutMembershipProof.make(serializedData: XCTUnwrap(Data(base64Encoded: $0.1))))
            )
        }
        
        return [try PreparedTxInput.make(knownTxOut: knownTxOut_1, ring: ring_1).get(), try PreparedTxInput.make(knownTxOut: knownTxOut_2, ring: ring_2).get()]
    }

    fileprivate static func accountKey() throws -> AccountKey {
        let rootAccountKey = try XCTUnwrap(AccountKey(serializedData: Data(base64Encoded: "CiIKIMM0eFjAenKpb/qWCpMpLBobETadGuaJCNy45N0Ej7sPEiIKIEU+8R66uCyb7xsVbX9qAPUa6cTxIpeQNIEQFoPbWFUKGh1mb2c6Ly9mb2cudGVzdC5tb2JpbGVjb2luLmNvbSqmBDCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAL5wfcE20zk+bqIs0WGmG8O1yBJCJ5fBOzBjgEI/sZwvhdayF4gp3P7dfuSCFo20RoVs6O0QMCObEWo59rE+K0Z/TV2zs2TLyKhOIZoZhM8tWEDQ53wCwFjUPlgW2BlvlaptyJULwBRY1TdWGCHWIWy4wD3ZIHlbFn3Cw36Kx5+q0d0AWWGSJUgUEikTGP7csE8Xkwryts1nEtJG2xT7QXFbYe1RRVTwGV4T4vcstQL55XTup+yi4rqVZqI5RDLb+BUJJOtOJ2pfo/3TqZUwE1fGvQCQWz0QWf8kIOexBtmNjEYhzkInycdEuVWzcjJvW5EvEw+xqIufWglujk9YMnqLVsC4OtCUWU38ie5WFgUjs4dDp2gsrUaUlrTWem2qz1Hjp37W5ybRPKxYRezOBeunrdCyP3Lr12HnMFcMpKLxFQSkReBzivRoEpte5kDLc6w+3OefE22rnDlmm2EdOLoXQHN7NdDJLjjVhtMCEIYCAoWFQBpxS70qadv2kBKt8a0UhE8bIsVCI7GcllkTpLgNCBZ3PHewJnJ1Ab0VuxU/+bYVspOWoHWFBmfuwtaOvYoUdWMZqBoevXyzDyBDoWIee9vt3JIJdkmleLqPRr5M/DDBkQXDCDJUYq0sIQn6M1dkck+Vp9TYD6cnPMyS+0HToS+0MW/uVo5wla0GByNnAgMBAAE=")!))

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
extension Transaction.Fixtures.ExactChange {
    fileprivate static func outputs() throws
        -> [TransactionOutput]
    {
        let posAmt = try XCTUnwrap(PositiveUInt64(2499990000000000 - 10_000_000_000))
        let output =
            TransactionOutput(
                recipient: try PublicAddress.Fixtures.Default(accountIndex: 1).publicAddress,
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
