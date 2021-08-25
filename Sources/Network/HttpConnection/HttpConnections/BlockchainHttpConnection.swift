//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin
import SwiftProtobuf

final class BlockchainHttpConnection: HttpConnection, BlockchainService {
    private let client: ConsensusCommon_BlockchainAPIRestClient
    private let requester: HTTPRequester

    init(
        config: ConnectionConfig<ConsensusUrl>,
        targetQueue: DispatchQueue?
    ) {
        self.client = ConsensusCommon_BlockchainAPIRestClient()
        self.requester = HTTPRequester(baseUrl: config.url.httpBasedUrl, trustRoots: config.trustRoots)
        super.init(config: config, targetQueue: targetQueue)
    }

    func getLastBlockInfo(
        completion:
            @escaping (Result<ConsensusCommon_LastBlockInfoResponse, ConnectionError>) -> Void
    ) {
        performCall(GetLastBlockInfoCall(client: client, requester: requester), completion: completion)
    }
}

extension BlockchainHttpConnection {
    private struct GetLastBlockInfoCall: HttpCallable {
        let client: ConsensusCommon_BlockchainAPIRestClient
        let requester: HTTPRequester

        func call(
            request: (),
            callOptions: HTTPCallOptions?,
            completion: @escaping (HttpCallResult<ConsensusCommon_LastBlockInfoResponse>) -> Void
        ) {
            let clientCall = client.getLastBlockInfo(Google_Protobuf_Empty())
            requester.makeRequest(call: clientCall) { result in
                switch result {
                case .success(let callResult):
                    completion(callResult)
                case .failure(let error):
                    logger.error(error.localizedDescription)
                }
            }
//            let unaryCall =
//                client.getLastBlockInfo(Google_Protobuf_Empty(), callOptions: callOptions)
//            unaryCall.callResult.whenSuccess(completion)
        }
    }
}
