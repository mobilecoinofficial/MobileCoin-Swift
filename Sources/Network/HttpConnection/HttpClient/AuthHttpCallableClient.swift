//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import LibMobileCoin

protocol AuthHttpCallableClient: AttestableHttpClient, AuthHttpCallable {
    func auth(_ request: Attest_AuthMessage, callOptions: CallOptions?)
        -> UnaryCall<Attest_AuthMessage, Attest_AuthMessage>
}

extension AuthHttpCallableClient {
    var authCallable: AuthHttpCallable {
        self
    }
}

extension AuthHttpCallableClient {
    func auth(
        _ request: Attest_AuthMessage,
        callOptions: CallOptions?,
        completion: @escaping (UnaryCallResult<Attest_AuthMessage>) -> Void
    ) {
        auth(request, callOptions: callOptions).callResult.whenSuccess(completion)
    }
}
