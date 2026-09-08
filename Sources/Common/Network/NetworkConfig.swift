//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable todo

import Foundation

struct NetworkConfig {
    static func make(
        consensusUrlLoadBalancer: UrlLoadBalancer<ConsensusUrl>,
        fogUrlLoadBalancer: UrlLoadBalancer<FogUrl>,
        attestation: AttestationConfig,
        transportProtocol: TransportProtocol,
        mistyswapLoadBalancer: UrlLoadBalancer<MistyswapUrl>? = nil
    ) -> Result<NetworkConfig, InvalidInputError> {
        .success(NetworkConfig(
                    consensusUrlLoadBalancer: consensusUrlLoadBalancer,
                    fogUrlLoadBalancer: fogUrlLoadBalancer,
                    attestation: attestation,
                    transportProtocol: transportProtocol,
                    mistyswapLoadBalancer: mistyswapLoadBalancer))
    }

    private let attestation: AttestationConfig
    private let consensusUrlLoadBalancer: UrlLoadBalancer<ConsensusUrl>
    private let fogUrlLoadBalancer: UrlLoadBalancer<FogUrl>
    private let mistyswapLoadBalancer: UrlLoadBalancer<MistyswapUrl>?

    var consensusUrls: [ConsensusUrl] {
        consensusUrlLoadBalancer.urlsTyped
    }

    var fogUrls: [FogUrl] {
        fogUrlLoadBalancer.urlsTyped
    }

    var transportProtocol: TransportProtocol

    var consensusTrustRoots: [TransportProtocol: SSLCertificates] = [:]
    var fogTrustRoots: [TransportProtocol: SSLCertificates] = [:]
    var mistyswapTrustRoots: [TransportProtocol: SSLCertificates] = [:]

    var consensusAuthorization: BasicCredentials?
    var fogUserAuthorization: BasicCredentials?
    var mistyswapUserAuthorization: BasicCredentials? {
        fogUserAuthorization // TODO - revisit if we will need this
    }

    var httpRequester: HttpRequester? {
        didSet {
            httpRequester?.setFogTrustRoots(fogTrustRoots[.http] as? SecSSLCertificates)
            httpRequester?.setConsensusTrustRoots(consensusTrustRoots[.http] as? SecSSLCertificates)
        }
    }

    init(
        consensusUrlLoadBalancer: UrlLoadBalancer<ConsensusUrl>,
        fogUrlLoadBalancer: UrlLoadBalancer<FogUrl>,
        attestation: AttestationConfig,
        transportProtocol: TransportProtocol,
        mistyswapLoadBalancer: UrlLoadBalancer<MistyswapUrl>? = nil
    ) {
        self.attestation = attestation
        self.transportProtocol = transportProtocol
        self.consensusUrlLoadBalancer = consensusUrlLoadBalancer
        self.fogUrlLoadBalancer = fogUrlLoadBalancer
        self.mistyswapLoadBalancer = mistyswapLoadBalancer
    }

    func consensusConfig() -> AttestedConnectionConfig<ConsensusUrl> {
        AttestedConnectionConfig(
            url: consensusUrlLoadBalancer.nextUrl(),
            transportProtocolOption: transportProtocol.option,
            attestation: attestation.consensus,
            trustRoots: consensusTrustRoots,
            authorization: consensusAuthorization)
    }

    func blockchainConfig() -> ConnectionConfig<ConsensusUrl> {
        ConnectionConfig(
            url: consensusUrlLoadBalancer.nextUrl(),
            transportProtocolOption: transportProtocol.option,
            trustRoots: consensusTrustRoots,
            authorization: consensusAuthorization)
    }

    func fogViewConfig() -> AttestedConnectionConfig<FogUrl> {
        AttestedConnectionConfig(
            url: fogUrlLoadBalancer.nextUrl(),
            transportProtocolOption: transportProtocol.option,
            attestation: attestation.fogView,
            trustRoots: fogTrustRoots,
            authorization: fogUserAuthorization)
    }

    func fogMerkleProofConfig() -> AttestedConnectionConfig<FogUrl> {
        AttestedConnectionConfig(
            url: fogUrlLoadBalancer.nextUrl(),
            transportProtocolOption: transportProtocol.option,
            attestation: attestation.fogMerkleProof,
            trustRoots: fogTrustRoots,
            authorization: fogUserAuthorization)
    }

    func fogKeyImageConfig() -> AttestedConnectionConfig<FogUrl> {
        AttestedConnectionConfig(
            url: fogUrlLoadBalancer.nextUrl(),
            transportProtocolOption: transportProtocol.option,
            attestation: attestation.fogKeyImage,
            trustRoots: fogTrustRoots,
            authorization: fogUserAuthorization)
    }

    func fogBlockConfig() -> ConnectionConfig<FogUrl> {
        ConnectionConfig(
            url: fogUrlLoadBalancer.nextUrl(),
            transportProtocolOption: transportProtocol.option,
            trustRoots: fogTrustRoots,
            authorization: fogUserAuthorization)
    }

    func fogUntrustedTxOutConfig() -> ConnectionConfig<FogUrl> {
        ConnectionConfig(
            url: fogUrlLoadBalancer.nextUrl(),
            transportProtocolOption: transportProtocol.option,
            trustRoots: fogTrustRoots,
            authorization: fogUserAuthorization)
    }

    func mistyswapConfig() -> AttestedConnectionConfig<MistyswapUrl>? {
        guard
            let mistyswapLoadBalancer = mistyswapLoadBalancer,
            let mistyswapAttestation = attestation.mistyswap
        else {
            return nil
        }

        return AttestedConnectionConfig(
            url: mistyswapLoadBalancer.nextUrl(),
            transportProtocolOption: transportProtocol.option,
            attestation: mistyswapAttestation,
            trustRoots: mistyswapTrustRoots,
            authorization: mistyswapUserAuthorization)
    }

    func mistyswapUntrustedConfig() -> ConnectionConfig<MistyswapUrl>? {
        guard
            let mistyswapLoadBalancer = mistyswapLoadBalancer
        else {
            return nil
        }

        return ConnectionConfig(
            url: mistyswapLoadBalancer.nextUrl(),
            transportProtocolOption: transportProtocol.option,
            trustRoots: mistyswapTrustRoots,
            authorization: mistyswapUserAuthorization)
    }

    var fogReportAttestation: Attestation { attestation.fogReport }

    private typealias PossibleCertificates = Result<SSLCertificates, InvalidInputError>
    private func validatedCertificates(_ trustRoots: [Data]) -> PossibleCertificates {
        TransportProtocol.http.certificateValidator.validate(trustRoots)
    }
}

extension NetworkConfig {
    @discardableResult mutating public func setConsensusTrustRoots(_ trustRoots: [Data])
        -> Result<(), InvalidInputError>
    {
        let http = validatedCertificates(trustRoots)

        self.consensusTrustRoots[.http] = try? http.get()
        self.httpRequester?.setConsensusTrustRoots(try? http.get() as? SecSSLCertificates)

        return http.map { _ in () }
    }

    @discardableResult mutating public func setFogTrustRoots(_ trustRoots: [Data])
        -> Result<(), InvalidInputError>
    {
        let http = validatedCertificates(trustRoots)

        self.fogTrustRoots[.http] = try? http.get()
        self.httpRequester?.setFogTrustRoots(try? http.get() as? SecSSLCertificates)

        return http.map { _ in () }
    }

}

extension NetworkConfig {
    struct AttestationConfig {
        let consensus: Attestation
        let fogView: Attestation
        let fogKeyImage: Attestation
        let fogMerkleProof: Attestation
        let fogReport: Attestation
        let mistyswap: Attestation?
    }
}
