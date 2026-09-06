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
        if let fog = fogTrustRoots[.http] as? SecSSLCertificates,
           case .failure(let error) = requester.setFogTrustRoots(fog) {
            logger.error("Fog trust roots stay unpinned: \(error)", logFunction: false)
        }
        if let consensus = consensusTrustRoots[.http] as? SecSSLCertificates,
           case .failure(let error) = requester.setConsensusTrustRoots(consensus) {
            logger.error("Consensus trust roots stay unpinned: \(error)", logFunction: false)
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
    private func validatedCertificates(
        _ trustRoots: [Data]
    ) -> (grpc: PossibleCertificates, http: PossibleCertificates) {
        let grpc = TransportProtocol.grpc.certificateValidator.validate(trustRoots)
        let http = TransportProtocol.http.certificateValidator.validate(trustRoots)
        return (grpc, http)
    }

    private func currentProtocolValidation(grpc: PossibleCertificates, http: PossibleCertificates)
        -> Result<(), InvalidInputError>
    {
        switch (transportProtocol, grpc, http) {
        case (.grpc, .success, _):
            return .success(())
        case (.grpc, .failure(let error), _):
            return .failure(error)
        case (.http, _, .success):
            return .success(())
        case (.http, _, .failure(let error)):
            return .failure(error)
        case (_, _, _):
            return .failure(InvalidInputError("Empty certificates"))
        }
    }
}

extension NetworkConfig {
    @discardableResult mutating public func setConsensusTrustRoots(_ trustRoots: [Data])
        -> Result<(), InvalidInputError>
    {
        setTrustRoots(trustRoots, into: \.consensusTrustRoots) { requester, certificates in
            requester.setConsensusTrustRoots(certificates)
        }
    }

    @discardableResult mutating public func setFogTrustRoots(_ trustRoots: [Data])
        -> Result<(), InvalidInputError>
    {
        setTrustRoots(trustRoots, into: \.fogTrustRoots) { requester, certificates in
            requester.setFogTrustRoots(certificates)
        }
    }

    // The requester takes the http roots before the dictionary keeps them, so
    // a refusal will leave the http roots that are already pinned in place.
    private mutating func setTrustRoots(
        _ trustRoots: [Data],
        into roots: WritableKeyPath<NetworkConfig, [TransportProtocol: SSLCertificates]>,
        pushedBy push: (HttpRequester, SecSSLCertificates) -> Result<(), InvalidInputError>
    ) -> Result<(), InvalidInputError> {
        let (grpc, http) = validatedCertificates(trustRoots)

        if let certificates = try? grpc.get() {
            self[keyPath: roots][.grpc] = certificates
        }
        if let certificates = try? http.get() {
            // A requester takes only Sec certificates, and nil there clears the
            // roots it holds, so a cast that fails answers as a failure.
            guard let httpCertificates = certificates as? SecSSLCertificates else {
                return .failure(InvalidInputError("HTTP trust roots hold another type"))
            }
            if let requester = httpRequester,
               case .failure(let error) = push(requester, httpCertificates) {
                return .failure(error)
            }
            self[keyPath: roots][.http] = certificates
        }

        return currentProtocolValidation(grpc: grpc, http: http)
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
