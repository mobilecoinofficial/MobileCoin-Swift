////
////  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
////
//
//import LibMobileCoin
//@testable import MobileCoin
//import XCTest
//
//class UrlLoadBalancerInvalidUrlIntTests: XCTestCase {
//
//    func testBlockchainRotatesAwayFromBadUrl() throws {
//        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
//            try testBlockchainRotatesAwayFromBadUrl(using: transportProtocol)
//        }
//    }
//
//    func testConsensusRotatesAwayFromBadUrl() throws {
//        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
//            try testConsensusRotatesAwayFromBadUrl(using: transportProtocol)
//        }
//    }
//
//    func testFogBlockRotatesAwayFromBadUrl() throws {
//        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
//            try testFogBlockRotatesAwayFromBadUrl(using: transportProtocol)
//        }
//    }
//
//    func testFogKeyImageRotatesAwayFromBadUrl() throws {
//        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
//            try testFogKeyImageRotatesAwayFromBadUrl(using: transportProtocol)
//        }
//    }
//
//    func testFogMerkleProofRotatesAwayFromBadUrl() throws {
//        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
//            try testFogMerkleProofRotatesAwayFromBadUrl(using: transportProtocol)
//        }
//    }
//
//    func testFogUntrustedTxOutRotatesAwayFromBadUrl() throws {
//        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
//            try testFogUntrustedTxOutRotatesAwayFromBadUrl(using: transportProtocol)
//        }
//    }
//
//    func testFogViewRotatesAwayFromBadUrl() throws {
//        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
//            try testFogViewRotatesAwayFromBadUrl(using: transportProtocol)
//        }
//    }
//
//    func testBlockchainRotatesAwayFromBadUrl(using transportProtocol: TransportProtocol) throws {
//        print("\n-----\nTesting Blockchain url rotation away from invalid URL using: " +
//              "\(transportProtocol.description)")
//
//        let consensusUrlLoadBalancer =
//            try UrlLoadBalancerFixtures().initialInvalidConsensusUrlBalancer
//
//        let blockchain = try IntegrationTestFixtures.createBlockchainConnection(
//            for: transportProtocol,
//            using: consensusUrlLoadBalancer)
//
//        XCTAssertEqual(
//            0,
//            consensusUrlLoadBalancer.curIdx,
//            "Consensus URL load balancer should not have rotated away from index 0")
//
//        let expectFailure = expectation(
//            description: "Blockchain request with invalid URL should fail")
//
//        blockchain.getLastBlockInfo {
//            guard let error = $0.failureOrFulfill(expectation: expectFailure) else { return }
//
//            switch error {
//            case .connectionFailure:
//                break
//            default:
//                XCTFail("error of type \(type(of: error)), \(error)")
//            }
//            expectFailure.fulfill()
//        }
//        waitForExpectations(timeout: transportProtocol.timeoutInSeconds)
//
//        XCTAssertEqual(
//            1,
//            consensusUrlLoadBalancer.curIdx,
//            "Consensus URL load balancer should have rotated from index 0 to 1")
//    }
//
//    func testConsensusRotatesAwayFromBadUrl(using transportProtocol: TransportProtocol) throws {
//        print("\n-----\nTesting Consensus url rotation away from invalid for protocol: " +
//              "\(transportProtocol.description)")
//
//        let consensusUrlLoadBalancer =
//            try UrlLoadBalancerFixtures().initialInvalidConsensusUrlBalancer
//
//        let consensus = try IntegrationTestFixtures.createConsensusConnection(
//            for: transportProtocol,
//            using: consensusUrlLoadBalancer)
//
//        XCTAssertEqual(
//            0,
//            consensusUrlLoadBalancer.curIdx,
//            "Consensus URL load balancer should not have rotated and should be at index 0")
//
//        let fixture = try Transaction.Fixtures.Default()
//
//        let expectFailure = expectation(description: "Making Consensus request against invalid URL")
//        consensus.proposeTx(fixture.tx) {
//            guard let error = $0.failureOrFulfill(expectation: expectFailure) else { return }
//
//            switch error {
//            case .connectionFailure:
//                break
//            default:
//                XCTFail("error of type \(type(of: error)), \(error)")
//            }
//            expectFailure.fulfill()
//        }
//        waitForExpectations(timeout: transportProtocol.timeoutInSeconds)
//
//        // verify that rotate has been called by checking curIdx of the loadBalancer
//        XCTAssertEqual(
//            1,
//            consensusUrlLoadBalancer.curIdx,
//            "Consensus URL load balancer should have rotated from index 0 to 1")
//    }
//
//    func testFogBlockRotatesAwayFromBadUrl(using transportProtocol: TransportProtocol) throws {
//        print("\n-----\nTesting FogBlock url rotation away from invalid for protocol: " +
//              "\(transportProtocol.description)")
//
//        let fogUrlLoadBalancer = try UrlLoadBalancerFixtures().initialInvalidUrlFogUrlBalancer
//        let fogBlock = try IntegrationTestFixtures.createFogBlockConnection(
//            for: transportProtocol,
//            using: fogUrlLoadBalancer)
//
//        XCTAssertEqual(
//            0,
//            fogUrlLoadBalancer.curIdx,
//            "Fog URL load balancer should not have rotated and should be at index 0")
//
//        let expectFailure = expectation(description: "Making FogBlock request against invalid URL")
//        fogBlock.getBlocks(
//            request: FogLedger_BlockRequest()
//        ) {
//            guard let error = $0.failureOrFulfill(expectation: expectFailure) else { return }
//
//            switch error {
//            case .connectionFailure:
//                break
//            default:
//                XCTFail("error of type \(type(of: error)), \(error)")
//            }
//            expectFailure.fulfill()
//        }
//        waitForExpectations(timeout: transportProtocol.timeoutInSeconds)
//
//        XCTAssertEqual(
//            1,
//            fogUrlLoadBalancer.curIdx,
//            "Fog URL load balancer should have rotated from index 0 to 1")
//    }
//
//    func testFogKeyImageRotatesAwayFromBadUrl(using transportProtocol: TransportProtocol) throws {
//        print("\n-----\nTesting FogKeyImage url rotation away from invalid for protocol: " +
//              "\(transportProtocol.description)")
//
//        let fogUrlLoadBalancer = try UrlLoadBalancerFixtures().initialInvalidUrlFogUrlBalancer
//        let fogKeyImage = try IntegrationTestFixtures.createFogKeyImageConnection(
//            for: transportProtocol,
//            using: fogUrlLoadBalancer)
//
//        XCTAssertEqual(
//            0,
//            fogUrlLoadBalancer.curIdx,
//            "Fog URL load balancer should not have rotated and should be at index 0")
//
//        let expectFailure = expectation(
//            description: "Making FogKeyImage request against invalid URL")
//        fogKeyImage.checkKeyImages(
//            request: FogLedger_CheckKeyImagesRequest()
//        ) {
//            guard let error = $0.failureOrFulfill(expectation: expectFailure) else { return }
//
//            switch error {
//            case .connectionFailure:
//                break
//            default:
//                XCTFail("error of type \(type(of: error)), \(error)")
//            }
//            expectFailure.fulfill()
//        }
//        waitForExpectations(timeout: transportProtocol.timeoutInSeconds)
//
//        XCTAssertEqual(
//            1,
//            fogUrlLoadBalancer.curIdx,
//            "Fog URL load balancer should have rotated from index 0 to 1")
//    }
//
//    func testFogMerkleProofRotatesAwayFromBadUrl(using transportProtocol: TransportProtocol)
//    throws {
//        print("\n-----\nTesting FogMerkleProof url rotation away from invalid for protocol: " +
//              "\(transportProtocol.description)")
//
//        let fogUrlLoadBalancer = try UrlLoadBalancerFixtures().initialInvalidUrlFogUrlBalancer
//        let fogMerkleProof = try IntegrationTestFixtures.createFogMerkleProofConnection(
//            for: transportProtocol,
//            using: fogUrlLoadBalancer)
//
//        XCTAssertEqual(
//            0,
//            fogUrlLoadBalancer.curIdx,
//            "Fog URL load balancer should not have rotated and should be at index 0")
//
//        let expectFailure = expectation(
//            description: "Making FogMerkleProof request against invalid URL")
//        fogMerkleProof.getOutputs(
//            request: FogLedger_GetOutputsRequest()
//        ) {
//            guard let error = $0.failureOrFulfill(expectation: expectFailure) else { return }
//
//            switch error {
//            case .connectionFailure:
//                break
//            default:
//                XCTFail("error of type \(type(of: error)), \(error)")
//            }
//            expectFailure.fulfill()
//        }
//        waitForExpectations(timeout: transportProtocol.timeoutInSeconds)
//
//        XCTAssertEqual(
//            1,
//            fogUrlLoadBalancer.curIdx,
//            "Fog URL load balancer should have rotated from index 0 to 1")
//    }
//
//    func testFogUntrustedTxOutRotatesAwayFromBadUrl(using transportProtocol: TransportProtocol)
//    throws {
//        print("\n-----\nTesting FogUntrustedTxOut url rotation away from invalid for protocol: " +
//              "\(transportProtocol.description)")
//
//        let fogUrlLoadBalancer = try UrlLoadBalancerFixtures().initialInvalidUrlFogUrlBalancer
//        let fogUntrustedTxOut =
//            try IntegrationTestFixtures.createFogUntrustedTxOutConnection(
//                for: transportProtocol,
//                using: fogUrlLoadBalancer)
//
//        XCTAssertEqual(
//            0,
//            fogUrlLoadBalancer.curIdx,
//            "Fog URL load balancer should not have rotated and should be at index 0")
//
//        let expectFailure1 = expectation(
//            description: "Making FogUntrustedTxOut request against invalid URL")
//        fogUntrustedTxOut.getTxOuts(request: FogLedger_TxOutRequest() ) {
//            guard let error = $0.failureOrFulfill(expectation: expectFailure1) else { return }
//
//            switch error {
//            case .connectionFailure:
//                break
//            default:
//                XCTFail("error of type \(type(of: error)), \(error)")
//            }
//            expectFailure1.fulfill()
//        }
//        waitForExpectations(timeout: transportProtocol.timeoutInSeconds)
//
//        XCTAssertEqual(
//            1,
//            fogUrlLoadBalancer.curIdx,
//            "Fog URL load balancer should have rotated from index 0 to 1")
//    }
//
//    func testFogViewRotatesAwayFromBadUrl(using transportProtocol: TransportProtocol) throws {
//        print("\n-----\nTesting FogView url rotation away from invalid using: " +
//              "\(transportProtocol.description)")
//
//        let fogUrlLoadBalancer = try UrlLoadBalancerFixtures().initialInvalidUrlFogUrlBalancer
//        let fogView = try IntegrationTestFixtures.createFogViewConnection(
//            for: transportProtocol,
//            using: fogUrlLoadBalancer)
//
//        XCTAssertEqual(
//            0,
//            fogUrlLoadBalancer.curIdx,
//            "Fog URL load balancer should not have rotated and should be at index 0")
//
//        let expectFailure = expectation(
//            description: "Making FogView request against invalid URL")
//        fogView.query(
//            requestAad: FogView_QueryRequestAAD(),
//            request: FogView_QueryRequest()
//        ) {
//            guard let error = $0.failureOrFulfill(expectation: expectFailure) else { return }
//
//            switch error {
//            case .connectionFailure:
//                break
//            default:
//                XCTFail("error of type \(type(of: error)), \(error)")
//            }
//            expectFailure.fulfill()
//        }
//        waitForExpectations(timeout: transportProtocol.timeoutInSeconds)
//
//        XCTAssertEqual(
//            1,
//            fogUrlLoadBalancer.curIdx,
//            "Fog URL load balancer should have rotated from index 0 to 1")
//    }
//}
