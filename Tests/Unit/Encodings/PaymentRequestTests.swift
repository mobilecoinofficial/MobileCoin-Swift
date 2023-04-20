//
//  Copyright (c) 2022 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class PaymentRequestTests: XCTestCase {

    func testEncodingToPrintableNoValueNoMemoNoID() throws {
        let defaultFixture = try PaymentRequest.Fixtures.Default()

        // create PaymentRequest
        let paymentRequest = PaymentRequest(publicAddress: defaultFixture.publicAddress)
        XCTAssertNotNil(paymentRequest)

        // create Printable_PaymentRequest from PaymentRequest
        let printablePaymentRequest = Printable_PaymentRequest(paymentRequest)

        // Validate
        XCTAssertNotNil(printablePaymentRequest)
        XCTAssertEqual(printablePaymentRequest.publicAddress, defaultFixture.externalPublicAddress)
        XCTAssertEqual(printablePaymentRequest.value, 0)
        XCTAssertEqual(printablePaymentRequest.memo.count, 0)
        XCTAssertEqual(printablePaymentRequest.paymentID, 0)
    }

    func testEncodingToPrintableNoValueNoMemo() throws {
        let defaultFixture = try PaymentRequest.Fixtures.Default()

        // create PaymentRequest
        let paymentRequest = PaymentRequest(publicAddress: defaultFixture.publicAddress)
        XCTAssertNotNil(paymentRequest)

        // create Printable_PaymentRequest from PaymentRequest
        let printablePaymentRequest = Printable_PaymentRequest(paymentRequest)

        // Validate
        XCTAssertNotNil(printablePaymentRequest)
        XCTAssertEqual(printablePaymentRequest.publicAddress, defaultFixture.externalPublicAddress)
        XCTAssertEqual(printablePaymentRequest.value, 0)
        XCTAssertEqual(printablePaymentRequest.memo.count, 0)
    }

    func testDecodingFromPrintableNoValueNoMemo() throws {
        let defaultFixture = try PaymentRequest.Fixtures.Default()

        // create Printable_PaymentRequest
        var printablePaymentRequest = Printable_PaymentRequest()
        printablePaymentRequest.publicAddress = External_PublicAddress(defaultFixture.publicAddress)

        // create PaymentRequest from Printable_PaymentRequest
        let paymentRequest = PaymentRequest(printablePaymentRequest)

        // Validate
        XCTAssertNotNil(paymentRequest)
        if let paymentRequest = paymentRequest {
            XCTAssertEqual(paymentRequest.publicAddress, defaultFixture.publicAddress)
            XCTAssertNil(paymentRequest.value)
            XCTAssertNil(paymentRequest.memo)
        }
    }

    func testEncodingToPrintableNoMemo() throws {
        let defaultFixture = try PaymentRequest.Fixtures.Default()

        // create PaymentRequest
        let paymentRequest = PaymentRequest(
            publicAddress: defaultFixture.publicAddress,
            value: defaultFixture.paymentValue,
            paymentID: defaultFixture.paymentID)

        XCTAssertNotNil(paymentRequest)

        // create Printable_PaymentRequest from PaymentRequest
        let printablePaymentRequest = Printable_PaymentRequest(paymentRequest)

        // Validate
        XCTAssertNotNil(printablePaymentRequest)
        XCTAssertEqual(printablePaymentRequest.publicAddress, defaultFixture.externalPublicAddress)
        XCTAssertEqual(printablePaymentRequest.value, defaultFixture.paymentValue)
        XCTAssertEqual(printablePaymentRequest.paymentID, defaultFixture.paymentID)
        XCTAssertEqual(printablePaymentRequest.memo.count, 0)
    }

    func testDecodingFromPrintableNoMemo() throws {
        let defaultFixture = try PaymentRequest.Fixtures.Default()

        // create Printable_PaymentRequest
        var printablePaymentRequest = Printable_PaymentRequest()
        printablePaymentRequest.publicAddress = defaultFixture.externalPublicAddress
        printablePaymentRequest.value = defaultFixture.paymentValue
        printablePaymentRequest.paymentID = defaultFixture.paymentID

        // create PaymentRequest from Printable_PaymentRequest
        let paymentRequest = PaymentRequest(printablePaymentRequest)

        // Validate
        XCTAssertNotNil(paymentRequest)
        if let paymentRequest = paymentRequest {
            XCTAssertEqual(paymentRequest.publicAddress, defaultFixture.publicAddress)
            XCTAssertEqual(paymentRequest.value, defaultFixture.paymentValue)
            XCTAssertEqual(paymentRequest.paymentID, defaultFixture.paymentID)
            XCTAssertNil(paymentRequest.memo)
        }
    }

    func testEncodingToPrintableNoValue() throws {
        let defaultFixture = try PaymentRequest.Fixtures.Default()

        // create PaymentRequest
        let paymentRequest = PaymentRequest(
            publicAddress: defaultFixture.publicAddress,
            memo: defaultFixture.memo,
            paymentID: defaultFixture.paymentID)

        XCTAssertNotNil(paymentRequest)

        // create Printable_PaymentRequest from PaymentRequest
        let printablePaymentRequest = Printable_PaymentRequest(paymentRequest)

        // Validate
        XCTAssertNotNil(printablePaymentRequest)
        XCTAssertEqual(printablePaymentRequest.publicAddress, defaultFixture.externalPublicAddress)
        XCTAssertEqual(printablePaymentRequest.value, 0)
        XCTAssertEqual(printablePaymentRequest.memo, defaultFixture.memo)
        XCTAssertEqual(printablePaymentRequest.paymentID, defaultFixture.paymentID)
    }

    func testDecodingFromPrintableNoValue() throws {
        let defaultFixture = try PaymentRequest.Fixtures.Default()

        // create Printable_PaymentRequest
        var printablePaymentRequest = Printable_PaymentRequest()
        printablePaymentRequest.publicAddress = defaultFixture.externalPublicAddress
        printablePaymentRequest.memo = defaultFixture.memo
        printablePaymentRequest.paymentID = defaultFixture.paymentID

        // create PaymentRequest from Printable_PaymentRequest
        let paymentRequest = PaymentRequest(printablePaymentRequest)

        // Validate
        XCTAssertNotNil(paymentRequest)
        if let paymentRequest = paymentRequest {
            XCTAssertEqual(paymentRequest.publicAddress, defaultFixture.publicAddress)
            XCTAssertNil(paymentRequest.value)
            XCTAssertEqual(paymentRequest.memo, defaultFixture.memo)
            XCTAssertEqual(paymentRequest.paymentID, defaultFixture.paymentID)
        }
    }

    func testEncodingToPrintable() throws {
        let defaultFixture = try PaymentRequest.Fixtures.Default()

        // create PaymentRequest
        let paymentRequest = PaymentRequest(
            publicAddress: defaultFixture.publicAddress,
            value: defaultFixture.paymentValue,
            memo: defaultFixture.memo,
            paymentID: defaultFixture.paymentID)

        XCTAssertNotNil(paymentRequest)

        // create Printable_PaymentRequest from PaymentRequest
        let printablePaymentRequest = Printable_PaymentRequest(paymentRequest)

        // Validate
        XCTAssertNotNil(printablePaymentRequest)
        XCTAssertEqual(printablePaymentRequest.publicAddress, defaultFixture.externalPublicAddress)
        XCTAssertEqual(printablePaymentRequest.value, defaultFixture.paymentValue)
        XCTAssertEqual(printablePaymentRequest.memo, defaultFixture.memo)
        XCTAssertEqual(printablePaymentRequest.paymentID, defaultFixture.paymentID)
    }

    func testDecodingFromPrintable() throws {
        let defaultFixture = try PaymentRequest.Fixtures.Default()

        // create Printable_PaymentRequest
        var printablePaymentRequest = Printable_PaymentRequest()
        printablePaymentRequest.publicAddress = defaultFixture.externalPublicAddress
        printablePaymentRequest.value = defaultFixture.paymentValue
        printablePaymentRequest.memo = defaultFixture.memo
        printablePaymentRequest.paymentID = defaultFixture.paymentID

        // create PaymentRequest from Printable_PaymentRequest
        let paymentRequest = PaymentRequest(printablePaymentRequest)

        // Validate
        XCTAssertNotNil(paymentRequest)
        if let paymentRequest = paymentRequest {
            XCTAssertEqual(paymentRequest.publicAddress, defaultFixture.publicAddress)
            XCTAssertEqual(paymentRequest.value, defaultFixture.paymentValue)
            XCTAssertEqual(paymentRequest.memo, defaultFixture.memo)
            XCTAssertEqual(paymentRequest.paymentID, defaultFixture.paymentID)
        }
    }

    func testDecodingFromPrintableWithInvalidPublicAddress() throws {
        // create Printable_PaymentRequest
        var printablePaymentRequest = Printable_PaymentRequest()
        printablePaymentRequest.publicAddress = External_PublicAddress()

        // create PaymentRequest from Printable_PaymentRequest
        let paymentRequest = PaymentRequest(printablePaymentRequest)

        // Validate
        XCTAssertNil(paymentRequest)
    }

}
