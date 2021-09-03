//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin


///// A HTTP client.
//public protocol HTTPClient {
//    /// The call options to use should the user not provide per-call options.
//    var defaultHTTPCallOptions: HTTPCallOptions { get set }
//}
//
//extension HTTPClient {
//    public func makeUnaryCall<Request, Response>(path: String, request: Request, callOptions: HTTPCallOptions? = nil, responseType: Response.Type = Response.self) -> HTTPUnaryCall<Request, Response> where Request : SwiftProtobuf.Message, Response : SwiftProtobuf.Message {
//        HTTPUnaryCall(path: path, options: callOptions, requestPayload: request, responseType: responseType)
//    }
//}

//protocol AuthHttpCallableClient: AttestableHttpClient, AuthHttpCallable {
//    func auth(_ request: Attest_AuthMessage, callOptions: HTTPCallOptions?)
//        -> HTTPUnaryCall<Attest_AuthMessage, Attest_AuthMessage>
//}
//
//extension AuthHttpCallableClient {
//    var authCallable: AuthHttpCallable {
//        self
//    }
//}
//
//extension AuthHttpCallableClient {
//    func auth(
//        _ request: Attest_AuthMessage,
//        callOptions: HTTPCallOptions?,
//        completion: @escaping (HttpCallResult<Attest_AuthMessage>) -> Void
//    ) {
//        let clientCall = auth(request, callOptions: callOptions)
//        requester.makeRequest(call: clientCall) { result in
//            switch result {
//            case .success(let callResult):
//                completion(callResult)
//            case .failure(let error):
//                logger.error(error.localizedDescription)
//            }
//        }
//    }
//}

protocol AuthQueryHttpCalleeAndClient : QueryHttpCallee, AuthHttpCallee, HTTPClient {}

struct AuthHttpCallableClientWrapper<WrappedClient:HTTPClient & AuthHttpCallee>: AuthHttpCallableClient, HTTPClient {
    public var defaultHTTPCallOptions: HTTPCallOptions {
        get {
            return client.defaultHTTPCallOptions
        }
        set {
            logger.warning("defaultHTTPOptions set not implemented")
        }
    }
    
    let client : WrappedClient
    let requester: RestApiRequester

    func auth(_ request: Attest_AuthMessage, callOptions: HTTPCallOptions?)
    -> HTTPUnaryCall<Attest_AuthMessage, Attest_AuthMessage> {
        client.auth(request, callOptions: callOptions)
    }
    
    func auth(
        _ request: Attest_AuthMessage,
        callOptions: HTTPCallOptions?,
        completion: @escaping (HttpCallResult<Attest_AuthMessage>) -> Void) {
        
        let clientCall = auth(request, callOptions: callOptions)
        requester.makeRequest(call: clientCall, completion: completion)
    }
}

extension AuthHttpCallableClientWrapper where WrappedClient : QueryHttpCallee {
    func query(
      _ request: Attest_Message,
      callOptions: HTTPCallOptions?
    ) -> HTTPUnaryCall<Attest_Message, Attest_Message> {
        client.query(request, callOptions: callOptions)
    }
}

extension AuthHttpCallableClientWrapper where WrappedClient : OutputsHttpCallee {
    func getOutputs(
      _ request: Attest_Message,
      callOptions: HTTPCallOptions?
    ) -> HTTPUnaryCall<Attest_Message, Attest_Message> {
        client.getOutputs(request, callOptions: callOptions)
    }
}

extension AuthHttpCallableClientWrapper where WrappedClient : CheckKeyImagesCallee {
    func checkKeyImages(
      _ request: Attest_Message,
      callOptions: HTTPCallOptions?
    ) -> HTTPUnaryCall<Attest_Message, Attest_Message> {
        client.checkKeyImages(request, callOptions: callOptions)
    }
}
