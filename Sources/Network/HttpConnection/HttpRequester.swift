//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

// swiftlint:disable all

import Foundation
import SwiftProtobuf
import NIOSSL

public protocol HttpRequester {
    func request(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        completion: @escaping (Result<HTTPResponse, Error>) -> Void)
}

public enum HTTPMethod : String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case HEAD = "HEAD"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

public struct HTTPResponse {
    public let httpUrlResponse: HTTPURLResponse
    public let responseData: Data?

    public var statusCode: Int {
        httpUrlResponse.statusCode
    }

    public var allHeaderFields: [AnyHashable: Any] {
        httpUrlResponse.allHeaderFields
    }
}

// - Add relative path component toe NetworkedMessage and then combine at runtime.

public class RestApiRequester {
    let requester: HttpRequester
    let baseUrl: URL
    let trustRoots: [NIOSSLCertificate]?
    let prefix: String = "gw"
    var challengeDelegate: URLSessionDelegate?

    public init(requester: HttpRequester, baseUrl: URL, trustRoots: [NIOSSLCertificate]? = []) {
        self.requester = requester
        self.baseUrl = baseUrl
        self.trustRoots = trustRoots
        self.challengeDelegate = ConnectionSessionTrust(url: baseUrl, trustRoots: trustRoots ?? [])
    }
}

public protocol Requester {
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
        let contentType = HTTPHeadersConstants.CONTENT_TYPE_PROTOBUF
        self.setValue(contentType.value, forHTTPHeaderField: contentType.fieldName)
        
        let accept = HTTPHeadersConstants.ACCEPT_PROTOBUF
        self.addValue(accept.value, forHTTPHeaderField: accept.fieldName)
    }
    
    mutating func addHeaders(_ headers: [String:String]) {
        headers.forEach { headerFieldName, value in
            self.setValue(value, forHTTPHeaderField: headerFieldName)
        }
    }
}

struct HTTPHeadersConstants {
    static var ACCEPT_PROTOBUF = (fieldName:"Accept", value:"application/x-protobuf")
    static var CONTENT_TYPE_PROTOBUF = (fieldName:"Content-Type", value:"application/x-protobuf")
}

extension Message {
    func prettyPrintJSON() -> String {
        guard let jsonData = try? self.jsonUTF8Data(),
              let data = try? JSONSerialization.jsonObject(with: jsonData, options: []),
              let object = try? JSONSerialization.data(withJSONObject: data, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: object, encoding: String.Encoding.utf8) else {
              return "Unable to pretty print json"
        }
        return prettyPrintedString
    }
}

public enum HTTPResponseStatusCodeError : Error {
    case unauthorized
    case badRequest
    case forbidden
    case notFound
    case unprocessableEntity
    case internalServerError
    case invalidResponseFromExternal
    case unknown(Int)
    
    // TODO add other HTTP errors here
    init(_ code: Int) {
        switch code {
        case 400: self = .badRequest
        case 401: self = .unauthorized
        case 403: self = .forbidden
        case 404: self = .notFound
        case 422: self = .unprocessableEntity
        case 500: self = .internalServerError
        case 502: self = .invalidResponseFromExternal
        default: self = .unknown(code)
        }
    }
    
    var value : Int? {
        switch self {
        case .badRequest: return 400
        case .unauthorized: return 401
        case .forbidden: return 403
        case .notFound: return 404
        case .unprocessableEntity: return 422
        case .internalServerError: return 500
        case .invalidResponseFromExternal: return 502
        default: return nil
        }
    }
}

extension HTTPResponseStatusCodeError : CustomStringConvertible {
    public var localizedDescription: String {
        return description
    }
    
    public var description: String {
        switch self {
        case .badRequest: return "The request is malformed (ex. missing or incorrect parameters)"
        case .unauthorized: return "Failed to provide proper authentication with the request."
        case .forbidden: return "The action in the request is not allowed."
        case .notFound: return "Not Found"
        case .unprocessableEntity: return "The server understands the content type of the request entity, and the syntax of the request entity is correct, but it was unable to process the contained instructions."
        case .internalServerError: return "Unhandled exception from one of the other services: the Database, FTX, or the Full Service Wallet."
        case .invalidResponseFromExternal: return "The server was acting as a gateway or proxy and received an invalid response from the upstream server (ie. one of the other services: the Database, FTX, or the Full Service Wallet.)"
        case .unknown(let code): return "HTTP Response code \(code)"
        }
    }
}

extension HTTPResponseStatusCodeError : Equatable {
    public static func == (lhs: HTTPResponseStatusCodeError, rhs: HTTPResponseStatusCodeError) -> Bool {
        switch (lhs, rhs) {
        case (.unknown(let lhsValue), .unknown(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return lhs.value ?? -1 == rhs.value ?? -1
        }
    }
}

public enum NetworkingError: Error {
    case unknownDecodingError
    case noResponseStatus
    case noResponse
    case unknown
    case noData
}

extension NetworkingError: CustomStringConvertible {
    public var description : String {
        switch self {
        case .noResponseStatus: return "Response status not explicitly set in proto response"
        case .noResponse: return "URLResponse object is nil"
        case .unknownDecodingError: return "Unknown decoding error"
        case .unknown: return "Unknown netowrking error"
        case .noData: return "No data in resposne"
        }
    }
}

//public class MyURLSessionDelegate: NSObject, URLSessionDelegate {
//    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        // `NSURLAuthenticationMethodClientCertificate`
//        // indicates the server requested a client certificate.
//        if challenge.protectionSpace.authenticationMethod
//             != NSURLAuthenticationMethodClientCertificate {
//                completionHandler(.performDefaultHandling, nil)
//                return
//        }
//
//        guard let file = Bundle(for: HTTPAccessURLSessionDelegate.self).url(forResource: p12Filename, withExtension: "p12"),
//              let p12Data = try? Data(contentsOf: file) else {
//            // Loading of the p12 file's data failed.
//            completionHandler(.performDefaultHandling, nil)
//            return
//        }
//
//        // Interpret the data in the P12 data blob with
//        // a little helper class called `PKCS12`.
//        let password = "MyP12Password" // Obviously this should be stored or entered more securely.
//        let p12Contents = PKCS12(pkcs12Data: p12Data, password: password)
//        guard let identity = p12Contents.identity else {
//            // Creating a PKCS12 never fails, but interpretting th contained data can. So again, no identity? We fall back to default.
//            completionHandler(.performDefaultHandling, nil)
//            return
//        }
//
//        // In my case, and as Apple recommends,
//        // we do not pass the certificate chain into
//        // the URLCredential used to respond to the challenge.
//        let credential = URLCredential(identity: identity,
//                                   certificates: nil,
//                                    persistence: .none)
//        challenge.sender?.use(credential, for: challenge)
//        completionHandler(.useCredential, credential)
//    }
//}
