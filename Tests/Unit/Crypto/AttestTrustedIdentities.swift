//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

final class AttestTrustedIdentities: XCTestCase {

    func testAuthBegin() throws {
        let fixture = try Attestation.Fixtures.MrEnclave()
        let attestation = fixture.consensusAttestation

        XCTAssertEqual(
            attestation.mrEnclaves.count,
            1)
        
        let verifier = AttestationVerifier(attestation: attestation)
        
    }
}
