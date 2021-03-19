//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_function_chains

import LibMobileCoin
@testable import MobileCoin
import XCTest

class AttestAkePerfTests: PerformanceTestCase {

    override class var defaultInvocationOptions: XCTMeasureOptions.InvocationOptions {
        Self.manualStartStopOptions
    }

    func testPerformanceAuthBegin() {
        measure {
            let fixture = try? XCTUnwrap(try AttestAke.Fixtures.Default())
            let attestAke = fixture?.attestAke

            startMeasuring()
            var authRequestData: Data?
            if let fixture = fixture {
                authRequestData = try? XCTUnwrap(attestAke?.authBeginRequestData(
                    responderId: fixture.responderId,
                    rng: fixture.rng,
                    rngContext: fixture.rngContext))
            }
            stopMeasuring()

            XCTAssertEqual(
                authRequestData?.base64EncodedString(),
                fixture?.authRequestData.base64EncodedString())
        }
    }

    func testPerformanceAuthEnd() {
        typealias Fixture = AttestAke.Fixtures.Default
        measure {
            let fixture = try? XCTUnwrap(try AttestAke.Fixtures.DefaultWithAuthBegin())
            let attestAke = fixture?.attestAke

            startMeasuring()
            if let fixture = fixture {
                XCTAssertNoThrow(evaluating: { try attestAke?.authEnd(
                    authResponseData: fixture.authResponseData,
                    attestationVerifier: fixture.attestationVerifier).get() })
            }
            stopMeasuring()

            XCTAssertTrue(attestAke?.isAttested ?? false)
        }
    }

    func testPerformanceEncryptEmptyMessage() {
        measure {
            let fixture = try? XCTUnwrap(try AttestAke.Fixtures.BlankFirstMessage())
            let attestAkeCipher = fixture?.attestAkeCipher

            var encryptedData: Data?
            startMeasuring()
            if let fixture = fixture {
                XCTAssertNoThrow(evaluating: {
                    encryptedData = try attestAkeCipher?
                        .encrypt(aad: fixture.aad, plaintext: fixture.plaintext).get()
                })
            }
            stopMeasuring()

            XCTAssertEqual(
                encryptedData?.base64EncodedString(),
                fixture?.encryptedData.base64EncodedString())
        }
    }

}
