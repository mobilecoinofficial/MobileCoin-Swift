//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin

protocol AuthHttpCallable {
    func auth(
        _ request: Attest_AuthMessage,
        callOptions: HTTPCallOptions?,
        completion: @escaping (HttpCallResult<Attest_AuthMessage>) -> Void)
}

struct AuthHttpCallableWrapper: HttpCallable {
    typealias Request = Attest_AuthMessage
    typealias Response = Attest_AuthMessage
    
    let authCallable: AuthHttpCallable

    func call(
        request: Attest_AuthMessage,
        callOptions: HTTPCallOptions?,
        completion: @escaping (HttpCallResult<Attest_AuthMessage>) -> Void
    ) {
        authCallable.auth(request, callOptions: callOptions, completion: completion)
    }
}
