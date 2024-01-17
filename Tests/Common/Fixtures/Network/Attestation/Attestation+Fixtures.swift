// swiftlint:disable line_length
//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

extension Attestation {
    enum Fixtures {}
}

extension Attestation.Fixtures {
    struct Default {
        let consensusAttestation: Attestation
        let reportAttestation: Attestation

        init() throws {
            self.consensusAttestation = try Self.attestation(productId: 1)
            self.reportAttestation = try Self.attestation(productId: 4)
        }
    }

    struct MrEnclave {
        let consensusAttestation: Attestation
        let reportAttestation: Attestation
        let ledgerAttestation: Attestation
        let viewAttestation: Attestation
        
        let configAdvisories: [String]
        let hardeningAdvisories: [String]
        
        let configAndHardeningAdvisoriesDescription: String
        let configAdvisoriesDescription: String
        let hardeningAdvisoriesDescription: String

        init() throws {
            self.consensusAttestation = try Self.consensus()
            self.reportAttestation = try Self.report()
            self.ledgerAttestation = try Self.ledger()
            self.viewAttestation = try Self.view()
            self.configAdvisories = Self.configAdvisories
            self.hardeningAdvisories = Self.hardeningAdvisories
            self.configAndHardeningAdvisoriesDescription = Self.configAndHardeningAdvisoriesDescription
            self.configAdvisoriesDescription = Self.configAdvisoriesDescription
            self.hardeningAdvisoriesDescription = Self.hardeningAdvisoriesDescription
        }
    }
    
    struct MrSigner {
        let consensusAttestation: Attestation
        let reportAttestation: Attestation

        let configAdvisories: [String]
        let hardeningAdvisories: [String]
        
        let configAndHardeningAdvisoriesDescription: String
        let configAdvisoriesDescription: String
        let hardeningAdvisoriesDescription: String

        init() throws {
            self.consensusAttestation = try Self.attestation(productId: 1)
            self.reportAttestation = try Self.attestation(productId: 4)
            
            self.configAdvisories = Self.configAdvisories
            self.hardeningAdvisories = Self.hardeningAdvisories
            self.configAndHardeningAdvisoriesDescription = Self.configAndHardeningAdvisoriesDescription
            self.configAdvisoriesDescription = Self.configAdvisoriesDescription
            self.hardeningAdvisoriesDescription = Self.hardeningAdvisoriesDescription
        }
    }
}

extension Attestation.Fixtures.Default {

    fileprivate static func attestation(productId: UInt16) throws -> Attestation {
        Attestation(
            mrSigner: try XCTUnwrap(Data32(base64Encoded: Self.mrSignerB64)),
            productId: productId,
            minimumSecurityVersion: 0,
            allowedHardeningAdvisories: ["INTEL-SA-00334", "INTEL-SA-00615"])
    }

    private static let mrSignerB64 = "fuXinXRiP9vG+/FFS+bzuwuGwSNmt7R4rRM1PkTehBE="

}

extension Attestation.Fixtures.MrEnclave {
    private static let configAndHardeningAdvisoriesDescription =
        #"IDs: {"INTEL-SA-00334", "INTEL-SA-00614", "INTEL-SA-00615"} Status: ConfigurationAndSWHardeningNeeded"#
    private static let configAdvisoriesDescription =
        #"IDs: {"INTEL-SA-00614"} Status: ConfigurationNeeded"#
    private static let hardeningAdvisoriesDescription =
        #"IDs: {"INTEL-SA-00334", "INTEL-SA-00615"} Status: SWHardeningNeeded"#

    private static let configAdvisories = [ "INTEL-SA-00614" ]
    
    private static let hardeningAdvisories = [ "INTEL-SA-00334", "INTEL-SA-00615" ]
    
    fileprivate static func consensus() throws -> Attestation {
        let mrEnclave = try Attestation.MrEnclave.make(mrEnclave: try XCTUnwrap(Data32(hexEncoded: Self.testNetConsensusMrEnclaveHex)).data, allowedConfigAdvisories: [], allowedHardeningAdvisories: ["INTEL-SA-00334", "INTEL-SA-00615", "INTEL-SA-00657"]).get()
        return Attestation(mrEnclaves: [mrEnclave])
    }

    fileprivate static func ledger() throws -> Attestation {
        let mrEnclave = try Attestation.MrEnclave.make(mrEnclave: try XCTUnwrap(Data32(hexEncoded: Self.testNetFogLedgerMrEnclaveHex)).data, allowedConfigAdvisories: [], allowedHardeningAdvisories: ["INTEL-SA-00334", "INTEL-SA-00615", "INTEL-SA-00657"]).get()
        return Attestation(mrEnclaves: [mrEnclave])
    }

    fileprivate static func view() throws -> Attestation {
        let mrEnclave = try Attestation.MrEnclave.make(mrEnclave: try XCTUnwrap(Data32(hexEncoded: Self.testNetFogViewMrEnclaveHex)).data, allowedConfigAdvisories: [], allowedHardeningAdvisories: ["INTEL-SA-00334", "INTEL-SA-00615", "INTEL-SA-00657"]).get()
        return Attestation(mrEnclaves: [mrEnclave])
    }

    fileprivate static func report() throws -> Attestation {
        let mrEnclave = try Attestation.MrEnclave.make(mrEnclave: try XCTUnwrap(Data32(hexEncoded: Self.testNetFogReportMrEnclaveHex)).data, allowedConfigAdvisories: [], allowedHardeningAdvisories: ["INTEL-SA-00334", "INTEL-SA-00615", "INTEL-SA-00657"]).get()
        return Attestation(mrEnclaves: [mrEnclave])
    }

    private static let testNetConsensusMrEnclaveHex =
        "5341c6702a3312243c0f049f87259352ff32aa80f0f6426351c3dd063d817d7a"
    private static let testNetFogViewMrEnclaveHex =
        "ac292a1ad27c0338a5159d5fab2bed3917ea144536cb13b5c1226d09a2fbc648"
    private static let testNetFogLedgerMrEnclaveHex =
        "b61188a6c946557f32e612eff5615908abd1b72ec11d8b7070595a92d4abbbf1"
    private static let testNetFogReportMrEnclaveHex =
        "248356aa0d3431abc45da1773cfd6191a4f2989a4a99da31f450bd7c461e312b"
}

extension Attestation.Fixtures.MrSigner {
    private static let configAndHardeningAdvisoriesDescription =
        #"IDs: {"INTEL-SA-00334", "INTEL-SA-00614", "INTEL-SA-00615"} Status: ConfigurationAndSWHardeningNeeded"#
    private static let configAdvisoriesDescription =
        #"IDs: {"INTEL-SA-00614"} Status: ConfigurationNeeded"#
    private static let hardeningAdvisoriesDescription =
        #"IDs: {"INTEL-SA-00334", "INTEL-SA-00615"} Status: SWHardeningNeeded"#

    private static let configAdvisories = [ "INTEL-SA-00614" ]
    
    private static let hardeningAdvisories = [ "INTEL-SA-00334", "INTEL-SA-00615" ]
    
    fileprivate static func attestation(productId: UInt16) throws -> Attestation {
        Attestation(
            mrSigner: try XCTUnwrap(Data32(hexEncoded: Self.mrSignerHex)),
            productId: productId,
            minimumSecurityVersion: 0,
            allowedHardeningAdvisories: ["INTEL-SA-00334", "INTEL-SA-00615"])
    }

    private static let mrSignerHex =
        "bf7fa957a6a94acb588851bc8767e0ca57706c79f4fc2aa6bcb993012c3c386c"
}
