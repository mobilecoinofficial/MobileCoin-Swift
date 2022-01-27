//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

struct NetworkConfig {
    static func make(consensusUrl: String, fogUrl: String, attestation: AttestationConfig, transportProtocol: TransportProtocol)
        -> Result<NetworkConfig, InvalidInputError>
    {
        ConsensusUrl.make(string: consensusUrl).flatMap { consensusUrl in
            FogUrl.make(string: fogUrl).map { fogUrl in
                NetworkConfig(consensusUrl: consensusUrl, fogUrl: fogUrl, attestation: attestation, transportProtocol: transportProtocol)
            }
        }
    }

    static func make(consensusUrls: [String], fogUrls: [String], attestation: AttestationConfig, transportProtocol: TransportProtocol)
        -> Result<NetworkConfig, InvalidInputError>
    {
        ConsensusUrl.make(strings: consensusUrls).flatMap { consensusUrls in
            FogUrl.make(strings: fogUrls).map { fogUrls in
                NetworkConfig(consensusUrls: consensusUrls, fogUrls: fogUrls, attestation: attestation, transportProtocol: transportProtocol)
            }
        }
    }

    private let attestation: AttestationConfig

    var transportProtocol: TransportProtocol

    var possibleConsensusTrustRoots: PossibleNIOSSLCertificates?
    var possibleFogTrustRoots: PossibleNIOSSLCertificates?

    var consensusAuthorization: BasicCredentials?
    var fogUserAuthorization: BasicCredentials?

    var httpRequester: HttpRequester?

    let fogUrls: [FogUrl]
    let consensusUrls: [ConsensusUrl]

    init(consensusUrl: ConsensusUrl, fogUrl: FogUrl, attestation: AttestationConfig, transportProtocol: TransportProtocol) {
        self.init(consensusUrls:[consensusUrl], fogUrls:[fogUrl], attestation: attestation, transportProtocol: transportProtocol)
    }

    init(consensusUrls: [ConsensusUrl], fogUrls: [FogUrl], attestation: AttestationConfig, transportProtocol: TransportProtocol) {

        self.fogUrls = fogUrls
        self.consensusUrls = consensusUrls
        self.attestation = attestation
        self.transportProtocol = transportProtocol
    }

    var consensus: AttestedConnectionConfig<ConsensusUrl> {
        AttestedConnectionConfig(
            urlLoadBalancer: try! RandomUrlLoadBalancer(urls:consensusUrls),
            transportProtocolOption: transportProtocol.option,
            attestation: attestation.consensus,
            trustRoots: possibleConsensusTrustRoots,
            authorization: consensusAuthorization)
    }

    var blockchain: ConnectionConfig<ConsensusUrl> {
        ConnectionConfig(
            urlLoadBalancer: try! RandomUrlLoadBalancer(urls:consensusUrls),
            transportProtocolOption: transportProtocol.option,
            trustRoots: possibleConsensusTrustRoots,
            authorization: consensusAuthorization)
    }

    var fogView: AttestedConnectionConfig<FogUrl> {
        AttestedConnectionConfig(
            urlLoadBalancer: try! RandomUrlLoadBalancer(urls:fogUrls),
            transportProtocolOption: transportProtocol.option,
            attestation: attestation.fogView,
            trustRoots: possibleFogTrustRoots,
            authorization: fogUserAuthorization)
    }

    var fogMerkleProof: AttestedConnectionConfig<FogUrl> {
        AttestedConnectionConfig(
            urlLoadBalancer: try! RandomUrlLoadBalancer(urls:fogUrls),
            transportProtocolOption: transportProtocol.option,
            attestation: attestation.fogMerkleProof,
            trustRoots: possibleFogTrustRoots,
            authorization: fogUserAuthorization)
    }

    var fogKeyImage: AttestedConnectionConfig<FogUrl> {
        AttestedConnectionConfig(
            urlLoadBalancer: try! RandomUrlLoadBalancer(urls:fogUrls),
            transportProtocolOption: transportProtocol.option,
            attestation: attestation.fogKeyImage,
            trustRoots: possibleFogTrustRoots,
            authorization: fogUserAuthorization)
    }

    var fogBlock: ConnectionConfig<FogUrl> {
        ConnectionConfig(
            urlLoadBalancer: try! RandomUrlLoadBalancer(urls:fogUrls),
            transportProtocolOption: transportProtocol.option,
            trustRoots: possibleFogTrustRoots,
            authorization: fogUserAuthorization)
    }

    var fogUntrustedTxOut: ConnectionConfig<FogUrl> {
        ConnectionConfig(
            urlLoadBalancer: try! RandomUrlLoadBalancer(urls:fogUrls),
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
