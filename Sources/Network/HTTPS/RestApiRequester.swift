//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

public class RestApiRequester {
    let requester: HttpRequester
    let baseUrl: MobileCoinUrlProtocol
    let prefix: String = "gw"

    init(requester: HttpRequester, baseUrl: MobileCoinUrlProtocol) {
        self.requester = requester
        self.baseUrl = baseUrl
    }
}

protocol Requester {
    func makeRequest<T: HTTPClientCall>(call: T, completion: @escaping (HttpCallResult<T.ResponsePayload>) -> Void)
}

extension RestApiRequester : Requester {
    private func completeURL(path: String) -> URL? {
        .prefix(baseUrl.httpBasedUrl, pathComponents:[prefix, path])
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

