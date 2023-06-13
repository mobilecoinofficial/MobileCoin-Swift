//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif
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

        let request = Report_ReportRequest()
        try createFogReportConnection(using: transportProtocol).getReports(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertGreaterThan(response.reports.count, 0)
            for report in response.reports {
                print("pubkey_expiry: \(report.pubkeyExpiry)")
                XCTAssertGreaterThan(report.pubkeyExpiry, 0)
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 40)
    }

    func testGetReportsShortURL() throws {
        let unless = IntegrationTestFixtures.network.fogShortURLSupported
        try XCTSkipUnless(unless, "Fog ShortURL not supported on this NetworkPreset")
        try TransportProtocol.supportedProtocols.forEach { transportProtocol in
            try getReportsShortURL(transportProtocol: transportProtocol)
        }
    }

    func getReportsShortURL(transportProtocol: TransportProtocol) throws {
        let expect = expectation(description: "Fog GetReports request")

        let request = Report_ReportRequest()
        try createShortURLFogReportConnection(
            using: transportProtocol
        ).getReports(request: request) {
            guard let response = $0.successOrFulfill(expectation: expect) else { return }

            XCTAssertGreaterThan(response.reports.count, 0)
            for report in response.reports {
                print("pubkey_expiry: \(report.pubkeyExpiry)")
                XCTAssertGreaterThan(report.pubkeyExpiry, 0)
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 40)
    }

}

extension FogReportConnectionIntTests {
    func createShortURLFogReportConnection(
        using transportProtocol: TransportProtocol
    ) throws -> FogReportConnection {
        let url = try FogUrl.make(string: IntegrationTestFixtures.network.fogReportShortUrl).get()
        let httpFactory = HttpProtocolConnectionFactory(httpRequester: DefaultHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return FogReportConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            url: url,
            transportProtocolOption: transportProtocol.option,
            targetQueue: DispatchQueue.main)
    }

    func createFogReportConnection(
        using transportProtocol: TransportProtocol
    ) throws -> FogReportConnection {
        let url = try FogUrl.make(string: IntegrationTestFixtures.network.fogReportUrl).get()
        let httpFactory = HttpProtocolConnectionFactory(httpRequester: DefaultHttpRequester())
        let grpcFactory = GrpcProtocolConnectionFactory()
        return FogReportConnection(
            httpFactory: httpFactory,
            grpcFactory: grpcFactory,
            url: url,
            transportProtocolOption: transportProtocol.option,
            targetQueue: DispatchQueue.main)
    }
}
