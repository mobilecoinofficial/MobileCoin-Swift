//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
@testable import LibMobileCoin
#if canImport(LibMobileCoinCommon)
@testable import LibMobileCoinCommon
#endif
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
    
    func testTrustedIdentityMrEnclave() throws {
        let mc_config_advisories = withMcInfallible(mc_advisories_create)
        let configAdvisories: [String] = ["INTEL-SA-00614"]
        configAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_config_advisories, advisory_id) }
        }
        
        let mc_hardening_advisories = withMcInfallible(mc_advisories_create)
        let hardeningAdvisories: [String] = ["INTEL-SA-00334", "INTEL-SA-00615"]
        hardeningAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_hardening_advisories, advisory_id) }
        }
        
        let mrEnclave = Data(hexEncoded: "5341c6702a3312243c0f049f87259352ff32aa80f0f6426351c3dd063d817d7a")!
        let ptr: OpaquePointer = mrEnclave.asMcBuffer { mrEnclavePtr in
            withMcInfallible { mc_trusted_identity_mr_enclave_create(mrEnclavePtr, mc_config_advisories, mc_hardening_advisories) }
        }
       
        let trusted_identity_description = Data32.make(withMcMutableBuffer: { bufferPtr, errorPtr in
                            mc_trusted_mr_enclave_identity_to_string(ptr, bufferPtr)
                        })
        
        print("here")
    }
}
