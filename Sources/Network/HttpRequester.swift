//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable all

import Foundation
import SwiftProtobuf

public protocol HttpRequester {
    func request(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        completion: @escaping (Result<HTTPResponse, Error>) -> Void)
}

public class RestApiRequester {
    let requester: HttpRequester
    let baseUrl: URL
    let trustRoots: [Data]?
    let prefix: String = "gw"
    var challengeDelegate: URLSessionDelegate?

    init(requester: HttpRequester, baseUrl: URL, trustRoots: [Data]? = []) {
        self.requester = requester
        self.baseUrl = baseUrl
        self.trustRoots = trustRoots
    }
}

protocol Requester {
    func makeRequest<T: HTTPClientCall>(call: T, completion: @escaping (HttpCallResult<T.ResponsePayload>) -> Void)
}

extension RestApiRequester : Requester {
    private func completeURL(path: String) -> URL? {
        .prefix(baseUrl, pathComponents:[prefix, path])
    }
    
    public func makeRequest<T: HTTPClientCall>(call: T, completion: @escaping (HttpCallResult<T.ResponsePayload>) -> Void) {
        guard let url = completeURL(path: call.path) else {
            completion(HttpCallResult(status: HTTPStatus(code: 1, message: "could not construct URL")))
            return
        }

        var request = URLRequest(url: url.absoluteURL)
        request.addProtoHeaders()
        request.addHeaders(call.options?.headers ?? [:])

        do {
            request.httpBody = try call.requestPayload?.serializedData()
        } catch let error {
            completion(HttpCallResult(status: HTTPStatus(code: 1, message: error.localizedDescription)))
        }

        requester.request(url: url, method: call.method, headers: request.allHTTPHeaderFields, body: request.httpBody) { result in
            switch result {
            case .failure(let error):
                completion(HttpCallResult(status: HTTPStatus(code: 1, message: error.localizedDescription)))
            case .success(let httpResponse):
                let response = httpResponse.httpUrlResponse

                logger.info("Http Request url: \(url)")
                logger.info("Status code: \(response.statusCode)")
                
                let responsePayload : T.ResponsePayload? = {
                    guard let data = httpResponse.responseData,
                          let responsePayload = try? T.ResponsePayload.init(serializedData: data)
                    else {
                        return nil
                    }
                    return responsePayload
                }()

                let result = HttpCallResult(status: HTTPStatus(code: response.statusCode, message: ""), metadata: response, response: responsePayload)
                completion(result)
            }
        }
    }
    
}

fileprivate extension URL {
    static func prefix(_ url: URL, pathComponents: [String]) -> URL? {
        let prunedComponents = pathComponents.map({ $0.hasPrefix("/") ? String($0.dropFirst()) : $0})
        var components = URLComponents()
        components.scheme = url.scheme
        components.host = url.host
        components.path = "/" + (url.pathComponents + prunedComponents).joined(separator: "/")
        return components.url
    }
}

fileprivate extension URLRequest {
    mutating func addProtoHeaders() {
        let contentType = (fieldName:"Content-Type", value:"application/x-protobuf")
        self.setValue(contentType.value, forHTTPHeaderField: contentType.fieldName)
        
        let accept = (fieldName:"Accept", value:"application/x-protobuf")
        self.addValue(accept.value, forHTTPHeaderField: accept.fieldName)
    }
    
    mutating func addHeaders(_ headers: [String:String]) {
        headers.forEach { headerFieldName, value in
            self.setValue(value, forHTTPHeaderField: headerFieldName)
        }
    }
}
