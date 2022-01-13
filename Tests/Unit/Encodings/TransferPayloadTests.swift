//
//  Copyright (c) 2022 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class TransferPayloadTests: XCTestCase {

    func testEncodingToPrintableWithBip39NoMemo() throws {
        let defaultFixture = try TransferPayload.Fixtures.Default()

        // create TransferPayload
        let transferPayload = TransferPayload(
            bip39: defaultFixture.entropyData32,
            txOutPublicKey: defaultFixture.ristretto)
        XCTAssertNotNil(transferPayload)

        // create Printable_TransferPayload from TransferPayload
        let printableTransferPayload = Printable_TransferPayload(transferPayload)

        // Validate
        XCTAssertNotNil(printableTransferPayload)
        XCTAssertEqual(printableTransferPayload.rootEntropy.data.count, 0)
        XCTAssertEqual(printableTransferPayload.bip39Entropy, defaultFixture.entropyData)
        XCTAssertEqual(printableTransferPayload.txOutPublicKey, defaultFixture.ristrettoCompressed)
        XCTAssertEqual(printableTransferPayload.memo.count, 0)
    }

    func testDecodingFromPrintableWithBip39NoMemo() throws {
        let defaultFixture = try TransferPayload.Fixtures.Default()

        // create Printable_TransferPayload
        var printableTransferPayload = Printable_TransferPayload()
        printableTransferPayload.bip39Entropy = defaultFixture.entropyData
        printableTransferPayload.rootEntropy = Data()
        printableTransferPayload.txOutPublicKey = defaultFixture.ristrettoCompressed

        // create TransferPayload from Printable_TransferPayload
        let transferPayload = TransferPayload(printableTransferPayload)

        // Validate
        XCTAssertNotNil(transferPayload)
        if let transferPayload = transferPayload {
            XCTAssertNil(transferPayload.rootEntropy32)
            XCTAssertEqual(transferPayload.bip39_32, defaultFixture.entropyData32)
            XCTAssertEqual(transferPayload.txOutPublicKey, defaultFixture.ristretto)
            XCTAssertNil(transferPayload.memo)
        }
    }

    func testEncodingToPrintableWithBip39AndMemo() throws {
        let defaultFixture = try TransferPayload.Fixtures.Default()

        // create TransferPayload
        let transferPayload = TransferPayload(
            bip39: defaultFixture.entropyData32,
            txOutPublicKey: defaultFixture.ristretto,
            memo: defaultFixture.memo)
        XCTAssertNotNil(transferPayload)

        // create Printable_TransferPayload from TransferPayload
        let printableTransferPayload = Printable_TransferPayload(transferPayload)

        // Validate
        XCTAssertNotNil(printableTransferPayload)
        XCTAssertEqual(printableTransferPayload.rootEntropy.data.count, 0)
        XCTAssertEqual(printableTransferPayload.bip39Entropy, defaultFixture.entropyData)
        XCTAssertEqual(printableTransferPayload.txOutPublicKey, defaultFixture.ristrettoCompressed)
        XCTAssertEqual(printableTransferPayload.memo, defaultFixture.memo)
    }

    func testDecodingFromPrintableWithBip39AndMemo() throws {
        let defaultFixture = try TransferPayload.Fixtures.Default()

        // create Printable_TransferPayload
        var printableTransferPayload = Printable_TransferPayload()
        printableTransferPayload.bip39Entropy = defaultFixture.entropyData
        printableTransferPayload.rootEntropy = Data()
        printableTransferPayload.txOutPublicKey = defaultFixture.ristrettoCompressed
        printableTransferPayload.memo = defaultFixture.memo

        // create TransferPayload from Printable_TransferPayload
        let transferPayload = TransferPayload(printableTransferPayload)

        // Validate
        XCTAssertNotNil(transferPayload)
        if let transferPayload = transferPayload {
            XCTAssertNil(transferPayload.rootEntropy32)
            XCTAssertEqual(transferPayload.bip39_32, defaultFixture.entropyData32)
            XCTAssertEqual(transferPayload.txOutPublicKey, defaultFixture.ristretto)
            XCTAssertEqual(transferPayload.memo, defaultFixture.memo)
        }
    }

    func testEncodingToPrintableWithRootEntropyNoMemo() throws {
        let defaultFixture = try TransferPayload.Fixtures.Default()

        // create TransferPayload
        let transferPayload = TransferPayload(
            rootEntropy: defaultFixture.entropyData32,
            txOutPublicKey: defaultFixture.ristretto)
        XCTAssertNotNil(transferPayload)

        // create Printable_TransferPayload from TransferPayload
        let printableTransferPayload = Printable_TransferPayload(transferPayload)

        // Validate
        XCTAssertNotNil(printableTransferPayload)
        XCTAssertEqual(printableTransferPayload.rootEntropy, defaultFixture.entropyData)
        XCTAssertEqual(printableTransferPayload.bip39Entropy.data.count, 0)
        XCTAssertEqual(printableTransferPayload.txOutPublicKey, defaultFixture.ristrettoCompressed)
        XCTAssertEqual(printableTransferPayload.memo.count, 0)
    }

    func testDecodingFromPrintableWithRootEntropyNoMemo() throws {
        let defaultFixture = try TransferPayload.Fixtures.Default()

        // create Printable_TransferPayload
        var printableTransferPayload = Printable_TransferPayload()
        printableTransferPayload.rootEntropy = defaultFixture.entropyData
        printableTransferPayload.bip39Entropy = Data()
        printableTransferPayload.txOutPublicKey = defaultFixture.ristrettoCompressed

        // create TransferPayload from Printable_TransferPayload
        let transferPayload = TransferPayload(printableTransferPayload)

        // Validate
        XCTAssertNotNil(transferPayload)
        if let transferPayload = transferPayload {
            XCTAssertEqual(transferPayload.rootEntropy32, defaultFixture.entropyData32)
            XCTAssertNil(transferPayload.bip39_32)
            XCTAssertEqual(transferPayload.txOutPublicKey, defaultFixture.ristretto)
            XCTAssertNil(transferPayload.memo)
        }
    }

    func testEncodingToPrintableWithRootEntropyAndMemo() throws {
        let defaultFixture = try TransferPayload.Fixtures.Default()

        // create TransferPayload
        let transferPayload = TransferPayload(
            rootEntropy: defaultFixture.entropyData32,
            txOutPublicKey: defaultFixture.ristretto,
            memo: defaultFixture.memo)
        XCTAssertNotNil(transferPayload)

        // create Printable_TransferPayload from TransferPayload
        let printableTransferPayload = Printable_TransferPayload(transferPayload)

        // Validate
        XCTAssertNotNil(printableTransferPayload)
        XCTAssertEqual(printableTransferPayload.rootEntropy, defaultFixture.entropyData)
        XCTAssertEqual(printableTransferPayload.bip39Entropy.data.count, 0)
        XCTAssertEqual(printableTransferPayload.txOutPublicKey, defaultFixture.ristrettoCompressed)
        XCTAssertEqual(printableTransferPayload.memo, defaultFixture.memo)
    }

    func testDecodingFromPrintableWithRootEntropyAndMemo() throws {
        let defaultFixture = try TransferPayload.Fixtures.Default()

        // create Printable_TransferPayload
        var printableTransferPayload = Printable_TransferPayload()
        printableTransferPayload.rootEntropy = defaultFixture.entropyData
        printableTransferPayload.bip39Entropy = Data()
        printableTransferPayload.txOutPublicKey = defaultFixture.ristrettoCompressed
        printableTransferPayload.memo = defaultFixture.memo

        // create TransferPayload from Printable_TransferPayload
        let transferPayload = TransferPayload(printableTransferPayload)

        // Validate
        XCTAssertNotNil(transferPayload)
        if let transferPayload = transferPayload {
            XCTAssertEqual(transferPayload.rootEntropy32, defaultFixture.entropyData32)
            XCTAssertNil(transferPayload.bip39_32)
            XCTAssertEqual(transferPayload.txOutPublicKey, defaultFixture.ristretto)
            XCTAssertEqual(transferPayload.memo, defaultFixture.memo)
        }
    }
}
