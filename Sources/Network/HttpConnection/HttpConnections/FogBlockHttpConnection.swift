//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin


//final class FogBlockHttpConnection: ConnectionProtocol, FogBlockService {
//    func getBlocks(
//        request: FogLedger_BlockRequest,
//        completion: @escaping (Result<FogLedger_BlockResponse, ConnectionError>) -> Void
//    ) {
//    }
//
//    func setAuthorization(credentials: BasicCredentials) {
//
//    }
//}

final class FogBlockHttpConnection: HttpConnection, FogBlockService {
    private let client: FogLedger_FogBlockAPIRestClient
    private let requester: HTTPRequester

    init(
        config: ConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) {
        self.client = FogLedger_FogBlockAPIRestClient()
        self.requester = HTTPRequester(baseUrl: config.url.httpBasedUrl, trustRoots: config.trustRoots)
        super.init(config: config, targetQueue: targetQueue)
    }

    func getBlocks(
        request: FogLedger_BlockRequest,
        completion: @escaping (Result<FogLedger_BlockResponse, ConnectionError>) -> Void
    ) {
        performCall(GetBlocksCall(client: client, requester: requester), request: request, completion: completion)
    }
}

extension FogBlockHttpConnection {
    private struct GetBlocksCall: HttpCallable {
        let client: FogLedger_FogBlockAPIRestClient
        let requester: HTTPRequester

        func call(
            request: FogLedger_BlockRequest,
            callOptions: HTTPCallOptions?,
            completion: @escaping (HttpCallResult<FogLedger_BlockResponse>) -> Void
        ) {
            let unaryCall = client.getBlocks(request, callOptions: callOptions)
            unaryCall.callResult.whenSuccess(completion)
        }
    }
}
