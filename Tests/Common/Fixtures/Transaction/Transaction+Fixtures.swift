//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable file_length multiline_function_chains force_unwrapping function_body_length

import LibMobileCoin
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
                    commitment: Data32(base64Encoded:
                        "uImiYd/FgPnNUbRkBu5+F61QNO4DXF8NNCPIzKy/2UA=")!,
                    maskedValue: 2886556578342610519,
                    maskedTokenId: McConstants.LEGACY_MOB_MASKED_TOKEN_ID,
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
            fogReportUrl: try AccountKey.Fixtures.Init().fogReportUrl,
            fogReportId: try AccountKey.Fixtures.Init().fogReportId,
            fogAuthoritySpki: try AccountKey.Fixtures.Init().fogAuthoritySpki).get()
    }

    fileprivate static func outputs() throws
        -> [TransactionOutput]
    {
        [
            TransactionOutput(
                recipient: try PublicAddress.Fixtures.Default(accountIndex: 1).publicAddress,
                amount: try XCTUnwrap(PositiveUInt64(10))
            ),
            TransactionOutput(
                recipient: try PublicAddress.Fixtures.Default(accountIndex: 2).publicAddress,
                amount: try XCTUnwrap(PositiveUInt64(2499979999999990))
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
        [
            TransactionOutput(
                recipient: try PublicAddress.Fixtures.Default(accountIndex: 1).publicAddress,
                amount: try XCTUnwrap(PositiveUInt64(2499990000000000 - 10_000_000_000))
            ),
        ]
    }

}

extension Transaction.Fixtures.Serialization {

    fileprivate static func serializedData() throws -> Data {
        try Data(contentsOf: Bundle.url("TransactionSerializedData", "bin"))
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
