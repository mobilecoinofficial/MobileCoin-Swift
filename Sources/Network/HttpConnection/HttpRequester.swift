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
        completion: @escaping (HTTPResult) -> Void)
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

public enum HTTPResult {
    case success(response: HTTPResponse)
    case failure(error: Error)
}

// - Add relative path component toe NetworkedMessage and then combine at runtime.

public class HTTPRequester {
    public static let defaultConfiguration : URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        return config
    }()

    let configuration : URLSessionConfiguration
    let baseUrl: URL
    let trustRoots: [NIOSSLCertificate]?
    let prefix: String = "gw"

    public init(baseUrl: URL, trustRoots: [NIOSSLCertificate]?, configuration: URLSessionConfiguration = HTTPRequester.defaultConfiguration) {
        self.configuration = configuration
        self.baseUrl = baseUrl
        self.trustRoots = trustRoots
    }
}

public protocol Requester {
//    func makeRequest<T: HTTPClientCall>(call: T, completion: @escaping (Result<T.ResponsePayload, Error>) -> Void)
    func makeRequest<T: HTTPClientCall>(call: T, completion: @escaping (Result<HttpCallResult<T.ResponsePayload>, Error>) -> Void)
}

extension HTTPRequester : Requester {
    private func completeURLFromPath(_ path: String) -> URL? {
        URL(string: path, relativeTo: URL(string: prefix, relativeTo: baseUrl))
    }
    
//    public func makeRequest<T: HTTPClientCall>(call: T, completion: @escaping (Result<HttpCallResult<T.ResponsePayload>, Error>) -> Void) {
    public func makeRequest<T: HTTPClientCall>(call: T, completion: @escaping (Result<HttpCallResult<T.ResponsePayload>, Error>) -> Void) {
        let session = URLSession(configuration: configuration)
        
        guard let url = completeURLFromPath(call.path) else {
            completion(.failure(InvalidInputError("Invalid URL")))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = call.method.rawValue
        request.addProtoHeaders()

        do {
            request.httpBody = try call.requestPayload?.serializedData() ?? Google_Protobuf_Empty().serializedData()
            logger.debug("MC HTTP Request: \(call.requestPayload?.prettyPrintJSON() ?? "")")
        } catch let error {
            logger.debug(error.localizedDescription)
        }

        session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(NetworkingError.noResponse))
                return
            }
            
            guard (200...299).contains(response.statusCode) else {
                completion(.failure(HTTPResponseStatusCodeError(response.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkingError.noData))
                return
            }
            
            do {
                let responsePayload = try T.ResponsePayload.init(serializedData: data)
                logger.debug("Resposne Proto as JSON: \((try? responsePayload.jsonString()) ?? "Unable to print JSON")")
                
                // let result = HttpCallResult<T.ResponsePayload>(status: HTTPStatus(code: response.statusCode, message: ""), initialMetadata: response, response: responsePayload)
                let result = HttpCallResult<T.ResponsePayload>(status: HTTPStatus(code: response.statusCode, message: ""), initialMetadata: response, response: responsePayload)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
}

fileprivate extension URLRequest {
    mutating func addProtoHeaders() {
        let contentType = HTTPHeadersConstants.CONTENT_TYPE_PROTOBUF
        self.setValue(contentType.value, forHTTPHeaderField: contentType.fieldName)
        
        let accept = HTTPHeadersConstants.ACCEPT_PROTOBUF
        self.addValue(accept.value, forHTTPHeaderField: accept.fieldName)
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
        case .unprocessableEntity: return 422
        case .internalServerError: return 500
        case .invalidResponseFromExternal: return 502
        default: return nil
        }
    }
}

extension HTTPResponseStatusCodeError : CustomStringConvertible {
    public var description: String {
        switch self {
        case .badRequest: return "The request is malformed (ex. missing or incorrect parameters)"
        case .unauthorized: return "Failed to provide proper authentication with the request."
        case .forbidden: return "The action in the request is not allowed."
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
