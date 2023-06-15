//
//  Copyright (c) 2020-2023 MobileCoin. All rights reserved.
//
@testable import MobileCoin
import XCTest

enum UnitTestFixtures {
    static let invalidConsensusUrl = "mc://invalid.mobilecoin.com"
    static let invalidFogUrl = "fog://invalid.mobilecoin.com"
    static let invalidMistyswapUrl = "mistyswap://invalid.mobilecoin.com"

    static func failingHttpNetworkConfig(
        _ fogUrlLoadBalancer: SequentialUrlLoadBalancer<FogUrl>,
        _ consensusUrlLoadBalancer: SequentialUrlLoadBalancer<ConsensusUrl>,
        _ mistyswapUrlLoadBalancer: SequentialUrlLoadBalancer<MistyswapUrl>,
        _ httpRequester: HttpRequester
    ) throws -> NetworkConfig {
        let attestation = Attestation(
            mrEnclaves: [],
            mrSigners: [])

        let attestationConfig = NetworkConfig.AttestationConfig(
            consensus: attestation,
            fogView: attestation,
            fogKeyImage: attestation,
            fogMerkleProof: attestation,
            fogReport: attestation,
            mistyswap: attestation)

        var networkConfig = try NetworkConfig.make(
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer,
            attestation: attestationConfig,
            transportProtocol: .http,
            mistyswapLoadBalancer: mistyswapUrlLoadBalancer
        )
            .get()

        networkConfig.httpRequester = httpRequester
        return networkConfig
    }

    static func createFogViewConnection(
        using fogUrlLoadBalancer: SequentialUrlLoadBalancer<FogUrl>,
        httpRequester: HttpRequester
    ) throws -> FogViewConnection {
        let networkConfig = try failingHttpNetworkConfig(
            fogUrlLoadBalancer,
            UrlLoadBalancerFixtures().invalidConsensusUrlBalancer,
            UrlLoadBalancerFixtures().invalidMistyswapUrlBalancer,
            httpRequester)

        fogUrlLoadBalancer.rotationEnabled = false
        let fogView = FogViewConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)
        fogUrlLoadBalancer.rotationEnabled = true

        return fogView
    }

    static func createFogUntrustedTxOutConnection(
        using fogUrlLoadBalancer: SequentialUrlLoadBalancer<FogUrl>,
        httpRequester: HttpRequester
    ) throws -> FogUntrustedTxOutConnection {
        let networkConfig = try failingHttpNetworkConfig(
            fogUrlLoadBalancer,
            UrlLoadBalancerFixtures().invalidConsensusUrlBalancer,
            UrlLoadBalancerFixtures().invalidMistyswapUrlBalancer,
            httpRequester)

        fogUrlLoadBalancer.rotationEnabled = false
        let fogUntrustedTxOut = FogUntrustedTxOutConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)
        fogUrlLoadBalancer.rotationEnabled = true

        return fogUntrustedTxOut
    }

    static func createFogMerkleProofConnection(
        using fogUrlLoadBalancer: SequentialUrlLoadBalancer<FogUrl>,
        httpRequester: HttpRequester
    ) throws -> FogMerkleProofConnection {
        let networkConfig = try failingHttpNetworkConfig(
            fogUrlLoadBalancer,
            UrlLoadBalancerFixtures().invalidConsensusUrlBalancer,
            UrlLoadBalancerFixtures().invalidMistyswapUrlBalancer,
            httpRequester)

        fogUrlLoadBalancer.rotationEnabled = false
        let fogMerkleProof = FogMerkleProofConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)
        fogUrlLoadBalancer.rotationEnabled = true

        return fogMerkleProof
    }

    static func createFogKeyImageConnection(
        using fogUrlLoadBalancer: SequentialUrlLoadBalancer<FogUrl>,
        httpRequester: HttpRequester
    ) throws -> FogKeyImageConnection {
        let networkConfig = try failingHttpNetworkConfig(
            fogUrlLoadBalancer,
            UrlLoadBalancerFixtures().invalidConsensusUrlBalancer,
            UrlLoadBalancerFixtures().invalidMistyswapUrlBalancer,
            httpRequester)

        fogUrlLoadBalancer.rotationEnabled = false
        let fogKeyImage = FogKeyImageConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)
        fogUrlLoadBalancer.rotationEnabled = true

        return fogKeyImage
    }

    static func createFogBlockConnection(
        using fogUrlLoadBalancer: SequentialUrlLoadBalancer<FogUrl>,
        httpRequester: HttpRequester
    ) throws -> FogBlockConnection {
        let networkConfig = try failingHttpNetworkConfig(
            fogUrlLoadBalancer,
            UrlLoadBalancerFixtures().invalidConsensusUrlBalancer,
            UrlLoadBalancerFixtures().invalidMistyswapUrlBalancer,
            httpRequester)

        fogUrlLoadBalancer.rotationEnabled = false
        let fogBlock = FogBlockConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)
        fogUrlLoadBalancer.rotationEnabled = true

        return fogBlock
    }

    static func createBlockchainConnection(
        using consensusUrlLoadBalancer: SequentialUrlLoadBalancer<ConsensusUrl>,
        httpRequester: HttpRequester
    ) throws -> BlockchainConnection {
        let networkConfig = try failingHttpNetworkConfig(
            UrlLoadBalancerFixtures().invalidFogUrlBalancer,
            consensusUrlLoadBalancer,
            UrlLoadBalancerFixtures().invalidMistyswapUrlBalancer,
            httpRequester)

        consensusUrlLoadBalancer.rotationEnabled = false
        let blockchain = BlockchainConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)
        consensusUrlLoadBalancer.rotationEnabled = true

        return blockchain
    }

    static func createConsensusConnection(
        using consensusUrlLoadBalancer: SequentialUrlLoadBalancer<ConsensusUrl>,
        httpRequester: HttpRequester
    ) throws -> ConsensusConnection {
        let networkConfig = try failingHttpNetworkConfig(
            UrlLoadBalancerFixtures().invalidFogUrlBalancer,
            consensusUrlLoadBalancer,
            UrlLoadBalancerFixtures().invalidMistyswapUrlBalancer,
            httpRequester)

        consensusUrlLoadBalancer.rotationEnabled = false
        let consensus = ConsensusConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)
        consensusUrlLoadBalancer.rotationEnabled = true

        return consensus
    }
}
