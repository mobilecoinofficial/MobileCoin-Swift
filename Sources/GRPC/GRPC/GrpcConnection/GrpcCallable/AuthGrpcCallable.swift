//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_parameters_brackets

import Foundation
import GRPC
import LibMobileCoin
#if canImport(LibMobileCoinGRPC)
import LibMobileCoinGRPC
import LibMobileCoinCommon
#endif

protocol AuthGrpcCallable {
    func auth(
        _ request: Attest_AuthMessage,
        callOptions: CallOptions?,
        completion: @escaping (Result<UnaryCallResult<Attest_AuthMessage>, Error>) -> Void)
}

struct AuthGrpcCallableWrapper: GrpcCallable {
    let authCallable: AuthGrpcCallable

    func call(
        request: Attest_AuthMessage,
        callOptions: CallOptions?,
        completion: @escaping (Result<UnaryCallResult<Attest_AuthMessage>, Error>) -> Void
    ) {
        authCallable.auth(request, callOptions: callOptions, completion: completion)
    }
}
