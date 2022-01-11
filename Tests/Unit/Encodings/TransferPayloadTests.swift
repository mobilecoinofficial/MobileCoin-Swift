//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class TransferPayloadTests: XCTestCase {

    // The base64Encoded string below will decode to 32 bytes of data for a valid Data32
    static var entropyData = Data(base64Encoded: "ajaEQTHHDeZEZDk1rGYQRF0ErcpmcPa7buRpNchz4hQ=")!
    static let entropyData32 = Data32(entropyData)!
    static let ristretto = RistrettoPublic(base64Encoded:
                                            "VECBlIdhtmTFaXtlWphlqELpDL04EKMbbPWu3CoJ2UE=")!
    static let ristrettoCompressed = External_CompressedRistretto(ristretto)
    static let memo = "test memo"

    func testEncodingToPrintableWithBip39NoMemo() throws {
        XCTAssertNoThrow(evaluating: {
            // create TransferPayload
            let transferPayload = TransferPayload(
                bip39: Self.entropyData32,
                txOutPublicKey: Self.ristretto)
            XCTAssertNotNil(transferPayload)

            // create Printable_TransferPayload from TransferPayload
            let printableTransferPayload = Printable_TransferPayload(transferPayload)

            // Validate
            XCTAssertNotNil(printableTransferPayload)
            XCTAssertEqual(printableTransferPayload.rootEntropy.data.count, 0)
            XCTAssertEqual(printableTransferPayload.bip39Entropy, Self.entropyData)
            XCTAssertEqual(printableTransferPayload.txOutPublicKey,
                           Self.ristrettoCompressed)
            XCTAssertEqual(printableTransferPayload.memo.count, 0)
        })
    }

    func testDecodingFromPrintableWithBip39NoMemo() throws {
        XCTAssertNoThrow(evaluating: {
            // create Printable_TransferPayload
            var printableTransferPayload = Printable_TransferPayload()
            printableTransferPayload.bip39Entropy = Self.entropyData
            printableTransferPayload.rootEntropy = Data()
            printableTransferPayload.txOutPublicKey = Self.ristrettoCompressed

            // create TransferPayload from Printable_TransferPayload
            let transferPayload = TransferPayload(printableTransferPayload)
            
            // Validate
            XCTAssertNotNil(transferPayload)
            if let transferPayload = transferPayload {
                XCTAssertNil(transferPayload.rootEntropy32)
                XCTAssertEqual(transferPayload.bip39_32, Self.entropyData32)
                XCTAssertEqual(transferPayload.txOutPublicKey, Self.ristretto)
                XCTAssertNil(transferPayload.memo)
            }
        })
    }

    func testEncodingToPrintableWithBip39AndMemo() throws {
        XCTAssertNoThrow(evaluating: {
            // create TransferPayload
            let transferPayload = TransferPayload(
                bip39: Self.entropyData32,
                txOutPublicKey: Self.ristretto,
                memo: Self.memo)
            XCTAssertNotNil(transferPayload)

            // create Printable_TransferPayload from TransferPayload
            let printableTransferPayload = Printable_TransferPayload(transferPayload)

            // Validate
            XCTAssertNotNil(printableTransferPayload)
            XCTAssertEqual(printableTransferPayload.rootEntropy.data.count, 0)
            XCTAssertEqual(printableTransferPayload.bip39Entropy, Self.entropyData)
            XCTAssertEqual(printableTransferPayload.txOutPublicKey, Self.ristrettoCompressed)
            XCTAssertEqual(printableTransferPayload.memo, Self.memo)
        })
    }

    func testDecodingFromPrintableWithBip39AndMemo() throws {
        XCTAssertNoThrow(evaluating: {
            // create Printable_TransferPayload
            var printableTransferPayload = Printable_TransferPayload()
            printableTransferPayload.bip39Entropy = Self.entropyData
            printableTransferPayload.rootEntropy = Data()
            printableTransferPayload.txOutPublicKey = Self.ristrettoCompressed
            printableTransferPayload.memo = Self.memo

            // create TransferPayload from Printable_TransferPayload
            let transferPayload = TransferPayload(printableTransferPayload)

            // Validate
            XCTAssertNotNil(transferPayload)
            if let transferPayload = transferPayload {
                XCTAssertNil(transferPayload.rootEntropy32)
                XCTAssertEqual(transferPayload.bip39_32, Self.entropyData32)
                XCTAssertEqual(transferPayload.txOutPublicKey, Self.ristretto)
                XCTAssertEqual(transferPayload.memo, Self.memo)
            }
        })
    }

    func testEncodingToPrintableWithRootEntropyNoMemo() throws {
        XCTAssertNoThrow(evaluating: {
            // create TransferPayload
            let transferPayload = TransferPayload(
                rootEntropy: Self.entropyData32,
                txOutPublicKey: Self.ristretto)
            XCTAssertNotNil(transferPayload)

            // create Printable_TransferPayload from TransferPayload
            let printableTransferPayload = Printable_TransferPayload(transferPayload)

            // Validate
            XCTAssertNotNil(printableTransferPayload)
            XCTAssertEqual(printableTransferPayload.rootEntropy, Self.entropyData)
            XCTAssertEqual(printableTransferPayload.bip39Entropy.data.count, 0)
            XCTAssertEqual(printableTransferPayload.txOutPublicKey, Self.ristrettoCompressed)
            XCTAssertEqual(printableTransferPayload.memo.count, 0)
        })
    }

    func testDecodingFromPrintableWithRootEntropyNoMemo() throws {
        XCTAssertNoThrow(evaluating: {
            // create Printable_TransferPayload
            var printableTransferPayload = Printable_TransferPayload()
            printableTransferPayload.rootEntropy = Self.entropyData
            printableTransferPayload.bip39Entropy = Data()
            printableTransferPayload.txOutPublicKey = Self.ristrettoCompressed

            // create TransferPayload from Printable_TransferPayload
            let transferPayload = TransferPayload(printableTransferPayload)

            // Validate
            XCTAssertNotNil(transferPayload)
            if let transferPayload = transferPayload {
                XCTAssertEqual(transferPayload.rootEntropy32, Self.entropyData32)
                XCTAssertNil(transferPayload.bip39_32)
                XCTAssertEqual(transferPayload.txOutPublicKey, Self.ristretto)
                XCTAssertNil(transferPayload.memo)
            }
        })
    }

    func testEncodingToPrintableWithRootEntropyAndMemo() throws {
        XCTAssertNoThrow(evaluating: {
            // create TransferPayload
            let transferPayload = TransferPayload(
                rootEntropy: Self.entropyData32,
                txOutPublicKey: Self.ristretto,
                memo: Self.memo)
            XCTAssertNotNil(transferPayload)

            // create Printable_TransferPayload from TransferPayload
            let printableTransferPayload = Printable_TransferPayload(transferPayload)

            // Validate
            XCTAssertNotNil(printableTransferPayload)
            XCTAssertEqual(printableTransferPayload.rootEntropy, Self.entropyData)
            XCTAssertEqual(printableTransferPayload.bip39Entropy.data.count, 0)
            XCTAssertEqual(printableTransferPayload.txOutPublicKey, Self.ristrettoCompressed)
            XCTAssertEqual(printableTransferPayload.memo, Self.memo)
        })
    }

    func testDecodingFromPrintableWithRootEntropyAndMemo() throws {
        XCTAssertNoThrow(evaluating: {
            // create Printable_TransferPayload
            var printableTransferPayload = Printable_TransferPayload()
            printableTransferPayload.rootEntropy = Self.entropyData
            printableTransferPayload.bip39Entropy = Data()
            printableTransferPayload.txOutPublicKey = Self.ristrettoCompressed
            printableTransferPayload.memo = Self.memo

            // create TransferPayload from Printable_TransferPayload
            let transferPayload = TransferPayload(printableTransferPayload)

            // Validate
            XCTAssertNotNil(transferPayload)
            if let transferPayload = transferPayload {
                XCTAssertEqual(transferPayload.rootEntropy32, Self.entropyData32)
                XCTAssertNil(transferPayload.bip39_32)
                XCTAssertEqual(transferPayload.txOutPublicKey, Self.ristretto)
                XCTAssertEqual(transferPayload.memo, Self.memo)
            }
        })
    }
}
