//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin
#if canImport(LibMobileCoinGRPC)
import LibMobileCoinGRPC
#endif

final class FogReportGrpcConnection: ArbitraryGrpcConnection, FogReportService {
    private let client: Report_ReportAPIClient

    init(url: FogUrl, channelManager: GrpcChannelManager, targetQueue: DispatchQueue?) {
        let channel = channelManager.channel(for: url)
        self.client = Report_ReportAPIClient(channel: channel)
        super.init(url: url, targetQueue: targetQueue)
    }

    func getReports(
        request: Report_ReportRequest,
        completion: @escaping (Result<Report_ReportResponse, ConnectionError>) -> Void
    ) {
        performCall(GetReportsCall(client: client), request: request, completion: completion)
    }
}

extension FogReportGrpcConnection {
    private struct GetReportsCall: GrpcCallable {
        let client: Report_ReportAPIClient

        func call(
            request: Report_ReportRequest,
            callOptions: CallOptions?,
            completion: @escaping (Result<UnaryCallResult<Report_ReportResponse>, Error>) -> Void
        ) {
            let unaryCall = client.getReports(request, callOptions: callOptions)
            unaryCall.callResult.whenComplete(completion)
        }
    }
}
