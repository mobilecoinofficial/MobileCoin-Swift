//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable multiline_function_chains

import Foundation

@testable import MobileCoin
import XCTest

enum NetworkConfigFixtures {
    static let dyanmicConfig = DynamicNetworkConfig.AlphaDevelopment.make()
    static let network: NetworkPreset = .dynamic(dyanmicConfig)
}

extension NetworkConfigFixtures {
    static let invalidConsensusUrl = "mc://invalid.mobilecoin.com"
    static let invalidFogUrl = "fog://invalid.mobilecoin.com"

    static func create(
        using transportProtocol: TransportProtocol
    ) throws -> NetworkConfig {
        try network.networkConfig(transportProtocol: transportProtocol)
    }

    static func create(transportProtocol: TransportProtocol, trustRoots: [Data])
    throws -> NetworkConfig {
        var networkConfig = try network.networkConfig()
        networkConfig.setConsensusTrustRoots(trustRoots)
        networkConfig.setFogTrustRoots(trustRoots)
        return networkConfig
    }

    static func create(
        transportProtocol: TransportProtocol,
        consensusUrlLoadBalancer: UrlLoadBalancer<ConsensusUrl>,
        fogUrlLoadBalancer: UrlLoadBalancer<FogUrl>
    ) throws -> NetworkConfig {

        let attestationConfig = try network.attestationConfig()

        var networkConfig = try NetworkConfig.make(
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer,
            attestation: attestationConfig,
            transportProtocol: transportProtocol).get()

        networkConfig.httpRequester = DefaultHttpRequester()
        try networkConfig.setConsensusTrustRoots(NetworkPreset.trustRootsBytes())
        try networkConfig.setFogTrustRoots(NetworkPreset.trustRootsBytes())
        networkConfig.consensusAuthorization = network.consensusCredentials
        networkConfig.fogUserAuthorization = network.fogUserCredentials

        return networkConfig
    }

    static func createWithInvalidUrls(using transportProtocol: TransportProtocol)
    throws -> NetworkConfig {
        let attestationConfig = try network.attestationConfig()

        return try ConsensusUrl.make(strings: [invalidConsensusUrl]).flatMap { consensusUrls in
            RandomUrlLoadBalancer<ConsensusUrl>.make(urls: consensusUrls).flatMap
            { consensusUrlLoadBalancer in
                FogUrl.make(strings: [invalidFogUrl]).flatMap { fogUrls in
                    RandomUrlLoadBalancer<FogUrl>.make(urls: fogUrls).map { fogUrlLoadBalancer in
                        NetworkConfig(
                            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
                            fogUrlLoadBalancer: fogUrlLoadBalancer,
                            attestation: attestationConfig,
                            transportProtocol: transportProtocol)
                    }
                }
            }
        }.get()
    }

    static func createWithInvalidCredentials(using transportProtocol: TransportProtocol)
    throws -> NetworkConfig {
        var networkConfig = try network.networkConfig()
        networkConfig.consensusAuthorization = network.invalidCredentials
        networkConfig.fogUserAuthorization = network.invalidCredentials
        return networkConfig
    }
}
