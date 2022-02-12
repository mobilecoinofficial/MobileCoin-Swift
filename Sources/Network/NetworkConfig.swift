//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

struct NetworkConfig {
    static func make(consensusUrlLoadBalancer: consensusUrlLoadBalancer, fogUrlLoadBalancer: fogUrlLoadBalancer, attestation: AttestationConfig, transportProtocol: TransportProtocol)
        -> Result<NetworkConfig, InvalidInputError>
    {
        NetworkConfig(consensusUrl: consensusUrl, fogUrl: fogUrl, attestation: attestation, transportProtocol: transportProtocol)
    }

    private let attestation: AttestationConfig
    private let consensusUrlLoadBalancer: RandomUrlLoadBalancer<ConsensusUrl>
    private let fogUrlLoadBalancer: RandomUrlLoadBalancer<FogUrl>

    var transportProtocol: TransportProtocol

    var consensusTrustRoots: [TransportProtocol: SSLCertificates] = [:]
    var fogTrustRoots: [TransportProtocol: SSLCertificates] = [:]

    var consensusAuthorization: BasicCredentials?
    var fogUserAuthorization: BasicCredentials?

    var httpRequester: HttpRequester? {
        didSet {
            httpRequester?.setFogTrustRoots(fogTrustRoots[.http] as? SecSSLCertificates)
            httpRequester?.setConsensusTrustRoots(consensusTrustRoots[.http] as? SecSSLCertificates)
        }
    }

    init(consensusUrlLoadBalancer: RandomUrlLoadBalancer<ConsensusUrl>, fogUrlLoadBalancer: RandomUrlLoadBalancer<FogUrl>, attestation: AttestationConfig, transportProtocol: TransportProtocol) {
        self.attestation = attestation
        self.transportProtocol = transportProtocol
        self.consensusUrlLoadBalancer = consensusUrlLoadBalancer
        self.fogUrlLoadBalancer = fogUrlLoadBalancer
    }

    var consensus: AttestedConnectionConfig<ConsensusUrl> {
        AttestedConnectionConfig(
            urlLoadBalancer: RandomUrlLoadBalancer(urls:consensusUrls),
            transportProtocolOption: transportProtocol.option,
            attestation: attestation.consensus,
            trustRoots: consensusTrustRoots,
            authorization: consensusAuthorization)
    }

    var blockchain: ConnectionConfig<ConsensusUrl> {
        ConnectionConfig(
            urlLoadBalancer: RandomUrlLoadBalancer(urls:consensusUrls),
            transportProtocolOption: transportProtocol.option,
            trustRoots: consensusTrustRoots,
            authorization: consensusAuthorization)
    }

    var fogView: AttestedConnectionConfig<FogUrl> {
        AttestedConnectionConfig(
            urlLoadBalancer: RandomUrlLoadBalancer(urls:fogUrls),
            transportProtocolOption: transportProtocol.option,
            attestation: attestation.fogView,
            trustRoots: fogTrustRoots,
            authorization: fogUserAuthorization)
    }

    var fogMerkleProof: AttestedConnectionConfig<FogUrl> {
        AttestedConnectionConfig(
            urlLoadBalancer: RandomUrlLoadBalancer(urls:fogUrls),
            transportProtocolOption: transportProtocol.option,
            attestation: attestation.fogMerkleProof,
            trustRoots: fogTrustRoots,
            authorization: fogUserAuthorization)
    }

    var fogKeyImage: AttestedConnectionConfig<FogUrl> {
        AttestedConnectionConfig(
            urlLoadBalancer: RandomUrlLoadBalancer(urls:fogUrls),
            transportProtocolOption: transportProtocol.option,
            attestation: attestation.fogKeyImage,
            trustRoots: fogTrustRoots,
            authorization: fogUserAuthorization)
    }

    var fogBlock: ConnectionConfig<FogUrl> {
        ConnectionConfig(
            urlLoadBalancer: RandomUrlLoadBalancer(urls:fogUrls),
            transportProtocolOption: transportProtocol.option,
            trustRoots: fogTrustRoots,
            authorization: fogUserAuthorization)
    }

    var fogUntrustedTxOut: ConnectionConfig<FogUrl> {
        ConnectionConfig(
            urlLoadBalancer: RandomUrlLoadBalancer(urls:fogUrls),
            transportProtocolOption: transportProtocol.option,
            trustRoots: fogTrustRoots,
            authorization: fogUserAuthorization)
    }

    var fogReportAttestation: Attestation { attestation.fogReport }

    @discardableResult mutating public func setConsensusTrustRoots(_ trustRoots: [Data])
        -> Result<(), InvalidInputError>
    {
        let (grpc, http) = validatedCertificates(trustRoots)
        
        self.consensusTrustRoots[.grpc] = try? grpc.get()
        self.consensusTrustRoots[.http] = try? http.get()
        self.httpRequester?.setConsensusTrustRoots(try? http.get() as? SecSSLCertificates)
        
        return currentProtocolValidation(grpc: grpc, http: http)
    }

    @discardableResult mutating public func setFogTrustRoots(_ trustRoots: [Data])
        -> Result<(), InvalidInputError>
    {
        let (grpc, http) = validatedCertificates(trustRoots)
        
        self.fogTrustRoots[.grpc] = try? grpc.get()
        self.fogTrustRoots[.http] = try? http.get()
        self.httpRequester?.setFogTrustRoots(try? http.get() as? SecSSLCertificates)
        
        return currentProtocolValidation(grpc: grpc, http: http)
    }
    
    private typealias PossibleCertificates = Result<SSLCertificates, InvalidInputError>
    private func validatedCertificates(_ trustRoots: [Data]) -> (grpc: PossibleCertificates, http:PossibleCertificates) {
        let grpc = TransportProtocol.grpc.certificateValidator.validate(trustRoots)
        let http = TransportProtocol.http.certificateValidator.validate(trustRoots)
        return (grpc, http)
    }
    
    private func currentProtocolValidation(grpc: PossibleCertificates, http: PossibleCertificates)
        -> Result<(), InvalidInputError>
    {
        switch (transportProtocol, grpc, http) {
        case (.grpc, .success( _), _):
            return .success(())
        case (.grpc, .failure(let error), _):
            return .failure(error)
        case (.http, _, .success( _)):
            return .success(())
        case (.http, _, .failure(let error)):
            return .failure(error)
        case (_, _, _):
            return .failure(InvalidInputError("Empty certificates"))
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
