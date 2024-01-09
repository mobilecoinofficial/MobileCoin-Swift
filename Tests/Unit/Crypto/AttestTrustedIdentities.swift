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
    
    func testTrustedIdentityMrEnclaveConfigAndHardeningAdvisories() throws {
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
       
        let trusted_identity_description = try Data(withMcMutableBufferInfallible: { bufferPtr in
            mc_trusted_mr_enclave_identity_advisories_to_string(ptr, bufferPtr)
        })
        
        let advisoryDescription = try XCTUnwrap(String(data: trusted_identity_description, encoding: .utf8))
        XCTAssertEqual(#"IDs: {"INTEL-SA-00334", "INTEL-SA-00614", "INTEL-SA-00615"} Status: ConfigurationAndSWHardeningNeeded"#, advisoryDescription)
    }
    
    func testTrustedIdentityMrEnclaveConfigAdvisories() throws {
        let mc_config_advisories = withMcInfallible(mc_advisories_create)
        let configAdvisories: [String] = ["INTEL-SA-00614"]
        configAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_config_advisories, advisory_id) }
        }
        
        let mc_hardening_advisories = withMcInfallible(mc_advisories_create)
        let hardeningAdvisories: [String] = []
        hardeningAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_hardening_advisories, advisory_id) }
        }
        
        let mrEnclave = Data(hexEncoded: "5341c6702a3312243c0f049f87259352ff32aa80f0f6426351c3dd063d817d7a")!
        let ptr: OpaquePointer = mrEnclave.asMcBuffer { mrEnclavePtr in
            withMcInfallible { mc_trusted_identity_mr_enclave_create(mrEnclavePtr, mc_config_advisories, mc_hardening_advisories) }
        }
       
        let trusted_identity_description = try Data(withMcMutableBufferInfallible: { bufferPtr in
            mc_trusted_mr_enclave_identity_advisories_to_string(ptr, bufferPtr)
        })
        
        let advisoryDescription = try XCTUnwrap(String(data: trusted_identity_description, encoding: .utf8))
        XCTAssertEqual(#"IDs: {"INTEL-SA-00614"} Status: ConfigurationNeeded"#, advisoryDescription)
    }
    
    func testTrustedIdentityMrEnclaveHardeningAdvisories() throws {
        let mc_config_advisories = withMcInfallible(mc_advisories_create)
        let configAdvisories: [String] = []
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
       
        let trusted_identity_description = try Data(withMcMutableBufferInfallible: { bufferPtr in
            mc_trusted_mr_enclave_identity_advisories_to_string(ptr, bufferPtr)
        })
        
        let advisoryDescription = try XCTUnwrap(String(data: trusted_identity_description, encoding: .utf8))
        XCTAssertEqual(#"IDs: {"INTEL-SA-00334", "INTEL-SA-00615"} Status: SWHardeningNeeded"#, advisoryDescription)
    }
    
    func testTrustedIdentityMrEnclaveHex() throws {
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
        
        let mrEnclaveHex = "5341c6702a3312243c0f049f87259352ff32aa80f0f6426351c3dd063d817d7a"
        let mrEnclave = Data(hexEncoded: mrEnclaveHex)!
        let ptr: OpaquePointer = mrEnclave.asMcBuffer { mrEnclavePtr in
            withMcInfallible { mc_trusted_identity_mr_enclave_create(mrEnclavePtr, mc_config_advisories, mc_hardening_advisories) }
        }
       
        let trusted_identity_description = try Data(withMcMutableBufferInfallible: { bufferPtr in
            mc_trusted_mr_enclave_identity_to_string(ptr, bufferPtr)
        })
        
        let enclaveDescription = try XCTUnwrap(String(data: trusted_identity_description, encoding: .utf8))
        XCTAssertEqual(mrEnclaveHex, enclaveDescription)
    }
   







    func testTrustedIdentityMrSignerConfigAndHardeningAdvisories() throws {
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
        
        let mrSigner = Data(hexEncoded: "5341c6702a3312243c0f049f87259352ff32aa80f0f6426351c3dd063d817d7a")!
        let ptr: OpaquePointer = mrSigner.asMcBuffer { mrSignerPtr in
            withMcInfallible { mc_trusted_identity_mr_signer_create(mrSignerPtr, mc_config_advisories, mc_hardening_advisories, UInt16(0), UInt16(9)) }
        }
       
        let trusted_identity_description = try Data(withMcMutableBufferInfallible: { bufferPtr in
            mc_trusted_mr_signer_identity_advisories_to_string(ptr, bufferPtr)
        })
        
        let advisoryDescription = try XCTUnwrap(String(data: trusted_identity_description, encoding: .utf8))
        XCTAssertEqual(#"IDs: {"INTEL-SA-00334", "INTEL-SA-00614", "INTEL-SA-00615"} Status: ConfigurationAndSWHardeningNeeded"#, advisoryDescription)
    }
    
    func testTrustedIdentityMrSignerConfigAdvisories() throws {
        let mc_config_advisories = withMcInfallible(mc_advisories_create)
        let configAdvisories: [String] = ["INTEL-SA-00614"]
        configAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_config_advisories, advisory_id) }
        }
        
        let mc_hardening_advisories = withMcInfallible(mc_advisories_create)
        let hardeningAdvisories: [String] = []
        hardeningAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_hardening_advisories, advisory_id) }
        }
        
        let mrSigner = Data(hexEncoded: "5341c6702a3312243c0f049f87259352ff32aa80f0f6426351c3dd063d817d7a")!
        let ptr: OpaquePointer = mrSigner.asMcBuffer { mrSignerPtr in
            withMcInfallible { mc_trusted_identity_mr_signer_create(mrSignerPtr, mc_config_advisories, mc_hardening_advisories, UInt16(0), UInt16(9)) }
        }
       
        let trusted_identity_description = try Data(withMcMutableBufferInfallible: { bufferPtr in
            mc_trusted_mr_signer_identity_advisories_to_string(ptr, bufferPtr)
        })
        
        let advisoryDescription = try XCTUnwrap(String(data: trusted_identity_description, encoding: .utf8))
        XCTAssertEqual(#"IDs: {"INTEL-SA-00614"} Status: ConfigurationNeeded"#, advisoryDescription)
    }
    
    func testTrustedIdentityMrSignerHardeningAdvisories() throws {
        let mc_config_advisories = withMcInfallible(mc_advisories_create)
        let configAdvisories: [String] = []
        configAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_config_advisories, advisory_id) }
        }
        
        let mc_hardening_advisories = withMcInfallible(mc_advisories_create)
        let hardeningAdvisories: [String] = ["INTEL-SA-00334", "INTEL-SA-00615"]
        hardeningAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_hardening_advisories, advisory_id) }
        }
        
        let mrSigner = Data(hexEncoded: "5341c6702a3312243c0f049f87259352ff32aa80f0f6426351c3dd063d817d7a")!
        let ptr: OpaquePointer = mrSigner.asMcBuffer { mrSignerPtr in
            withMcInfallible { mc_trusted_identity_mr_signer_create(mrSignerPtr, mc_config_advisories, mc_hardening_advisories, UInt16(0), UInt16(9)) }
        }
       
        let trusted_identity_description = try Data(withMcMutableBufferInfallible: { bufferPtr in
            mc_trusted_mr_signer_identity_advisories_to_string(ptr, bufferPtr)
        })
        
        let advisoryDescription = try XCTUnwrap(String(data: trusted_identity_description, encoding: .utf8))
        XCTAssertEqual(#"IDs: {"INTEL-SA-00334", "INTEL-SA-00615"} Status: SWHardeningNeeded"#, advisoryDescription)
    }
    
    func testTrustedIdentityMrSignerHex() throws {
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
        
        let mrSignerHex = "5341c6702a3312243c0f049f87259352ff32aa80f0f6426351c3dd063d817d7a"
        let mrSigner = Data(hexEncoded: mrSignerHex)!
        let ptr: OpaquePointer = mrSigner.asMcBuffer { mrSignerPtr in
            withMcInfallible { mc_trusted_identity_mr_signer_create(mrSignerPtr, mc_config_advisories, mc_hardening_advisories, UInt16(0), UInt16(9)) }
        }
       
        let trusted_identity_description = try Data(withMcMutableBufferInfallible: { bufferPtr in
            mc_trusted_mr_signer_identity_to_string(ptr, bufferPtr)
        })
        
        let enclaveDescription = try XCTUnwrap(String(data: trusted_identity_description, encoding: .utf8))
        XCTAssertEqual(mrSignerHex, enclaveDescription)
    }
}
