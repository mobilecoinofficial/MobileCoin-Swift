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
    let invalidMistyswapUrlBalancer: SequentialUrlLoadBalancer<MistyswapUrl>

    init() throws {
        invalidFogUrlBalancer = try Self.createInvalidFogUrlLoadBalancer()
        invalidConsensusUrlBalancer = try Self.createInvalidConsensusUrlLoadBalancer()
        invalidMistyswapUrlBalancer = try Self.createInvalidMistyswapUrlLoadBalancer()
    }
}

protocol ServiceFixture {
    var serviceName: String { get }
    var urlTypeName: String { get }

    func callService(expect: XCTestExpectation) throws
}

extension UrlLoadBalancerFixtures {

    struct Blockchain: ServiceFixture {
        let serviceName = "Blockchain"
        let urlTypeName = "Consensus"
        let blockchain: BlockchainConnection

        init(_ blockchain: BlockchainConnection) throws {
            self.blockchain = blockchain
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
        let consensus: ConsensusConnection

        init(_ consensus: ConsensusConnection) throws {
            self.consensus = consensus
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
        let fogBlock: FogBlockConnection

        init(_ fogBlock: FogBlockConnection) throws {
            self.fogBlock = fogBlock
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
        let fogKeyImage: FogKeyImageConnection

        init(_ fogKeyImage: FogKeyImageConnection) throws {
            self.fogKeyImage = fogKeyImage
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
        let fogMerkleProof: FogMerkleProofConnection

        init(_ fogMerkleProof: FogMerkleProofConnection) throws {
            self.fogMerkleProof = fogMerkleProof
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
        let fogUntrustedTxOut: FogUntrustedTxOutConnection

        init(_ fogUntrustedTxOut: FogUntrustedTxOutConnection) throws {
            self.fogUntrustedTxOut = fogUntrustedTxOut
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
        let fogView: FogViewConnection

        init(_ fogView: FogViewConnection) throws {
            self.fogView = fogView
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
        let urls = try ConsensusUrl.make(strings: urlStrings).get()
        return SequentialUrlLoadBalancer(urls: urls)
    }

    private static func createInvalidFogUrlLoadBalancer()
    throws -> SequentialUrlLoadBalancer<FogUrl> {
        let urlStrings = [
            UnitTestFixtures.invalidFogUrl,
            UnitTestFixtures.invalidFogUrl,
        ]
        let urls = try FogUrl.make(strings: urlStrings).get()
        return SequentialUrlLoadBalancer(urls: urls)
    }
    
    private static func createInvalidMistyswapUrlLoadBalancer()
    throws -> SequentialUrlLoadBalancer<MistyswapUrl> {
        let urlStrings = [
            UnitTestFixtures.invalidMistyswapUrl,
            UnitTestFixtures.invalidMistyswapUrl,
        ]
        let urls = try MistyswapUrl.make(strings: urlStrings).get()
        return SequentialUrlLoadBalancer(urls: urls)
    }

}
