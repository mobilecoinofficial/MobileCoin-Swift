//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import LibMobileCoin
@testable import MobileCoin
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

        _ = AttestationVerifier(attestation: attestation)
    }

    func testTrustedIdentityMrEnclaveConfigAndHardeningAdvisories() throws {
        let fixture = try Attestation.Fixtures.MrEnclave()
        let mc_config_advisories = withMcInfallible(mc_advisories_create)
        fixture.configAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_config_advisories, advisory_id) }
        }

        let mc_hardening_advisories = withMcInfallible(mc_advisories_create)
        fixture.hardeningAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_hardening_advisories, advisory_id) }
        }

        let mrEnclave = fixture.consensusAttestation.mrEnclaves[0].mrEnclave.data
        let ptr: OpaquePointer = mrEnclave.asMcBuffer { mrEnclavePtr in
            withMcInfallible {
                mc_trusted_identity_mr_enclave_create(
                    mrEnclavePtr,
                    mc_config_advisories,
                    mc_hardening_advisories
                )
            }
        }

        let trusted_identity_description = Data(withMcMutableBufferInfallible: { bufferPtr in
            mc_trusted_mr_enclave_identity_advisories_to_string(
                ptr,
                bufferPtr
            )
        })

        let advisoryDescription = try XCTUnwrap(
            String(data: trusted_identity_description, encoding: .utf8))
        XCTAssertEqual(fixture.configAndHardeningAdvisoriesDescription, advisoryDescription)
    }

    func testTrustedIdentityMrEnclaveConfigAdvisories() throws {
        let fixture = try Attestation.Fixtures.MrEnclave()
        let mc_config_advisories = withMcInfallible(mc_advisories_create)
        fixture.configAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_config_advisories, advisory_id) }
        }

        let mc_hardening_advisories = withMcInfallible(mc_advisories_create)
        let hardeningAdvisories: [String] = []
        hardeningAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_hardening_advisories, advisory_id) }
        }

        let mrEnclave = fixture.consensusAttestation.mrEnclaves[0].mrEnclave.data
        let ptr: OpaquePointer = mrEnclave.asMcBuffer { mrEnclavePtr in
            withMcInfallible {
                mc_trusted_identity_mr_enclave_create(
                    mrEnclavePtr,
                    mc_config_advisories,
                    mc_hardening_advisories
                )
            }
        }

        let trusted_identity_description = Data(withMcMutableBufferInfallible: { bufferPtr in
            mc_trusted_mr_enclave_identity_advisories_to_string(ptr, bufferPtr)
        })

        let advisoryDescription = try XCTUnwrap(
            String(data: trusted_identity_description, encoding: .utf8))
        XCTAssertEqual(fixture.configAdvisoriesDescription, advisoryDescription)
    }

    func testTrustedIdentityMrEnclaveHardeningAdvisories() throws {
        let fixture = try Attestation.Fixtures.MrEnclave()
        let mc_config_advisories = withMcInfallible(mc_advisories_create)

        let mc_hardening_advisories = withMcInfallible(mc_advisories_create)
        fixture.hardeningAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_hardening_advisories, advisory_id) }
        }

        let mrEnclave = fixture.consensusAttestation.mrEnclaves[0].mrEnclave.data
        let ptr: OpaquePointer = mrEnclave.asMcBuffer { mrEnclavePtr in
            withMcInfallible {
                mc_trusted_identity_mr_enclave_create(
                    mrEnclavePtr,
                    mc_config_advisories,
                    mc_hardening_advisories
                )
            }
        }

        let trusted_identity_description = Data(withMcMutableBufferInfallible: { bufferPtr in
            mc_trusted_mr_enclave_identity_advisories_to_string(ptr, bufferPtr)
        })

        let advisoryDescription = try XCTUnwrap(
            String(data: trusted_identity_description, encoding: .utf8))
        XCTAssertEqual(fixture.hardeningAdvisoriesDescription, advisoryDescription)
    }

    func testTrustedIdentityMrEnclaveHex() throws {
        let fixture = try Attestation.Fixtures.MrEnclave()
        let mc_config_advisories = withMcInfallible(mc_advisories_create)
        fixture.configAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_config_advisories, advisory_id) }
        }

        let mc_hardening_advisories = withMcInfallible(mc_advisories_create)
        fixture.hardeningAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_hardening_advisories, advisory_id) }
        }

        let mrEnclave = fixture.consensusAttestation.mrEnclaves[0].mrEnclave.data
        let mrEnclaveHex = mrEnclave.hexEncodedString()
        let ptr: OpaquePointer = mrEnclave.asMcBuffer { mrEnclavePtr in
            withMcInfallible {
                mc_trusted_identity_mr_enclave_create(
                    mrEnclavePtr,
                    mc_config_advisories,
                    mc_hardening_advisories
                )
            }
        }

        let trusted_identity_description = Data(withMcMutableBufferInfallible: { bufferPtr in
            mc_trusted_mr_enclave_identity_to_string(ptr, bufferPtr)
        })

        let enclaveDescription = try XCTUnwrap(
            String(data: trusted_identity_description, encoding: .utf8))
        XCTAssertEqual(mrEnclaveHex, enclaveDescription)
    }

    func testTrustedIdentityMrSignerConfigAndHardeningAdvisories() throws {
        let fixture = try Attestation.Fixtures.MrSigner()
        let mc_config_advisories = withMcInfallible(mc_advisories_create)
        fixture.configAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_config_advisories, advisory_id) }
        }

        let mc_hardening_advisories = withMcInfallible(mc_advisories_create)
        fixture.hardeningAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_hardening_advisories, advisory_id) }
        }

        let mrSigner = fixture.consensusAttestation.mrSigners[0].mrSigner.data
        let ptr: OpaquePointer = mrSigner.asMcBuffer { mrSignerPtr in
            withMcInfallible {
                mc_trusted_identity_mr_signer_create(
                    mrSignerPtr,
                    mc_config_advisories,
                    mc_hardening_advisories,
                    UInt16(0),
                    UInt16(9)
                )
            }
        }

        let trusted_identity_description = Data(withMcMutableBufferInfallible: { bufferPtr in
            mc_trusted_mr_signer_identity_advisories_to_string(ptr, bufferPtr)
        })

        let advisoryDescription = try XCTUnwrap(
            String(data: trusted_identity_description, encoding: .utf8))
        XCTAssertEqual(fixture.configAndHardeningAdvisoriesDescription, advisoryDescription)
    }

    func testTrustedIdentityMrSignerConfigAdvisories() throws {
        let fixture = try Attestation.Fixtures.MrSigner()
        let mc_config_advisories = withMcInfallible(mc_advisories_create)
        fixture.configAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_config_advisories, advisory_id) }
        }

        let mc_hardening_advisories = withMcInfallible(mc_advisories_create)

        let mrSigner = fixture.consensusAttestation.mrSigners[0].mrSigner.data
        let ptr: OpaquePointer = mrSigner.asMcBuffer { mrSignerPtr in
            withMcInfallible {
                mc_trusted_identity_mr_signer_create(
                    mrSignerPtr,
                    mc_config_advisories,
                    mc_hardening_advisories,
                    UInt16(0),
                    UInt16(9)
                )
            }
        }

        let trusted_identity_description = Data(withMcMutableBufferInfallible: { bufferPtr in
            mc_trusted_mr_signer_identity_advisories_to_string(ptr, bufferPtr)
        })

        let advisoryDescription = try XCTUnwrap(
            String(data: trusted_identity_description, encoding: .utf8))
        XCTAssertEqual(fixture.configAdvisoriesDescription, advisoryDescription)
    }

    func testTrustedIdentityMrSignerHardeningAdvisories() throws {
        let fixture = try Attestation.Fixtures.MrSigner()
        let mc_config_advisories = withMcInfallible(mc_advisories_create)

        let mc_hardening_advisories = withMcInfallible(mc_advisories_create)
        fixture.hardeningAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_hardening_advisories, advisory_id) }
        }

        let mrSigner = fixture.consensusAttestation.mrSigners[0].mrSigner.data
        let ptr: OpaquePointer = mrSigner.asMcBuffer { mrSignerPtr in
            withMcInfallible {
                mc_trusted_identity_mr_signer_create(
                    mrSignerPtr,
                    mc_config_advisories,
                    mc_hardening_advisories,
                    UInt16(0),
                    UInt16(9)
                )
            }
        }

        let trusted_identity_description = Data(withMcMutableBufferInfallible: { bufferPtr in
            mc_trusted_mr_signer_identity_advisories_to_string(ptr, bufferPtr)
        })

        let advisoryDescription = try XCTUnwrap(
            String(data: trusted_identity_description, encoding: .utf8))
        XCTAssertEqual(fixture.hardeningAdvisoriesDescription, advisoryDescription)
    }

    func testTrustedIdentityMrSignerHex() throws {
        let fixture = try Attestation.Fixtures.MrSigner()
        let mc_config_advisories = withMcInfallible(mc_advisories_create)
        fixture.configAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_config_advisories, advisory_id) }
        }

        let mc_hardening_advisories = withMcInfallible(mc_advisories_create)
        fixture.hardeningAdvisories.forEach { advisory_id in
            withMcInfallible { mc_add_advisory(mc_hardening_advisories, advisory_id) }
        }

        let mrSigner = fixture.consensusAttestation.mrSigners[0].mrSigner.data
        let mrSignerHex = mrSigner.hexEncodedString()
        let ptr: OpaquePointer = mrSigner.asMcBuffer { mrSignerPtr in
            withMcInfallible {
                mc_trusted_identity_mr_signer_create(
                    mrSignerPtr,
                    mc_config_advisories,
                    mc_hardening_advisories,
                    UInt16(0),
                    UInt16(9)
                )
            }
        }

        let trusted_identity_description = Data(withMcMutableBufferInfallible: { bufferPtr in
            mc_trusted_mr_signer_identity_to_string(ptr, bufferPtr)
        })

        let enclaveDescription = try XCTUnwrap(
            String(data: trusted_identity_description, encoding: .utf8))
        XCTAssertEqual(mrSignerHex, enclaveDescription)
    }
}
