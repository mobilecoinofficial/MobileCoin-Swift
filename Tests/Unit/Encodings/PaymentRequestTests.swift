//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class PaymentRequestTests: XCTestCase {

    static let publicAddress = (try? PublicAddress.Fixtures.Init())!.accountKey.publicAddress
    static let externalPublicAddress = External_PublicAddress(publicAddress)
    static let value: UInt64 = 123
    static let memo = "test memo"

    func testEncodingToPrintableNoValueNoMemom() throws {
        XCTAssertNoThrow(evaluating: {
            // create PaymentRequest
            let paymentRequest = PaymentRequest(publicAddress: Self.publicAddress)
            XCTAssertNotNil(paymentRequest)

            // create Printable_PaymentRequest from PaymentRequest
            let printablePaymentRequest = Printable_PaymentRequest(paymentRequest)

            // Validate
            XCTAssertNotNil(printablePaymentRequest)
            XCTAssertEqual(printablePaymentRequest.publicAddress, Self.externalPublicAddress)
            XCTAssertEqual(printablePaymentRequest.value, 0)
            XCTAssertEqual(printablePaymentRequest.memo.count, 0)
        })
    }

    func testDecodingFromPrintableNoValueNoMemo() throws {
        XCTAssertNoThrow(evaluating: {
            // create Printable_PaymentRequest
            var printablePaymentRequest = Printable_PaymentRequest()
            printablePaymentRequest.publicAddress = Self.externalPublicAddress

            // create PaymentRequest from Printable_PaymentRequest
            let paymentRequest = PaymentRequest(printablePaymentRequest)

            // Validate
            XCTAssertNotNil(paymentRequest)
            if let paymentRequest = paymentRequest {
                XCTAssertEqual(paymentRequest.publicAddress, Self.publicAddress)
                XCTAssertNil(paymentRequest.value)
                XCTAssertNil(paymentRequest.memo)
            }
        })
    }

    func testEncodingToPrintableNoMemo() throws {
        XCTAssertNoThrow(evaluating: {
            // create PaymentRequest
            let paymentRequest = PaymentRequest(publicAddress: Self.publicAddress,
                                                value: Self.value)
            XCTAssertNotNil(paymentRequest)

            // create Printable_PaymentRequest from PaymentRequest
            let printablePaymentRequest = Printable_PaymentRequest(paymentRequest)

            // Validate
            XCTAssertNotNil(printablePaymentRequest)
            XCTAssertEqual(printablePaymentRequest.publicAddress, Self.externalPublicAddress)
            XCTAssertEqual(printablePaymentRequest.value, Self.value)
            XCTAssertEqual(printablePaymentRequest.memo.count, 0)
        })
    }

    func testDecodingFromPrintableNoMemo() throws {
        XCTAssertNoThrow(evaluating: {
            // create Printable_PaymentRequest
            var printablePaymentRequest = Printable_PaymentRequest()
            printablePaymentRequest.publicAddress = Self.externalPublicAddress
            printablePaymentRequest.value = Self.value

            // create PaymentRequest from Printable_PaymentRequest
            let paymentRequest = PaymentRequest(printablePaymentRequest)

            // Validate
            XCTAssertNotNil(paymentRequest)
            if let paymentRequest = paymentRequest {
                XCTAssertEqual(paymentRequest.publicAddress, Self.publicAddress)
                XCTAssertEqual(paymentRequest.value, Self.value)
                XCTAssertNil(paymentRequest.memo)
            }
        })
    }

    func testEncodingToPrintableNoValue() throws {
        XCTAssertNoThrow(evaluating: {
            // create PaymentRequest
            let paymentRequest = PaymentRequest(publicAddress: Self.publicAddress, memo: Self.memo)
            XCTAssertNotNil(paymentRequest)

            // create Printable_PaymentRequest from PaymentRequest
            let printablePaymentRequest = Printable_PaymentRequest(paymentRequest)

            // Validate
            XCTAssertNotNil(printablePaymentRequest)
            XCTAssertEqual(printablePaymentRequest.publicAddress, Self.externalPublicAddress)
            XCTAssertEqual(printablePaymentRequest.value, 0)
            XCTAssertEqual(printablePaymentRequest.memo, Self.memo)
        })
    }

    func testDecodingFromPrintableNoValue() throws {
        XCTAssertNoThrow(evaluating: {
            // create Printable_PaymentRequest
            var printablePaymentRequest = Printable_PaymentRequest()
            printablePaymentRequest.publicAddress = Self.externalPublicAddress
            printablePaymentRequest.memo = Self.memo

            // create PaymentRequest from Printable_PaymentRequest
            let paymentRequest = PaymentRequest(printablePaymentRequest)

            // Validate
            XCTAssertNotNil(paymentRequest)
            if let paymentRequest = paymentRequest {
                XCTAssertEqual(paymentRequest.publicAddress, Self.publicAddress)
                XCTAssertNil(paymentRequest.value)
                XCTAssertEqual(paymentRequest.memo, Self.memo)
            }
        })
    }

    func testEncodingToPrintable() throws {
        XCTAssertNoThrow(evaluating: {
            // create PaymentRequest
            let paymentRequest = PaymentRequest(publicAddress: Self.publicAddress,
                                                value: Self.value,
                                                memo: Self.memo)
            XCTAssertNotNil(paymentRequest)

            // create Printable_PaymentRequest from PaymentRequest
            let printablePaymentRequest = Printable_PaymentRequest(paymentRequest)

            // Validate
            XCTAssertNotNil(printablePaymentRequest)
            XCTAssertEqual(printablePaymentRequest.publicAddress, Self.externalPublicAddress)
            XCTAssertEqual(printablePaymentRequest.value, Self.value)
            XCTAssertEqual(printablePaymentRequest.memo, Self.memo)
        })
    }

    func testDecodingFromPrintable() throws {
        XCTAssertNoThrow(evaluating: {
            // create Printable_PaymentRequest
            var printablePaymentRequest = Printable_PaymentRequest()
            printablePaymentRequest.publicAddress = Self.externalPublicAddress
            printablePaymentRequest.value = Self.value
            printablePaymentRequest.memo = Self.memo

            // create PaymentRequest from Printable_PaymentRequest
            let paymentRequest = PaymentRequest(printablePaymentRequest)

            // Validate
            XCTAssertNotNil(paymentRequest)
            if let paymentRequest = paymentRequest {
                XCTAssertEqual(paymentRequest.publicAddress, Self.publicAddress)
                XCTAssertEqual(paymentRequest.value, Self.value)
                XCTAssertEqual(paymentRequest.memo, Self.memo)
            }
        })
    }

}
