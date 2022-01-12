//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class PaymentRequestTests: XCTestCase {

    static let value: UInt64 = 123
    static let memo = "test memo"

    func testEncodingToPrintableNoValueNoMemom() throws {
        let publicAddress = try PublicAddress.Fixtures.Init().accountKey.publicAddress

        // create PaymentRequest
        let paymentRequest = PaymentRequest(publicAddress: publicAddress)
        XCTAssertNotNil(paymentRequest)

        // create Printable_PaymentRequest from PaymentRequest
        let printablePaymentRequest = Printable_PaymentRequest(paymentRequest)

        // Validate
        XCTAssertNotNil(printablePaymentRequest)
        XCTAssertEqual(printablePaymentRequest.publicAddress, External_PublicAddress(publicAddress))
        XCTAssertEqual(printablePaymentRequest.value, 0)
        XCTAssertEqual(printablePaymentRequest.memo.count, 0)
    }

    func testDecodingFromPrintableNoValueNoMemo() throws {
        let publicAddress = try PublicAddress.Fixtures.Init().accountKey.publicAddress

        // create Printable_PaymentRequest
        var printablePaymentRequest = Printable_PaymentRequest()
        printablePaymentRequest.publicAddress = External_PublicAddress(publicAddress)

        // create PaymentRequest from Printable_PaymentRequest
        let paymentRequest = PaymentRequest(printablePaymentRequest)

        // Validate
        XCTAssertNotNil(paymentRequest)
        if let paymentRequest = paymentRequest {
            XCTAssertEqual(paymentRequest.publicAddress, publicAddress)
            XCTAssertNil(paymentRequest.value)
            XCTAssertNil(paymentRequest.memo)
        }
    }

    func testEncodingToPrintableNoMemo() throws {
        let publicAddress = try PublicAddress.Fixtures.Init().accountKey.publicAddress

        // create PaymentRequest
        let paymentRequest = PaymentRequest(publicAddress: publicAddress,
                                            value: Self.value)
        XCTAssertNotNil(paymentRequest)

        // create Printable_PaymentRequest from PaymentRequest
        let printablePaymentRequest = Printable_PaymentRequest(paymentRequest)

        // Validate
        XCTAssertNotNil(printablePaymentRequest)
        XCTAssertEqual(printablePaymentRequest.publicAddress, External_PublicAddress(publicAddress))
        XCTAssertEqual(printablePaymentRequest.value, Self.value)
        XCTAssertEqual(printablePaymentRequest.memo.count, 0)
    }

    func testDecodingFromPrintableNoMemo() throws {
        let publicAddress = try PublicAddress.Fixtures.Init().accountKey.publicAddress

        // create Printable_PaymentRequest
        var printablePaymentRequest = Printable_PaymentRequest()
        printablePaymentRequest.publicAddress = External_PublicAddress(publicAddress)
        printablePaymentRequest.value = Self.value

        // create PaymentRequest from Printable_PaymentRequest
        let paymentRequest = PaymentRequest(printablePaymentRequest)

        // Validate
        XCTAssertNotNil(paymentRequest)
        if let paymentRequest = paymentRequest {
            XCTAssertEqual(paymentRequest.publicAddress, publicAddress)
            XCTAssertEqual(paymentRequest.value, Self.value)
            XCTAssertNil(paymentRequest.memo)
        }
    }

    func testEncodingToPrintableNoValue() throws {
        let publicAddress = try PublicAddress.Fixtures.Init().accountKey.publicAddress

        // create PaymentRequest
        let paymentRequest = PaymentRequest(publicAddress: publicAddress, memo: Self.memo)
        XCTAssertNotNil(paymentRequest)

        // create Printable_PaymentRequest from PaymentRequest
        let printablePaymentRequest = Printable_PaymentRequest(paymentRequest)

        // Validate
        XCTAssertNotNil(printablePaymentRequest)
        XCTAssertEqual(printablePaymentRequest.publicAddress, External_PublicAddress(publicAddress))
        XCTAssertEqual(printablePaymentRequest.value, 0)
        XCTAssertEqual(printablePaymentRequest.memo, Self.memo)
    }

    func testDecodingFromPrintableNoValue() throws {
        let publicAddress = try PublicAddress.Fixtures.Init().accountKey.publicAddress

        // create Printable_PaymentRequest
        var printablePaymentRequest = Printable_PaymentRequest()
        printablePaymentRequest.publicAddress = External_PublicAddress(publicAddress)
        printablePaymentRequest.memo = Self.memo

        // create PaymentRequest from Printable_PaymentRequest
        let paymentRequest = PaymentRequest(printablePaymentRequest)

        // Validate
        XCTAssertNotNil(paymentRequest)
        if let paymentRequest = paymentRequest {
            XCTAssertEqual(paymentRequest.publicAddress, publicAddress)
            XCTAssertNil(paymentRequest.value)
            XCTAssertEqual(paymentRequest.memo, Self.memo)
        }
    }

    func testEncodingToPrintable() throws {
        let publicAddress = try PublicAddress.Fixtures.Init().accountKey.publicAddress

        // create PaymentRequest
        let paymentRequest = PaymentRequest(publicAddress: publicAddress,
                                            value: Self.value,
                                            memo: Self.memo)
        XCTAssertNotNil(paymentRequest)

        // create Printable_PaymentRequest from PaymentRequest
        let printablePaymentRequest = Printable_PaymentRequest(paymentRequest)

        // Validate
        XCTAssertNotNil(printablePaymentRequest)
        XCTAssertEqual(printablePaymentRequest.publicAddress, External_PublicAddress(publicAddress))
        XCTAssertEqual(printablePaymentRequest.value, Self.value)
        XCTAssertEqual(printablePaymentRequest.memo, Self.memo)
    }

    func testDecodingFromPrintable() throws {
        let publicAddress = try PublicAddress.Fixtures.Init().accountKey.publicAddress

        // create Printable_PaymentRequest
        var printablePaymentRequest = Printable_PaymentRequest()
        printablePaymentRequest.publicAddress = External_PublicAddress(publicAddress)
        printablePaymentRequest.value = Self.value
        printablePaymentRequest.memo = Self.memo

        // create PaymentRequest from Printable_PaymentRequest
        let paymentRequest = PaymentRequest(printablePaymentRequest)

        // Validate
        XCTAssertNotNil(paymentRequest)
        if let paymentRequest = paymentRequest {
            XCTAssertEqual(paymentRequest.publicAddress, publicAddress)
            XCTAssertEqual(paymentRequest.value, Self.value)
            XCTAssertEqual(paymentRequest.memo, Self.memo)
        }
    }

}
