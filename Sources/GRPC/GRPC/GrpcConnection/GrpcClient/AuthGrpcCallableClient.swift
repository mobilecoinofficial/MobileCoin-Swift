//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin
#if canImport(LibMobileCoinGRPC)
import LibMobileCoinCommon
import LibMobileCoinGRPC
#endif

protocol AuthGrpcCallableClient: AttestableGrpcClient, AuthGrpcCallable {
    func auth(_ request: Attest_AuthMessage, callOptions: CallOptions?)
        -> UnaryCall<Attest_AuthMessage, Attest_AuthMessage>
}

extension AuthGrpcCallableClient {
    var authCallable: AuthGrpcCallable {
        self
    }
}

extension AuthGrpcCallableClient {
    func auth(
        _ request: Attest_AuthMessage,
        callOptions: CallOptions?,
        completion: @escaping (Result<UnaryCallResult<Attest_AuthMessage>, Error>) -> Void
    ) {
        auth(request, callOptions: callOptions).callResult.whenComplete(completion)
    }
}
