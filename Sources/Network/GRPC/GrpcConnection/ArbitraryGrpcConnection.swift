//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import NIO

class ArbitraryGrpcConnection {
    private let inner: SerialDispatchLock<Inner>

    init(url: MobileCoinUrlProtocol, targetQueue: DispatchQueue?) {
        let inner = Inner(url: url)
        self.inner = .init(inner, targetQueue: targetQueue)
    }

    func performCall<Call: GrpcCallable>(
        _ call: Call,
        request: Call.Request,
        completion: @escaping (Result<Call.Response, ConnectionError>) -> Void
    ) {
        func performCallCallback(callResult: Result<UnaryCallResult<Call.Response>, Error>) {
            inner.accessAsync {
                let result = $0.processResponse(callResult: callResult)
                switch result {
                case .success:
                    logger.info("Call complete. url: \($0.url)", logFunction: false)
                case .failure(let connectionError):
                    let errorMessage =
                        "Connection failure. url: \($0.url), error: \(connectionError)"
                    switch connectionError {
                    case .connectionFailure, .serverRateLimited:
                        logger.warning(errorMessage, logFunction: false)
                    case .authorizationFailure, .invalidServerResponse,
                         .attestationVerificationFailed, .outdatedClient:
                        logger.error(errorMessage, logFunction: false)
                    }
                }
                completion(result)
            }
        }
        inner.accessAsync {
            logger.info("Performing call... url: \($0.url)", logFunction: false)

            let callOptions = $0.requestCallOptions()
            call.call(request: request, callOptions: callOptions, completion: performCallCallback)
        }
    }
}

extension ArbitraryGrpcConnection {
    private struct Inner {
        let url: MobileCoinUrlProtocol
        private let session: ConnectionSession

        init(url: MobileCoinUrlProtocol) {
            self.url = url
            self.session = ConnectionSession(url: url)
        }

        func requestCallOptions() -> CallOptions {
            var callOptions = CallOptions()
            session.addRequestHeaders(to: &callOptions.customMetadata)
            callOptions.timeLimit = TimeLimit.timeout(TimeAmount.seconds(30))
            return callOptions
        }

        func processResponse<Response>(callResult: Result<UnaryCallResult<Response>, Error>)
            -> Result<Response, ConnectionError>
        {
            switch callResult {
            case .failure(let error):
                return .failure(.connectionFailure(error.localizedDescription))
            case .success(let callResponse):
                guard callResponse.status.isOk, let response = callResponse.response else {
                    return .failure(.connectionFailure(String(describing: callResponse.status)))
                }

                if let initialMetadata = callResponse.initialMetadata {
                    session.processResponse(headers: initialMetadata)
                }

                return .success(response)
            }
        }
    }
}
