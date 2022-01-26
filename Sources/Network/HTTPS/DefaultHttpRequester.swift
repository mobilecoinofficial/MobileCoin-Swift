//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

class DefaultHttpRequester: NSObject, HttpRequester {
    var fogTrustRoots: SSLCertificates?
    var consensusTrustRoots: SSLCertificates?
    
    var pinnedKeys: [SecKey] {
        [fogTrustRoots, consensusTrustRoots].compactMap {
            $0 as? SecSSLCertificates
        }.compactMap {
            $0.publicKeys
        }.flatMap { $0 }
    }
    
    static let certPinningEnabled = true

    static let defaultConfiguration : URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        return config
    }()
    
    private static let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.underlyingQueue = .global()
        return queue
    }()

    private lazy var session: URLSession = {
       URLSession(configuration: DefaultHttpRequester.defaultConfiguration, delegate: self, delegateQueue: Self.operationQueue)
    }()
    
    func request(
        url: URL,
        method: HTTPMethod,
        headers: [String: String]?,
        body: Data?,
        completion: @escaping (Result<HTTPResponse, Error>) -> Void
    ) {
        var request = URLRequest(url: url.absoluteURL)
        request.httpMethod = method.rawValue
        headers?.forEach({ key, value in
            request.setValue(value, forHTTPHeaderField: key)
        })

        request.httpBody = body

        let task = session.dataTask(with: request) {data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(ConnectionError.invalidServerResponse("No Response")))
                return
            }
            let httpResponse = HTTPResponse(httpUrlResponse: response, responseData: data)
            completion(.success(httpResponse))
        }
        task.resume()
    }
    
    func setConsensusTrustRoots(_ trustRoots: SSLCertificates?) {
        consensusTrustRoots = trustRoots
    }
    
    func setFogTrustRoots(_ trustRoots: SSLCertificates?) {
        fogTrustRoots = trustRoots
    }
}

extension DefaultHttpRequester {
    public typealias URLAuthenticationChallengeCompletion = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void

    func urlSession(didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping URLAuthenticationChallengeCompletion) {
        guard let trust = challenge.protectionSpace.serverTrust, SecTrustGetCertificateCount(trust) > 0 else {
            // This case will probably get handled by ATS, but still...
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        guard Self.certPinningEnabled && pinnedKeys.isNotEmpty else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        /// Compare the public keys
        let serverCertificateKey = SecTrustGetCertificateAtIndex(trust, 0)?.asPublicKey()
        switch serverCertificateKey {
        case .success(let key) where pinnedKeys.contains(key):
            completionHandler(.useCredential, URLCredential(trust: trust))
        case .failure(let error):
            /// Failing here means that the public key of the server does not match the stored one. This can
            /// either indicate a MITM attack, or that the backend certificate and the private key changed,
            /// most likely due to expiration.
            logger.error("Error: \(error)")
            completionHandler(.cancelAuthenticationChallenge, nil)
        default:
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

extension DefaultHttpRequester: URLSessionDelegate {

    public func urlSession(_ session: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping URLAuthenticationChallengeCompletion)
    {
        urlSession(didReceive: challenge, completionHandler: completionHandler)
    }

}

extension DefaultHttpRequester: URLSessionTaskDelegate {

    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping URLAuthenticationChallengeCompletion)
    {
        urlSession(didReceive: challenge, completionHandler: completionHandler)
    }

}
