//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable multiline_parameters_brackets

import Foundation
import LibMobileCoin
import GRPC

//final class HttpClientWrapper: AttestableHttpClient {
//    
//    private let httpRequester: HttpRequester?
//    private let headers: [String: String]
//    private let config: ConnectionConfigProtocol
//    private let httpMethod = HTTPMethod.POST
//    var authCallable: AuthHttpCallable {
//        get {
//            TestAuthCallable()
//        }
//    }
//    
//    required init(config: ConnectionConfigProtocol, httpRequester: HttpRequester?) {
//        self.httpRequester = httpRequester
//        self.config = config
//        self.headers = [:]
//    }
//    
//    func request(
//        body: Data?,
//        completion: @escaping (Result<Data?, Error>) -> Void) {
//        if let requester = httpRequester {
//            requester.request(
//                url: config.url.url,
//                method: httpMethod,
//                headers: headers,
//                body: body) { httpResponse in
//                switch httpResponse {
//                case .success(let response):
//                    return completion(.success(response.responseData))
//                case .failure(let error):
//                    return completion(.failure(error))
//                }
//            }
//        } else {
//            return completion(
//                .failure(InvalidInputError("HttpRequester was not set in the Network config")))
//        }
//    }
//}

//public struct TestAuthCallable : AuthHttpCallable {
//    func auth(_ request: Attest_AuthMessage, callOptions: HTTPCallOptions?, completion: @escaping (HttpCallResult<Attest_AuthMessage>) -> Void) {
//        print("Implement")
//    }
//}
