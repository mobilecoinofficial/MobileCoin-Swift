//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

@testable import MobileCoin
import XCTest

extension IntegrationTestFixtures {

    static func createFogViewConnection(
        for transportProtocol: TransportProtocol,
        using fogUrlLoadBalancer: SequentialUrlLoadBalancer<FogUrl>
    ) throws -> FogViewConnection {
        fogUrlLoadBalancer.rotationEnabled = false

        let consensusUrlLoadBalancer = try UrlLoadBalancerFixtures().validUrlsConsensusUrlBalancer

        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer)

        let fogView = FogViewConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        fogUrlLoadBalancer.rotationEnabled = true
        return fogView
    }

    static func createFogUntrustedTxOutConnection(
        for transportProtocol: TransportProtocol,
        using fogUrlLoadBalancer: SequentialUrlLoadBalancer<FogUrl>
    ) throws -> FogUntrustedTxOutConnection {
        fogUrlLoadBalancer.rotationEnabled = false

        let consensusUrlLoadBalancer = try UrlLoadBalancerFixtures().validUrlsConsensusUrlBalancer

        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer)

        let fogUntrustedTxOut = FogUntrustedTxOutConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        fogUrlLoadBalancer.rotationEnabled = true
        return fogUntrustedTxOut
    }

    static func createFogMerkleProofConnection(
        for transportProtocol: TransportProtocol,
        using fogUrlLoadBalancer: SequentialUrlLoadBalancer<FogUrl>
    ) throws -> FogMerkleProofConnection {
        fogUrlLoadBalancer.rotationEnabled = false

        let consensusUrlLoadBalancer = try UrlLoadBalancerFixtures().validUrlsConsensusUrlBalancer
        
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer)

        let fogMerkleProof = FogMerkleProofConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        fogUrlLoadBalancer.rotationEnabled = true
        return fogMerkleProof
    }

    static func createFogKeyImageConnection(
        for transportProtocol: TransportProtocol,
        using fogUrlLoadBalancer: SequentialUrlLoadBalancer<FogUrl>
    ) throws -> FogKeyImageConnection {
        fogUrlLoadBalancer.rotationEnabled = false

        let consensusUrlLoadBalancer = try UrlLoadBalancerFixtures().validUrlsConsensusUrlBalancer

        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer)

        let fogKeyImage = FogKeyImageConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        fogUrlLoadBalancer.rotationEnabled = true
        return fogKeyImage
    }

    static func createFogBlockConnection(
        for transportProtocol: TransportProtocol,
        using fogUrlLoadBalancer: SequentialUrlLoadBalancer<FogUrl>
    ) throws -> FogBlockConnection {
        fogUrlLoadBalancer.rotationEnabled = false

        let consensusUrlLoadBalancer = try UrlLoadBalancerFixtures().validUrlsConsensusUrlBalancer

        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer)

        let fogBlock = FogBlockConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        fogUrlLoadBalancer.rotationEnabled = true
        return fogBlock
    }

    static func createBlockchainConnection(
        for transportProtocol: TransportProtocol,
        using consensusUrlLoadBalancer: SequentialUrlLoadBalancer<ConsensusUrl>
    ) throws -> BlockchainConnection {
        consensusUrlLoadBalancer.rotationEnabled = false

        let fogUrlLoadBalancer = try UrlLoadBalancerFixtures().validUrlsFogUrlBalancer

        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer)

        let blockchain = BlockchainConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        consensusUrlLoadBalancer.rotationEnabled = true
        return blockchain
    }

    static func createConsensusConnection(
        for transportProtocol: TransportProtocol,
        using consensusUrlLoadBalancer: SequentialUrlLoadBalancer<ConsensusUrl>
    ) throws -> ConsensusConnection {
        consensusUrlLoadBalancer.rotationEnabled = false

        let fogUrlLoadBalancer = try UrlLoadBalancerFixtures().validUrlsFogUrlBalancer

        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer)

        let consensus = ConsensusConnection(
            httpFactory: HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester),
            grpcFactory: GrpcProtocolConnectionFactory(),
            config: networkConfig,
            targetQueue: DispatchQueue.main)

        consensusUrlLoadBalancer.rotationEnabled = true
        return consensus
    }

    static func createConsensusConnectionWithInvalidUrls(transportProtocol: TransportProtocol)
    throws -> ConsensusConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfigWithInvalidUrls(
            using: transportProtocol)
        return createConsensusConnection(networkConfig: networkConfig)
    }

    static func createConsensusConnection(networkConfig: NetworkConfig) -> ConsensusConnection {
        let httpFactory = HttpProtocolConnectionFactory(
            httpRequester: networkConfig.httpRequester ?? DefaultHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return ConsensusConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            config: networkConfig,
            targetQueue: DispatchQueue.main)
    }

    static func createFogBlockConnectionWithInvalidUrls(using transportProtocol: TransportProtocol)
    throws -> FogBlockConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfigWithInvalidUrls(
            using: transportProtocol)
        return createFogBlockConnection(networkConfig: networkConfig)
    }

    static func createFogBlockConnection(networkConfig: NetworkConfig) -> FogBlockConnection {
        let httpFactory = HttpProtocolConnectionFactory(
            httpRequester: networkConfig.httpRequester ?? DefaultHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return FogBlockConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            config: networkConfig,
            targetQueue: DispatchQueue.main)
    }
}
