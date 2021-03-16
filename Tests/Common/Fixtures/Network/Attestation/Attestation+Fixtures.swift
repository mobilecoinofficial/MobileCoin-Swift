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
}

extension Attestation.Fixtures.Default {

    fileprivate static func attestation(productId: UInt16) throws -> Attestation {
        Attestation(
            mrSigner: try XCTUnwrap(Data32(base64Encoded: Self.mrSignerB64)),
            productId: productId,
            minimumSecurityVersion: 0,
            allowedHardeningAdvisories: ["INTEL-SA-00334"])
    }

    private static let mrSignerB64 = "fuXinXRiP9vG+/FFS+bzuwuGwSNmt7R4rRM1PkTehBE="

}
