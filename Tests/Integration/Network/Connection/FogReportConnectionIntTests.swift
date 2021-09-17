//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import LibMobileCoin
@testable import MobileCoin
import XCTest

class FogReportConnectionIntTests: XCTestCase {

    func testGetReports() throws {
        let expect = expectation(description: "Fog GetReports request")

        try createFogReportConnection().getReports(request: Report_ReportRequest()) {
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
    func createFogReportConnection() throws -> FogReportConnection {
        let url = try FogUrl.make(string: IntegrationTestFixtures.network.fogReportUrl).get()
        return FogReportConnection(
            url: url,
            transportProtocolOption: try IntegrationTestFixtures.network.networkConfig().transportProtocol.option,
            channelManager: GrpcChannelManager(),
            httpRequester: TestHttpRequester(),
            targetQueue: DispatchQueue.main)
    }
}
