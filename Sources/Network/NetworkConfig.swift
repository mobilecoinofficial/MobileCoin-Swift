//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

/**
 
 TODO
 
 - Create AttestedConnection protocol with default implementations for all re-attest logic, remove GRPC specific code and encapsulate into factory/DI
 - Go through each "XXYYConnection" concrete class and delegate Connection<Y,Y> creation to factory pattern or similar
 - Move PossibleNIOSSLCertificate change into all protocols and shared code
 - Move GrpcChannelManager() into a DI call on TransportProtocol option ? or nil and set only from Grpc init code ?
 */
struct NetworkConfig {
    static func make(consensusUrl: String, fogUrl: String, attestation: AttestationConfig, transportProtocol: TransportProtocol = .grpc)
        -> Result<NetworkConfig, InvalidInputError>
    {
        ConsensusUrl.make(string: consensusUrl).flatMap { consensusUrl in
            FogUrl.make(string: fogUrl).map { fogUrl in
                NetworkConfig(consensusUrl: consensusUrl, fogUrl: fogUrl, attestation: attestation, transportProtocol: transportProtocol)
            }
        }
    }

    let consensusUrl: ConsensusUrl
    let fogUrl: FogUrl

    private let attestation: AttestationConfig

    var transportProtocol: TransportProtocol = .grpc

    var possibleConsensusTrustRoots: PossibleNIOSSLCertificates?
    var possibleFogTrustRoots: PossibleNIOSSLCertificates?

    var consensusAuthorization: BasicCredentials?
    var fogUserAuthorization: BasicCredentials?

    var httpRequester: HttpRequester?
    
    init(consensusUrl: ConsensusUrl, fogUrl: FogUrl, attestation: AttestationConfig, transportProtocol: TransportProtocol = .grpc) {
        self.consensusUrl = consensusUrl
        self.fogUrl = fogUrl
        self.attestation = attestation
        self.transportProtocol = transportProtocol
    }

    var consensus: AttestedConnectionConfig<ConsensusUrl> {
        AttestedConnectionConfig(
            url: consensusUrl,
            transportProtocolOption: transportProtocol.option,
            attestation: attestation.consensus,
            trustRoots: possibleConsensusTrustRoots,
            authorization: consensusAuthorization)
    }

    var blockchain: ConnectionConfig<ConsensusUrl> {
        ConnectionConfig(
            url: consensusUrl,
            transportProtocolOption: transportProtocol.option,
            trustRoots: possibleConsensusTrustRoots,
            authorization: consensusAuthorization)
    }

    var fogView: AttestedConnectionConfig<FogUrl> {
        AttestedConnectionConfig(
            url: fogUrl,
            transportProtocolOption: transportProtocol.option,
            attestation: attestation.fogView,
            trustRoots: possibleFogTrustRoots,
            authorization: fogUserAuthorization)
    }

    var fogMerkleProof: AttestedConnectionConfig<FogUrl> {
        AttestedConnectionConfig(
            url: fogUrl,
            transportProtocolOption: transportProtocol.option,
            attestation: attestation.fogMerkleProof,
            trustRoots: possibleFogTrustRoots,
            authorization: fogUserAuthorization)
    }

    var fogKeyImage: AttestedConnectionConfig<FogUrl> {
        AttestedConnectionConfig(
            url: fogUrl,
            transportProtocolOption: transportProtocol.option,
            attestation: attestation.fogKeyImage,
            trustRoots: possibleFogTrustRoots,
            authorization: fogUserAuthorization)
    }

    var fogBlock: ConnectionConfig<FogUrl> {
        ConnectionConfig(
            url: fogUrl,
            transportProtocolOption: transportProtocol.option,
            trustRoots: possibleFogTrustRoots,
            authorization: fogUserAuthorization)
    }

    var fogUntrustedTxOut: ConnectionConfig<FogUrl> {
        ConnectionConfig(
            url: fogUrl,
            transportProtocolOption: transportProtocol.option,
            trustRoots: possibleFogTrustRoots,
            authorization: fogUserAuthorization)
    }

    var fogReportAttestation: Attestation { attestation.fogReport }
    
    @discardableResult mutating public func setConsensusTrustRoots(_ trustRoots: [Data])
        -> Result<(), InvalidInputError>
    {
        switch transportProtocol.certificateValidator.validate(trustRoots) {
        case .success(let certificate):
            self.possibleConsensusTrustRoots = certificate
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
    
    @discardableResult mutating public func setFogTrustRoots(_ trustRoots: [Data])
        -> Result<(), InvalidInputError>
    {
        switch transportProtocol.certificateValidator.validate(trustRoots) {
        case .success(let certificate):
            self.possibleFogTrustRoots = certificate
            return .success(())
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension NetworkConfig {
    struct AttestationConfig {
        let consensus: Attestation
        let fogView: Attestation
        let fogKeyImage: Attestation
        let fogMerkleProof: Attestation
        let fogReport: Attestation
    }
}

extension NetworkConfig {
}
