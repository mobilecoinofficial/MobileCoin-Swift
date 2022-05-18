//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

// chose to avoid the extension on the Generic UrlLoadBalancer<> as the
// use of the fixture would be obtrusive
struct UrlLoadBalancerFixtures {
    let validUrlsConsensusUrlBalancer: SequentialUrlLoadBalancer<ConsensusUrl>
    let validUrlsFogUrlBalancer: SequentialUrlLoadBalancer<FogUrl>
    let initialInvalidUrlFogUrlBalancer: SequentialUrlLoadBalancer<FogUrl>
    let initialInvalidConsensusUrlBalancer: SequentialUrlLoadBalancer<ConsensusUrl>

    init() throws {
        validUrlsConsensusUrlBalancer = try Self.createValidConsensusUrlLoadBalancer()
        validUrlsFogUrlBalancer = try Self.createValidFogUrlLoadBalancer()
        initialInvalidUrlFogUrlBalancer = try Self.createFogUrlLoadBalancerWithInitialInvalidUrl()
        initialInvalidConsensusUrlBalancer =
            try Self.createConsensusUrlLoadBalancerWithInitialInvalidUrl()
    }
}

extension UrlLoadBalancerFixtures {
    struct ValidBlockchain {
        let loadBalancer: SequentialUrlLoadBalancer<ConsensusUrl>
        let blockchainService: BlockchainConnection
       
        init(with: TransportProtocol) throws {
            self.loadBalancer = try UrlLoadBalancerFixtures().validUrlsConsensusUrlBalancer
            self.blockchainService = try IntegrationTestFixtures.createBlockchainConnection(
                for: transportProtocol,
                using: loadBalancer)
        }
    }
}

extension UrlLoadBalancerFixtures {
    fileprivate static func createValidConsensusUrlLoadBalancer()
    throws -> SequentialUrlLoadBalancer<ConsensusUrl> {
        // same url purposefully doubled-up, as we use the current index to detect rotation
        let urlStrings = [
            IntegrationTestFixtures.network.consensusUrl,
            IntegrationTestFixtures.network.consensusUrl,
        ]
        let consensusUrls = try ConsensusUrl.make(strings: urlStrings).get()
        return SequentialUrlLoadBalancer(urls: consensusUrls)
    }

    fileprivate static func createValidFogUrlLoadBalancer()
    throws -> SequentialUrlLoadBalancer<FogUrl> {
        // same url purposefully doubled-up, as we use the current index to detect rotation
        let urlStrings = [
            IntegrationTestFixtures.network.fogUrl,
            IntegrationTestFixtures.network.fogUrl,
        ]
        let fogUrls = try FogUrl.make(strings: urlStrings).get()
        return SequentialUrlLoadBalancer(urls: fogUrls)
    }

    fileprivate static func createConsensusUrlLoadBalancerWithInitialInvalidUrl()
    throws -> SequentialUrlLoadBalancer<ConsensusUrl> {
        let urlStrings = [
            IntegrationTestFixtures.invalidConsensusUrl,
            IntegrationTestFixtures.network.consensusUrl,
        ]
        let consensusUrls = try ConsensusUrl.make(strings: urlStrings).get()
        return SequentialUrlLoadBalancer(urls: consensusUrls)
    }

    fileprivate static func createFogUrlLoadBalancerWithInitialInvalidUrl()
    throws -> SequentialUrlLoadBalancer<FogUrl> {
        let urlStrings = [
            IntegrationTestFixtures.invalidFogUrl,
            IntegrationTestFixtures.network.fogUrl,
        ]
        let fogUrls = try FogUrl.make(strings: urlStrings).get()
        return SequentialUrlLoadBalancer(urls: fogUrls)
    }
}
