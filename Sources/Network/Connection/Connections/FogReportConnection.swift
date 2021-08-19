//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin

final class FogReportConnection:
    ArbitraryConnection<FogReportGrpcConnection, FogReportHttpConnection>, FogReportService
{
    private let url: FogUrl
    private let channelManager: GrpcChannelManager
    private let targetQueue: DispatchQueue?

    init(
        url: FogUrl,
        transportProtocolOption: TransportProtocol.Option,
        channelManager: GrpcChannelManager,
        targetQueue: DispatchQueue?
    ) {
        self.url = url
        self.channelManager = channelManager
        self.targetQueue = targetQueue

        super.init(
            connectionOptionWrapperFactory: { transportProtocolOption in
                switch transportProtocolOption {
                case .grpc:
                    return .grpc(
                        grpcService: FogReportGrpcConnection(
                            url: url,
                            channelManager: channelManager,
                            targetQueue: targetQueue))
                case .http:
                    return .http(httpService: FogReportHttpConnection())
                }
            },
            transportProtocolOption: transportProtocolOption,
            targetQueue: targetQueue)
    }

    func getReports(
        request: Report_ReportRequest,
        completion: @escaping (Result<Report_ReportResponse, ConnectionError>) -> Void
    ) {
    }
}
