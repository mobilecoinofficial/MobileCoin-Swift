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

        init() throws {
            self.consensusAttestation = try Self.attestation()
            self.reportAttestation = try Self.attestation()
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

    fileprivate static func attestation() throws -> Attestation {
        let mrEnclave = try Attestation.MrEnclave.make(mrEnclave: try XCTUnwrap(Data32(hexEncoded: Self.mrSignerB64)).data, allowedConfigAdvisories: [], allowedHardeningAdvisories: ["INTEL-SA-00334", "INTEL-SA-00615"]).get()
        return Attestation.init(mrEnclaves: [mrEnclave])
    }

    private static let mrSignerB64 = "5341c6702a3312243c0f049f87259352ff32aa80f0f6426351c3dd063d817d7a"

}
