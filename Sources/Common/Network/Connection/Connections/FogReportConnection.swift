//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
#if canImport(LibMobileCoinCommon)
import LibMobileCoinCommon
#endif

final class FogReportConnection: ArbitraryConnection<
        HttpProtocolConnectionFactory.FogReportServiceProvider
    >,
    FogReportService
{
    private let httpFactory: HttpProtocolConnectionFactory
    private let url: FogUrl
    private let targetQueue: DispatchQueue?

    init(
        httpFactory: HttpProtocolConnectionFactory,
        url: FogUrl,
        transportProtocolOption: TransportProtocol.Option,
        targetQueue: DispatchQueue?
    ) {
        self.httpFactory = httpFactory
        self.url = url
        self.targetQueue = targetQueue

        super.init(
            serviceFactory: { transportProtocolOption in
                httpFactory.makeFogReportService(
                    url: url,
                    transportProtocolOption: transportProtocolOption,
                    targetQueue: targetQueue)
            },
            transportProtocolOption: transportProtocolOption,
            targetQueue: targetQueue)
    }

    func getReports(
        request: Report_ReportRequest,
        completion: @escaping (Result<Report_ReportResponse, ConnectionError>) -> Void
    ) {
        service.getReports(request: request, completion: completion)
    }
}
