//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class FogReportConnectionIntTests: XCTestCase {

    func testGetReports() throws {
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try getReports(transportProtocol: transportProtocol)
        }
    }
    
    func getReports(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog GetReports request")

        try createFogReportConnection(transportProtocol:transportProtocol).getReports(request: Report_ReportRequest()) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertGreaterThan(response.reports.count, 0)
            for report in response.reports {
                print("pubkey_expiry: \(report.pubkeyExpiry)")
                XCTAssertGreaterThan(report.pubkeyExpiry, 0)
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }
    
    func testGetReportsShortURL() throws {
        try XCTSkipUnless(IntegrationTestFixtures.network.fogShortURLSupported, "Fog ShortURL not supported on this NetworkPreset")
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try getReportsShortURL(transportProtocol: transportProtocol)
        }
    }
    
    func getReportsShortURL(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog GetReports request")

        try createShortURLFogReportConnection(transportProtocol:transportProtocol).getReports(request: Report_ReportRequest()) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertGreaterThan(response.reports.count, 0)
            for report in response.reports {
                print("pubkey_expiry: \(report.pubkeyExpiry)")
                XCTAssertGreaterThan(report.pubkeyExpiry, 0)
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 20)
    }

}

extension FogReportConnectionIntTests {
    func createShortURLFogReportConnection(transportProtocol: TransportProtocol) throws -> FogReportConnection {
        let url = try FogUrl.make(string: IntegrationTestFixtures.network.fogReportShortUrl).get()
        let httpFactory = HttpProtocolConnectionFactory(httpRequester: TestHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return FogReportConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            url: url,
            transportProtocolOption: transportProtocol.option,
            targetQueue: DispatchQueue.main)
    }

    func createFogReportConnection(transportProtocol: TransportProtocol) throws -> FogReportConnection {
        let url = try FogUrl.make(string: IntegrationTestFixtures.network.fogReportUrl).get()
        let httpFactory = HttpProtocolConnectionFactory(httpRequester: TestHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return FogReportConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            url: url,
            transportProtocolOption: transportProtocol.option,
            targetQueue: DispatchQueue.main)
    }
}
