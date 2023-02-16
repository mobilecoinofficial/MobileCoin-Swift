//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//
import LibMobileCoin
@testable import MobileCoin
import XCTest

// chose to avoid the extension on the Generic UrlLoadBalancer<> as the
// use of the fixture would be obtrusive
struct UrlLoadBalancerFixtures {
    let invalidFogUrlBalancer: SequentialUrlLoadBalancer<FogUrl>
    let invalidConsensusUrlBalancer: SequentialUrlLoadBalancer<ConsensusUrl>

    init() throws {
        invalidFogUrlBalancer = try Self.createInvalidFogUrlLoadBalancer()
        invalidConsensusUrlBalancer = try Self.createInvalidConsensusUrlLoadBalancer()
    }
}

protocol ServiceFixture {
    var serviceName: String { get }
    var urlTypeName: String { get }
    var loadBalancer: MockUrlLoadBalancer { get }

    func callService(expect: XCTestExpectation) throws
}

extension UrlLoadBalancerFixtures {

    struct Blockchain: ServiceFixture {
        let serviceName = "Blockchain"
        let urlTypeName = "Consensus"
        let seqLoadBalancer: SequentialUrlLoadBalancer<ConsensusUrl>
        let blockchain: BlockchainConnection

        var loadBalancer: MockUrlLoadBalancer {
            seqLoadBalancer
        }

        init() throws {
            self.seqLoadBalancer = try UrlLoadBalancerFixtures().invalidConsensusUrlBalancer
            self.blockchain = try UnitTestFixtures.createBlockchainConnection(
                using: seqLoadBalancer)
        }

        func callService(expect: XCTestExpectation) throws {
            blockchain.getLastBlockInfo {
                guard let error = $0.failureOrFulfill(expectation: expect) else { return }

                switch error {
                case .connectionFailure:
                    break
                default:
                    XCTFail("error of type \(type(of: error)), \(error)")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { expect.fulfill() }
            }
        }
    }

    struct Consensus: ServiceFixture {
        let serviceName = "Consensus"
        let urlTypeName = "Consensus"
        let seqLoadBalancer: SequentialUrlLoadBalancer<ConsensusUrl>
        let consensus: ConsensusConnection

        init() throws {
            self.seqLoadBalancer = try UrlLoadBalancerFixtures().invalidConsensusUrlBalancer
            self.consensus = try UnitTestFixtures.createConsensusConnection(
                using: seqLoadBalancer)
        }

        var loadBalancer: MockUrlLoadBalancer {
            seqLoadBalancer
        }

        func callService(expect: XCTestExpectation) throws {
            consensus.proposeTx(try Transaction.Fixtures.Default().tx) {
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

    struct FogBlock: ServiceFixture {
        let serviceName = "FogBlock"
        let urlTypeName = "Fog"
        let seqLoadBalancer: SequentialUrlLoadBalancer<FogUrl>
        let fogBlock: FogBlockConnection

        init() throws {
            self.seqLoadBalancer = try UrlLoadBalancerFixtures().invalidFogUrlBalancer
            self.fogBlock = try UnitTestFixtures.createFogBlockConnection(
                using: seqLoadBalancer)
        }

        var loadBalancer: MockUrlLoadBalancer {
            seqLoadBalancer
        }

        func callService(expect: XCTestExpectation) throws {
            fogBlock.getBlocks(request: FogLedger_BlockRequest()) {
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

    struct FogKeyImage: ServiceFixture {
        let serviceName = "FogKeyImage"
        let urlTypeName = "Fog"
        let seqLoadBalancer: SequentialUrlLoadBalancer<FogUrl>
        let fogKeyImage: FogKeyImageConnection

        init() throws {
            self.seqLoadBalancer = try UrlLoadBalancerFixtures().invalidFogUrlBalancer
            self.fogKeyImage = try UnitTestFixtures.createFogKeyImageConnection(
                using: seqLoadBalancer)
        }

        var loadBalancer: MockUrlLoadBalancer {
            seqLoadBalancer
        }

        func callService(expect: XCTestExpectation) throws {
            fogKeyImage.checkKeyImages(request: FogLedger_CheckKeyImagesRequest()) {
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

    struct FogMerkleProof: ServiceFixture {
        let serviceName = "FogMerkleProof"
        let urlTypeName = "Fog"
        let seqLoadBalancer: SequentialUrlLoadBalancer<FogUrl>
        let fogMerkleProof: FogMerkleProofConnection

        init() throws {
            self.seqLoadBalancer = try UrlLoadBalancerFixtures().invalidFogUrlBalancer
            self.fogMerkleProof = try UnitTestFixtures.createFogMerkleProofConnection(
                using: seqLoadBalancer)
        }

        var loadBalancer: MockUrlLoadBalancer {
            seqLoadBalancer
        }

        func callService(expect: XCTestExpectation) throws {
            fogMerkleProof.getOutputs(request: FogLedger_GetOutputsRequest()) {
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

    struct FogUntrustedTxOut: ServiceFixture {
        let serviceName = "FogUntrustedTxOut"
        let urlTypeName = "Fog"
        let seqLoadBalancer: SequentialUrlLoadBalancer<FogUrl>
        let fogUntrustedTxOut: FogUntrustedTxOutConnection

        init() throws {
            self.seqLoadBalancer = try UrlLoadBalancerFixtures().invalidFogUrlBalancer
            self.fogUntrustedTxOut = try UnitTestFixtures.createFogUntrustedTxOutConnection(
                using: seqLoadBalancer)
        }

        var loadBalancer: MockUrlLoadBalancer {
            seqLoadBalancer
        }

        func callService(expect: XCTestExpectation) throws {
            fogUntrustedTxOut.getTxOuts(request: FogLedger_TxOutRequest()) {
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

    struct FogView: ServiceFixture {
        let serviceName = "FogView"
        let urlTypeName = "Fog"
        let seqLoadBalancer: SequentialUrlLoadBalancer<FogUrl>
        let fogView: FogViewConnection

        init() throws {
            self.seqLoadBalancer = try UrlLoadBalancerFixtures().invalidFogUrlBalancer

            self.fogView = try UnitTestFixtures.createFogViewConnection(
                using: seqLoadBalancer)
        }

        var loadBalancer: MockUrlLoadBalancer {
            seqLoadBalancer
        }

        func callService(expect: XCTestExpectation) throws {
            fogView.query(requestAad: FogView_QueryRequestAAD(), request: FogView_QueryRequest()) {
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

extension UrlLoadBalancerFixtures {
    private static func createInvalidConsensusUrlLoadBalancer()
    throws -> SequentialUrlLoadBalancer<ConsensusUrl> {
        let urlStrings = [
            UnitTestFixtures.invalidConsensusUrl,
            UnitTestFixtures.invalidConsensusUrl,
        ]
        let consensusUrls = try ConsensusUrl.make(strings: urlStrings).get()
        return SequentialUrlLoadBalancer(urls: consensusUrls)
    }

    private static func createInvalidFogUrlLoadBalancer()
    throws -> SequentialUrlLoadBalancer<FogUrl> {
        let urlStrings = [
            UnitTestFixtures.invalidFogUrl,
            UnitTestFixtures.invalidFogUrl,
        ]
        let fogUrls = try FogUrl.make(strings: urlStrings).get()
        return SequentialUrlLoadBalancer(urls: fogUrls)
    }
}
