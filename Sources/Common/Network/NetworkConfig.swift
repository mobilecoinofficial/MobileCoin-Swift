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

    var mistyswapUrls: [MistyswapUrl] {
        mistyswapLoadBalancer?.urlsTyped ?? []
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
            pushStoredTrustRoots()
        }
    }

    // Answers with the config's own requester, and gives the config a
    // DefaultHttpRequester first whenever it holds none.
    mutating func filledHttpRequester() -> HttpRequester {
        if let requester = httpRequester {
            return requester
        }
        let requester = DefaultHttpRequester()
        httpRequester = requester
        return requester
    }

    // A property setter answers with nothing, so a refusal only goes to the
    // log. Roots the config doesn't hold leave the requester's own in place.
    private func pushStoredTrustRoots() {
        guard let requester = httpRequester else { return }

        let fog = (fogTrustRoots[.http] as? SecSSLCertificates)
            .map { (certificates: $0, hosts: fogUrls.map(\.host)) }
        let consensus = (consensusTrustRoots[.http] as? SecSSLCertificates)
            .map { (certificates: $0, hosts: consensusUrls.map(\.host)) }
        let mistyswap = (mistyswapTrustRoots[.http] as? SecSSLCertificates)
            .map { (certificates: $0, hosts: mistyswapUrls.map(\.host)) }

        // A same-module requester takes every held root under one lock, so a
        // concurrent read never observes only some of them applied.
        if let requester = requester as? DefaultHttpRequester {
            requester.setAllTrustRoots(fog: fog, consensus: consensus, mistyswap: mistyswap)
            return
        }

        if let fog = fog, case .failure(let error) = requester.setFogTrustRoots(
            fog.certificates, hosts: fog.hosts) {
            logger.error("Fog trust roots stay unpinned: \(error)", logFunction: false)
        }
        if let consensus = consensus, case .failure(let error) = requester.setConsensusTrustRoots(
            consensus.certificates, hosts: consensus.hosts) {
            logger.error("Consensus trust roots stay unpinned: \(error)", logFunction: false)
        }
        if let mistyswap = mistyswap, case .failure(let error) = requester.setMistyswapTrustRoots(
            mistyswap.certificates, hosts: mistyswap.hosts) {
            logger.error("Mistyswap trust roots stay unpinned: \(error)", logFunction: false)
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
}

extension NetworkConfig {
    // Empty bytes parse to a certificate holding zero keys, which pins
    // against nothing while looking like a successful call.
    private static func parseNonEmpty(_ trustRoots: [Data])
        -> Result<SecSSLCertificates, InvalidInputError>
    {
        guard trustRoots.isNotEmpty else {
            return .failure(InvalidInputError("Trust roots cannot be empty"))
        }
        return SecSSLCertificates.make(trustRootBytes: trustRoots)
    }

    /// Pins `trustRoots` for the consensus hosts over HTTP. The requester takes
    /// them before the dictionary keeps them, so a refusal will leave the roots
    /// already pinned in place.
    @discardableResult mutating public func setConsensusTrustRoots(_ trustRoots: [Data])
        -> Result<(), InvalidInputError>
    {
        let certificates: SecSSLCertificates
        switch NetworkConfig.parseNonEmpty(trustRoots) {
        case .success(let parsed):
            certificates = parsed
        case .failure(let error):
            return .failure(error)
        }

        let hosts = consensusUrls.map(\.host)
        if let requester = httpRequester,
           case .failure(let error) = requester.setConsensusTrustRoots(certificates, hosts: hosts)
        {
            return .failure(error)
        }
        consensusTrustRoots[.http] = certificates
        return .success(())
    }

    /// Pins `trustRoots` for the fog hosts over HTTP. The requester takes them
    /// before the dictionary keeps them, so a refusal will leave the roots
    /// already pinned in place.
    @discardableResult mutating public func setFogTrustRoots(_ trustRoots: [Data])
        -> Result<(), InvalidInputError>
    {
        let certificates: SecSSLCertificates
        switch NetworkConfig.parseNonEmpty(trustRoots) {
        case .success(let parsed):
            certificates = parsed
        case .failure(let error):
            return .failure(error)
        }

        let hosts = fogUrls.map(\.host)
        if let requester = httpRequester,
           case .failure(let error) = requester.setFogTrustRoots(certificates, hosts: hosts) {
            return .failure(error)
        }
        fogTrustRoots[.http] = certificates
        return .success(())
    }

    /// Pins `trustRoots` for the mistyswap hosts over HTTP. The requester takes
    /// them before the dictionary keeps them, so a refusal will leave the roots
    /// already pinned in place.
    @discardableResult mutating public func setMistyswapTrustRoots(_ trustRoots: [Data])
        -> Result<(), InvalidInputError>
    {
        let certificates: SecSSLCertificates
        switch NetworkConfig.parseNonEmpty(trustRoots) {
        case .success(let parsed):
            certificates = parsed
        case .failure(let error):
            return .failure(error)
        }

        let hosts = mistyswapUrls.map(\.host)
        guard hosts.isNotEmpty else {
            return .failure(InvalidInputError("There is no mistyswap host to pin trust roots to"))
        }
        if let requester = httpRequester,
           case .failure(let error) = requester.setMistyswapTrustRoots(certificates, hosts: hosts) {
            return .failure(error)
        }
        mistyswapTrustRoots[.http] = certificates
        return .success(())
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
