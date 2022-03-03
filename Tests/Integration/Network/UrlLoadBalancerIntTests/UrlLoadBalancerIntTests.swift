//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class UrlLoadBalancerIntTests: XCTestCase {
    
    func testFogViewUrlRotates() throws {
        try testFogViewRotatesAwayFromBadUrl(transportProtocol: .http)
//        try testFogViewRotatesAwayFromBadUrl(transportProtocol: .grpc)
    }

    func testFogViewRotatesAwayFromBadUrl(transportProtocol: TransportProtocol) throws {
        // try XCTSkipUnless(IntegrationTestFixtures.network.fogRequiresCredentials)

        let expectFailure = expectation(description: "Making FogView request against invalid URL")

        let consensusUrlLoadBalancer = try createConsensusUrlLoadBalancer()
        let fogUrlLoadBalancer = try createFogUrlLoadBalancer()

        // disable url rotation during creation of connection/svc as multipe calls
        // to nextUrl() will cause rotation away from the initial invalid URL
        consensusUrlLoadBalancer.rotationEnabled = false
        fogUrlLoadBalancer.rotationEnabled = false

        let fogViewConnection = try createFogViewConnection(transportProtocol: transportProtocol,
                                                            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
                                                            fogUrlLoadBalancer: fogUrlLoadBalancer)

        // enable URL rotation prior to actual server calls
        consensusUrlLoadBalancer.rotationEnabled = true
        fogUrlLoadBalancer.rotationEnabled = true

        fogViewConnection.query(
            requestAad: FogView_QueryRequestAAD(),
            request: FogView_QueryRequest()
        ) {
            guard let error = $0.failureOrFulfill(expectation: expectFailure) else { return }

            switch error {
            case .connectionFailure:
                break
            default:
                XCTFail("error of type \(type(of: error)), \(error)")
            }
            expectFailure.fulfill()
        }
        waitForExpectations(timeout: 1000)

        let expectSuccess = expectation(description: "Making FogView request that should succeed via url rotation after prior failure")

        fogViewConnection.query(
            requestAad: FogView_QueryRequestAAD(),
            request: FogView_QueryRequest()
        ) {
            guard nil != $0.successOrFulfill(expectation: expectSuccess) else { return }
            expectSuccess.fulfill()
        }
        waitForExpectations(timeout: 100)
    }

}

extension UrlLoadBalancerIntTests {
    func createConsensusUrlLoadBalancer() throws -> SequentialUrlLoadBalancer<ConsensusUrl> {
        let urlStrings = [IntegrationTestFixtures.invalidConsensusUrl, IntegrationTestFixtures.network.consensusUrl]
        let consensusUrls = try ConsensusUrl.make(strings: urlStrings).get()
        return SequentialUrlLoadBalancer(urls: consensusUrls)
    }

    func createFogUrlLoadBalancer() throws -> SequentialUrlLoadBalancer<FogUrl> {
        let urlStrings = [IntegrationTestFixtures.invalidFogUrl, IntegrationTestFixtures.network.fogUrl]
        let fogUrls = try FogUrl.make(strings: urlStrings).get()
        return SequentialUrlLoadBalancer(urls: fogUrls)
    }

    func createFogViewConnection(
        transportProtocol: TransportProtocol,
        consensusUrlLoadBalancer: UrlLoadBalancer<ConsensusUrl>,
        fogUrlLoadBalancer: UrlLoadBalancer<FogUrl>
    ) throws -> FogViewConnection {
        let networkConfig = try IntegrationTestFixtures.createNetworkConfig(
            transportProtocol: transportProtocol,
            consensusUrlLoadBalancer: consensusUrlLoadBalancer,
            fogUrlLoadBalancer: fogUrlLoadBalancer)
        let httpFactory = HttpProtocolConnectionFactory(httpRequester: networkConfig.httpRequester)
        let grpcFactory = GrpcProtocolConnectionFactory()
        return FogViewConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            config: networkConfig,
            targetQueue: DispatchQueue.main)
    }
}
