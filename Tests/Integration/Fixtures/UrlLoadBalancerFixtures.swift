//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//
import LibMobileCoin
@testable import MobileCoin
import XCTest

// chose to avoid the extension on the Generic UrlLoadBalancer<> as the
// use of the fixture would be obtrusive
struct UrlLoadBalancerFixtures {
    let validUrlsFogUrlBalancer: SequentialUrlLoadBalancer<FogUrl>
    let validUrlsConsensusUrlBalancer: SequentialUrlLoadBalancer<ConsensusUrl>
    let initialInvalidUrlFogUrlBalancer: SequentialUrlLoadBalancer<FogUrl>
    let initialInvalidConsensusUrlBalancer: SequentialUrlLoadBalancer<ConsensusUrl>

    init() throws {
        validUrlsFogUrlBalancer = try Self.createValidFogUrlLoadBalancer()
        validUrlsConsensusUrlBalancer = try Self.createValidConsensusUrlLoadBalancer()
        initialInvalidUrlFogUrlBalancer = try Self.createFogUrlLoadBalancerWithInitialInvalidUrl()
        initialInvalidConsensusUrlBalancer =
            try Self.createConsensusUrlLoadBalancerWithInitialInvalidUrl()
    }
}

protocol ServiceFixture {
    var serviceName: String { get }
    var urlTypeName: String { get }
    var loadBalancer: MockUrlLoadBalancer { get }
    var useValidUrls: Bool { get }

    func callService(expect: XCTestExpectation) throws
}

extension UrlLoadBalancerFixtures {

    struct Blockchain: ServiceFixture {
        let serviceName = "Blockchain"
        let urlTypeName = "Consensus"
        let seqLoadBalancer: SequentialUrlLoadBalancer<ConsensusUrl>
        let blockchain: BlockchainConnection
        let useValidUrls: Bool

        var loadBalancer: MockUrlLoadBalancer {
            seqLoadBalancer
        }

        init(with transportProtocol: TransportProtocol, useValidUrls: Bool) throws {
            self.useValidUrls = useValidUrls

            self.seqLoadBalancer = try {
                useValidUrls
                ? try UrlLoadBalancerFixtures().validUrlsConsensusUrlBalancer
                : try UrlLoadBalancerFixtures().initialInvalidConsensusUrlBalancer
            }()

            self.blockchain = try IntegrationTestFixtures.createBlockchainConnection(
                for: transportProtocol,
                using: seqLoadBalancer)
        }

        func callService(expect: XCTestExpectation) throws {
            blockchain.getLastBlockInfo {

               if useValidUrls {
                    guard nil != $0.successOrFulfill(expectation: expect) else { return }
                    expect.fulfill()
                } else {
                    guard let error = $0.failureOrFulfill(expectation: expect) else { return }

                    switch error {
                    case .connectionFailure:
                        break
                    default:
                        XCTFail("error of type \(type(of: error)), \(error)")
                    }
                    expect.fulfill()
                }
            }
        }
    }

    struct Consensus: ServiceFixture {
        let serviceName = "Consensus"
        let urlTypeName = "Consensus"
        let seqLoadBalancer: SequentialUrlLoadBalancer<ConsensusUrl>
        let consensus: ConsensusConnection
        let useValidUrls: Bool

        init(with transportProtocol: TransportProtocol, useValidUrls: Bool) throws {
            self.useValidUrls = useValidUrls

            self.seqLoadBalancer = try {
                useValidUrls
                ? try UrlLoadBalancerFixtures().validUrlsConsensusUrlBalancer
                : try UrlLoadBalancerFixtures().initialInvalidConsensusUrlBalancer
            }()

            self.consensus = try IntegrationTestFixtures.createConsensusConnection(
                for: transportProtocol,
                using: seqLoadBalancer)
        }

        var loadBalancer: MockUrlLoadBalancer {
            seqLoadBalancer
        }

        func callService(expect: XCTestExpectation) throws {
            consensus.proposeTx(try Transaction.Fixtures.Default().tx) {
                if useValidUrls {
                    guard nil != $0.successOrFulfill(expectation: expect) else { return }
                    expect.fulfill()
                } else {
                    guard let error = $0.failureOrFulfill(expectation: expect) else { return }

                    switch error {
                    case .connectionFailure:
                        break
                    default:
                        XCTFail("error of type \(type(of: error)), \(error)")
                    }
                    expect.fulfill()
                }
            }
        }
    }

    struct FogBlock: ServiceFixture {
        let serviceName = "FogBlock"
        let urlTypeName = "Fog"
        let seqLoadBalancer: SequentialUrlLoadBalancer<FogUrl>
        let fogBlock: FogBlockConnection
        let useValidUrls: Bool

        init(with transportProtocol: TransportProtocol, useValidUrls: Bool) throws {
            self.useValidUrls = useValidUrls

            self.seqLoadBalancer = try {
                useValidUrls
                ? try UrlLoadBalancerFixtures().validUrlsFogUrlBalancer
                : try UrlLoadBalancerFixtures().initialInvalidUrlFogUrlBalancer
            }()

            self.fogBlock = try IntegrationTestFixtures.createFogBlockConnection(
                for: transportProtocol,
                using: seqLoadBalancer)
        }

        var loadBalancer: MockUrlLoadBalancer {
            seqLoadBalancer
        }

        func callService(expect: XCTestExpectation) throws {
            fogBlock.getBlocks(request: FogLedger_BlockRequest()) {
                if useValidUrls {
                    guard nil != $0.successOrFulfill(expectation: expect) else { return }
                    expect.fulfill()
                } else {
                    guard let error = $0.failureOrFulfill(expectation: expect) else { return }

                    switch error {
                    case .connectionFailure:
                        break
                    default:
                        XCTFail("error of type \(type(of: error)), \(error)")
                    }
                    expect.fulfill()
                }
            }
        }
    }

    struct FogKeyImage: ServiceFixture {
        let serviceName = "FogKeyImage"
        let urlTypeName = "Fog"
        let seqLoadBalancer: SequentialUrlLoadBalancer<FogUrl>
        let fogKeyImage: FogKeyImageConnection
        let useValidUrls: Bool

        init(with transportProtocol: TransportProtocol, useValidUrls: Bool) throws {
            self.useValidUrls = useValidUrls

            self.seqLoadBalancer = try {
                useValidUrls
                ? try UrlLoadBalancerFixtures().validUrlsFogUrlBalancer
                : try UrlLoadBalancerFixtures().initialInvalidUrlFogUrlBalancer
            }()

            self.fogKeyImage = try IntegrationTestFixtures.createFogKeyImageConnection(
                for: transportProtocol,
                using: seqLoadBalancer)
        }

        var loadBalancer: MockUrlLoadBalancer {
            seqLoadBalancer
        }

        func callService(expect: XCTestExpectation) throws {
            fogKeyImage.checkKeyImages(request: FogLedger_CheckKeyImagesRequest()) {
                if useValidUrls {
                    guard nil != $0.successOrFulfill(expectation: expect) else { return }
                    expect.fulfill()
                } else {
                    guard let error = $0.failureOrFulfill(expectation: expect) else { return }

                    switch error {
                    case .connectionFailure:
                        break
                    default:
                        XCTFail("error of type \(type(of: error)), \(error)")
                    }
                    expect.fulfill()
                }
            }
        }
    }

    struct FogMerkleProof: ServiceFixture {
        let serviceName = "FogMerkleProof"
        let urlTypeName = "Fog"
        let seqLoadBalancer: SequentialUrlLoadBalancer<FogUrl>
        let fogMerkleProof: FogMerkleProofConnection
        let useValidUrls: Bool

        init(with transportProtocol: TransportProtocol, useValidUrls: Bool) throws {
            self.useValidUrls = useValidUrls

            self.seqLoadBalancer = try {
                useValidUrls
                ? try UrlLoadBalancerFixtures().validUrlsFogUrlBalancer
                : try UrlLoadBalancerFixtures().initialInvalidUrlFogUrlBalancer
            }()

            self.fogMerkleProof = try IntegrationTestFixtures.createFogMerkleProofConnection(
                for: transportProtocol,
                using: seqLoadBalancer)
        }

        var loadBalancer: MockUrlLoadBalancer {
            seqLoadBalancer
        }

        func callService(expect: XCTestExpectation) throws {
            fogMerkleProof.getOutputs(request: FogLedger_GetOutputsRequest()) {
                if useValidUrls {
                    guard nil != $0.successOrFulfill(expectation: expect) else { return }
                    expect.fulfill()
                } else {
                    guard let error = $0.failureOrFulfill(expectation: expect) else { return }

                    switch error {
                    case .connectionFailure:
                        break
                    default:
                        XCTFail("error of type \(type(of: error)), \(error)")
                    }
                    expect.fulfill()
                }
            }
        }
    }

    struct FogUntrustedTxOut: ServiceFixture {
        let serviceName = "FogUntrustedTxOut"
        let urlTypeName = "Fog"
        let seqLoadBalancer: SequentialUrlLoadBalancer<FogUrl>
        let fogUntrustedTxOut: FogUntrustedTxOutConnection
        let useValidUrls: Bool

        init(with transportProtocol: TransportProtocol, useValidUrls: Bool) throws {
            self.useValidUrls = useValidUrls

            self.seqLoadBalancer = try {
                useValidUrls
                ? try UrlLoadBalancerFixtures().validUrlsFogUrlBalancer
                : try UrlLoadBalancerFixtures().initialInvalidUrlFogUrlBalancer
            }()

            self.fogUntrustedTxOut = try IntegrationTestFixtures.createFogUntrustedTxOutConnection(
                for: transportProtocol,
                using: seqLoadBalancer)
        }

        var loadBalancer: MockUrlLoadBalancer {
            seqLoadBalancer
        }

        func callService(expect: XCTestExpectation) throws {
            fogUntrustedTxOut.getTxOuts(request: FogLedger_TxOutRequest()) {
                if useValidUrls {
                    guard nil != $0.successOrFulfill(expectation: expect) else { return }
                    expect.fulfill()
                } else {
                    guard let error = $0.failureOrFulfill(expectation: expect) else { return }

                    switch error {
                    case .connectionFailure:
                        break
                    default:
                        XCTFail("error of type \(type(of: error)), \(error)")
                    }
                    expect.fulfill()
                }
            }
        }
    }

    struct FogView: ServiceFixture {
        let serviceName = "FogView"
        let urlTypeName = "Fog"
        let seqLoadBalancer: SequentialUrlLoadBalancer<FogUrl>
        let fogView: FogViewConnection
        let useValidUrls: Bool

        init(with transportProtocol: TransportProtocol, useValidUrls: Bool) throws {
            self.useValidUrls = useValidUrls

            self.seqLoadBalancer = try {
                useValidUrls
                ? try UrlLoadBalancerFixtures().validUrlsFogUrlBalancer
                : try UrlLoadBalancerFixtures().initialInvalidUrlFogUrlBalancer
            }()

            self.fogView = try IntegrationTestFixtures.createFogViewConnection(
                for: transportProtocol,
                using: seqLoadBalancer)
        }

        var loadBalancer: MockUrlLoadBalancer {
            seqLoadBalancer
        }

        func callService(expect: XCTestExpectation) throws {
            fogView.query(requestAad: FogView_QueryRequestAAD(), request: FogView_QueryRequest()) {
                if useValidUrls {
                    guard nil != $0.successOrFulfill(expectation: expect) else { return }
                    expect.fulfill()
                } else {
                    guard let error = $0.failureOrFulfill(expectation: expect) else { return }

                    switch error {
                    case .connectionFailure:
                        break
                    default:
                        XCTFail("error of type \(type(of: error)), \(error)")
                    }
                    expect.fulfill()
                }
            }
        }
    }

}

extension UrlLoadBalancerFixtures {
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
