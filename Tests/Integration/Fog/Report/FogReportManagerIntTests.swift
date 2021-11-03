//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

@testable import MobileCoin
import XCTest

class FogReportManagerIntTests: XCTestCase {
    func testFogReportGRPC() throws {
        try fogReport(transportProtocol: TransportProtocol.grpc)
    }
    
    func testFogReportHTTP() throws {
        try fogReport(transportProtocol: TransportProtocol.http)
    }
    
    func fogReport(transportProtocol: TransportProtocol) throws {
        let fogReportManager = try IntegrationTestFixtures.createFogReportManager(transportProtocol: transportProtocol)
        let reportUrl = try IntegrationTestFixtures.fogReportUrlTyped()

        let expect = expectation(description: "Retrieve fog reports")
        fogReportManager.reportResponse(for: reportUrl) {
            guard let reportResponse = $0.successOrFulfill(expectation: expect) else { return }

            print(reportResponse)
            XCTAssertNoThrow(evaluating: {
                let report = try XCTUnwrap(reportResponse.reports.first)
                let serializedVerificationReport = try report.report.serializedData()
                print("report: \(serializedVerificationReport.base64EncodedString())")
            })

            XCTAssertFalse(reportResponse.reports.isEmpty)
            for report in reportResponse.reports {
                print("received report for fog url: \(reportUrl) with expiry: " +
                    "\(report.pubkeyExpiry)")
                XCTAssertGreaterThan(report.pubkeyExpiry, 0)
            }

            expect.fulfill()
        }
        waitForExpectations(timeout: 10)
    }
}
