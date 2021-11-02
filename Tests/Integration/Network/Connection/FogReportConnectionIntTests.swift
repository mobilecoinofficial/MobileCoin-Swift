//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class FogReportConnectionIntTests: XCTestCase {

    func testGetReportsGRPC() throws {
        try getReports(transportProtocol: TransportProtocol.grpc)
    }
    
    func testGetReportsHTTP() throws {
        try getReports(transportProtocol: TransportProtocol.http)
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

}

extension FogReportConnectionIntTests {
    func createFogReportConnection(transportProtocol: TransportProtocol) throws -> FogReportConnection {
        let url = try FogUrl.make(string: IntegrationTestFixtures.network.fogReportUrl).get()
        return FogReportConnection(
            url: url,
            transportProtocolOption: transportProtocol.option,
            channelManager: GrpcChannelManager(),
            httpRequester: TestHttpRequester(),
            targetQueue: DispatchQueue.main)
    }
}
