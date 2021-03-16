//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class Base58CoderTests: XCTestCase {

    let decoder = JSONDecoder()

    struct B58EncodePublicAddressWithoutFog: Decodable {
        let view_public_key: RistrettoPublic
        let spend_public_key: RistrettoPublic
        let b58_encoded: String
    }

    func testEncodingPublicAddressWithoutFog() {
        XCTAssertNoThrow(evaluating: {
            let path = try Bundle.url("b58_encode_public_address_without_fog", "jsonl")
            let text = try String(contentsOf: path, encoding: .utf8)
            for line in text.components(separatedBy: CharacterSet.newlines) where !line.isEmpty {
                let testcase = try decoder.decode(
                    B58EncodePublicAddressWithoutFog.self,
                    from: line.data(using: .utf8)!)
                let publicAddress = PublicAddress(
                    viewPublicKey: testcase.view_public_key,
                    spendPublicKey: testcase.spend_public_key)
                XCTAssertEqual(Base58Coder.encode(publicAddress), testcase.b58_encoded)
            }
        })
    }

    func testDecodingPublicAddressWithoutFog() {
        XCTAssertNoThrow(evaluating: {
            let path = try Bundle.url("b58_encode_public_address_without_fog", "jsonl")
            let text = try String(contentsOf: path, encoding: .utf8)
            for line in text.components(separatedBy: CharacterSet.newlines) where !line.isEmpty {
                let testcase = try decoder.decode(
                    B58EncodePublicAddressWithoutFog.self,
                    from: line.data(using: .utf8)!)
                guard let result = Base58Coder.decode(testcase.b58_encoded) else {
                    XCTFail("B58EncodePublicAddressWithoutFog test case failed to decode: " +
                        "\(testcase.b58_encoded)")
                    continue
                }
                guard case .publicAddress(let decoded) = result else {
                    XCTFail("B58EncodePublicAddressWithoutFog test case didn't decode to " +
                        "PublicAddress: \(result)")
                    continue
                }
                let expected = PublicAddress(
                    viewPublicKey: testcase.view_public_key,
                    spendPublicKey: testcase.spend_public_key)
                XCTAssertEqual(decoded, expected)
            }
        })
    }

    struct B58EncodePublicAddressWithFog: Decodable {
        let view_public_key: RistrettoPublic
        let spend_public_key: RistrettoPublic
        let fog_report_url: String
        let fog_report_id: String
        let fog_authority_sig: [UInt8]
        let b58_encoded: String
    }

    func testEncodingPublicAddressWithFog() throws {
        XCTAssertNoThrow(evaluating: {
            let path = try Bundle.url("b58_encode_public_address_with_fog", "jsonl")
            let text = try String(contentsOf: path, encoding: .utf8)
            for line in text.components(separatedBy: CharacterSet.newlines) where !line.isEmpty {
                let testcase = try decoder.decode(
                    B58EncodePublicAddressWithFog.self,
                    from: line.data(using: .utf8)!)
                let publicAddress = try XCTUnwrapSuccess(PublicAddress.make(
                    viewPublicKey: testcase.view_public_key,
                    spendPublicKey: testcase.spend_public_key,
                    fogReportUrl: testcase.fog_report_url,
                    fogReportId: testcase.fog_report_id,
                    fogAuthoritySig: Data(testcase.fog_authority_sig)))
                XCTAssertEqual(Base58Coder.encode(publicAddress), testcase.b58_encoded)
            }
        })
    }

    func testDecodingPublicAddressWithFog() {
        XCTAssertNoThrow(evaluating: {
            let path = try Bundle.url("b58_encode_public_address_with_fog", "jsonl")
            let text = try String(contentsOf: path, encoding: .utf8)
            for line in text.components(separatedBy: CharacterSet.newlines) where !line.isEmpty {
                let testcase = try decoder.decode(
                    B58EncodePublicAddressWithFog.self,
                    from: line.data(using: .utf8)!)
                guard let result = Base58Coder.decode(testcase.b58_encoded) else {
                    XCTFail("B58EncodePublicAddressWithFog test case failed to decode: " +
                        "\(testcase.b58_encoded)")
                    continue
                }
                guard case .publicAddress(let decoded) = result else {
                    XCTFail("B58EncodePublicAddressWithFog test case didn't decode to " +
                        "PublicAddress: \(result)")
                    continue
                }
                let expected = try XCTUnwrapSuccess(PublicAddress.make(
                    viewPublicKey: testcase.view_public_key,
                    spendPublicKey: testcase.spend_public_key,
                    fogReportUrl: testcase.fog_report_url,
                    fogReportId: testcase.fog_report_id,
                    fogAuthoritySig: Data(testcase.fog_authority_sig)))
                XCTAssertEqual(decoded, expected)
            }
        })
    }

}
