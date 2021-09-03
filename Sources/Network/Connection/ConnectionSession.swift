//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
//  swiftlint:disable all

import Foundation
import GRPC
import NIOHPACK
import NIOHTTP1
import NIOSSL

final class ConnectionSession {
    private static var ephemeralCookieStorage: HTTPCookieStorage {
        guard let cookieStorage = URLSessionConfiguration.ephemeral.httpCookieStorage else {
            // Safety: URLSessionConfiguration.ephemeral.httpCookieStorage will always return
            // non-nil.
            logger.fatalError("URLSessionConfiguration.ephemeral.httpCookieStorage returned nil.")
        }
        return cookieStorage
    }

    private let url: URL
    private let cookieStorage: HTTPCookieStorage
    var authorizationCredentials: BasicCredentials?

    private var cookieHeaders : [String:String] {
        guard let cookies = cookieStorage.cookies(for: url) else { return [:] }
        return HTTPCookie.requestHeaderFields(with: cookies)
    }

    private var authorizationHeades : [String: String] {
        guard let credentials = authorizationCredentials else { return [:] }
        return ["Authorization" : credentials.authorizationHeaderValue]
    }
    var requestHeaders: [String : String] {
        var headers : [String: String] = [:]
        headers.merge(cookieHeaders) {  (_, new) in new }
        headers.merge(authorizationHeades) {  (_, new) in new }
        return headers
    }
    
    convenience init(config: ConnectionConfigProtocol) {
        self.init(url: config.url, authorization: config.authorization)
    }

    init(url: MobileCoinUrlProtocol, authorization: BasicCredentials? = nil) {
        self.url = url.httpBasedUrl
        self.cookieStorage = Self.ephemeralCookieStorage
        self.authorizationCredentials = authorization
    }

    func addRequestHeaders(to hpackHeaders: inout HPACKHeaders) {
        addAuthorizationHeader(to: &hpackHeaders)
        addCookieHeader(to: &hpackHeaders)
    }

    func processResponse(headers: HPACKHeaders) {
        processCookieHeader(headers: headers)
    }
    
    func processResponse(headers: [AnyHashable : Any]) {
        processCookieHeader(headers: headers)
    }
}

extension ConnectionSession {
    private func addAuthorizationHeader(to hpackHeaders: inout HPACKHeaders) {
        if let credentials = authorizationCredentials {
            hpackHeaders.add(httpHeaders: ["Authorization": credentials.authorizationHeaderValue])
        }
    }
    
}

// GRPC
extension ConnectionSession {
    private func processCookieHeader(headers: HPACKHeaders) {
        let http1Headers = Dictionary(
            headers.map { ($0.name.capitalized, $0.value) },
            uniquingKeysWith: { k, _ in k })

        let receivedCookies = HTTPCookie.cookies(
            withResponseHeaderFields: http1Headers,
            for: url)
        receivedCookies.forEach(cookieStorage.setCookie)
    }
    
    private func addCookieHeader(to hpackHeaders: inout HPACKHeaders) {
        if let cookies = cookieStorage.cookies(for: url) {
            hpackHeaders.add(httpHeaders: HTTPCookie.requestHeaderFields(with: cookies))
        }
    }

    private func processCookieHeader(headers: [AnyHashable: Any]) {
        let http1Headers = Dictionary(
            headers.compactMap({ (key: AnyHashable, value: Any) -> (name: String, value: String)? in
                guard let name = key as? String else { return nil }
                guard let value = value as? String else { return nil }
                return (name:name, value:value)
            }).map { ($0.name.capitalized, $0.value) },
            uniquingKeysWith: { k, _ in k })

        let receivedCookies = HTTPCookie.cookies(
            withResponseHeaderFields: http1Headers,
            for: url)
        receivedCookies.forEach(cookieStorage.setCookie)
    }
    
}

extension HPACKHeaders {
    fileprivate mutating func add(httpHeaders: [String: String]) {
        add(httpHeaders: HTTPHeaders(Array(httpHeaders)))
    }

    fileprivate mutating func add(httpHeaders: HTTPHeaders) {
        add(contentsOf: HPACKHeaders(httpHeaders: httpHeaders))
    }
}

class ConnectionSessionTrust : NSObject, URLSessionDelegate {
    let trustRoots: [NIOSSLCertificate]
    let url : URL
    
    init(url: URL, trustRoots: [NIOSSLCertificate]) {
        self.url = url
        self.trustRoots = trustRoots
    }

    func urlSession(_ session: URLSession,
                  didReceive challenge: URLAuthenticationChallenge,
                  completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }
        // indicates the server requested a client certificate.
//        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodClientCertificate else {
//            logger.info("No cert needed")
//            completionHandler(.performDefaultHandling, nil)
//            return
//        }
        
//        guard let trust = challenge.protectionSpace.serverTrust else {
//            logger.info("no server trust")
//            completionHandler(.performDefaultHandling, nil)
//            return
//        }
//
////        let isServerTrusted = SecTrustEvaluateWithError(serverTrust, nil)
//
//        guard let host = url.host else {
//            completionHandler(.performDefaultHandling, nil)
//            return
//        }
//
//
//        guard let ourCertData = Data(base64Encoded: String.trustRootsB64) else { //, options: Data.Base64DecodingOptions.ignoreUnknownCharacters) else {
//            completionHandler(.performDefaultHandling, nil)
//            return
//        }
//
//        guard let certificate = SecCertificateCreateWithData(nil, ourCertData as CFData) else {
//            completionHandler(.performDefaultHandling, nil)
//            return
//        }
//
////        // use certificate e.g. copy the public key
////        let publicKey = SecCertificateCopyKey(certificate)!
////
////        guard let publicKeySec = SecKeyCreateWithData(ourCertData as! CFData, attributesRSAPub as CFDictionary, &error) else {
////            completionHandler(.performDefaultHandling, nil)
////            return
////        }
//        let policy = SecPolicyCreateSSL(true, (host as CFString))
//        let basicPolicy = SecPolicyCreateBasicX509()
//        let manualTrust = UnsafeMutablePointer<SecTrust?>.allocate(capacity: 1)
//        if let serverCertificate = SecTrustGetCertificateAtIndex(trust, 0) {
//            let certArray = Array(arrayLiteral:serverCertificate, certificate)
//            let status = SecTrustCreateWithCertificates(certArray as AnyObject, policy, manualTrust)
//
//            print(serverCertificate)
//            print(certificate)
//            print(certificate == serverCertificate)
//
//            guard status == errSecSuccess else { return }
//
////            let trust = optionalTrust!
//
////            if let pointee = manualTrust.pointee,
////               let key = SecTrustCopyPublicKey(pointee) {
////                trustRoots.compactMap({ root in
////                    try? root.extractPublicKey().toSPKIBytes()
////                }).forEach({print($0)})
////
////                print(key)
////                if pinnedKeys().contains(serverCertificateKey) {
////                    completionHandler(.useCredential, URLCredential(trust: trust))
////                    return
////                }
////            }
//       }
////        guard let file = Bundle(for: HTTPAccessURLSessionDelegate.self).url(forResource: p12Filename, withExtension: "p12"),
////              let p12Data = try? Data(contentsOf: file) else {
////            // Loading of the p12 file's data failed.
////            completionHandler(.performDefaultHandling, nil)
////            return
////        }
////
////        // Interpret the data in the P12 data blob with
////        // a little helper class called `PKCS12`.
////        let password = "MyP12Password" // Obviously this should be stored or entered more securely.
////        let p12Contents = PKCS12(pkcs12Data: p12Data, password: password)
////        guard let identity = p12Contents.identity else {
////            // Creating a PKCS12 never fails, but interpretting th contained data can. So again, no identity? We fall back to default.
////            completionHandler(.performDefaultHandling, nil)
////            return
////        }
//
//        // In my case, and as Apple recommends,
//        // we do not pass the certificate chain into
//        // the URLCredential used to respond to the challenge.
////        let credential = URLCredential(identity: identity,
////                                   certificates: nil,
////                                    persistence: .none)
////        challenge.sender?.use(credential, for: challenge)
////        completionHandler(.useCredential, credential)
//    }
}

extension String {
    static let trustRootsB64 =
        /// MobileCoin-managed Consensus and Fog services use Let's Encrypt with an intermediate
        /// certificate that's cross-signed by IdenTrust's "DST Root CA X3": https://crt.sh/?d=8395
        """
            MIIDSjCCAjKgAwIBAgIQRK+wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/MSQwIgYDVQQKExtEaWdpdGF\
            sIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMTDkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDT\
            IxMDkzMDE0MDExNVowPzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQDEw5EU\
            1QgUm9vdCBDQSBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAN+v6ZdQCINXtMxiZfaQguzH0yxr\
            MMpb7NnDfcdAwRgUi+DoM3ZJKuM/IUmTrE4Orz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoO\
            ifooUMM0RoOEqOLl5CjH9UL2AZd+3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9bxiqKqy69cK\
            3FCxolkHRyxXtqqzTWMIn/5WgTe1QLyNau7Fqckh49ZLOMxt+/yUFw7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40du\
            tolucbY38EVAjqr2m7xPi71XAicPNaDaeQQmxkqtilX4+U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB\
            /zAOBgNVHQ8BAf8EBAMCAQYwHQYDVR0OBBYEFMSnsaR7LHH62+FLkHX/xBVghYkQMA0GCSqGSIb3DQEBBQUAA4I\
            BAQCjGiybFwBcqR7uKGY3Or+Dxz9LwwmglSBd49lZRNI+DT69ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8fa\
            XbauX+5v3gTt23ADq1cEmv8uXrAvHRAosZy5Q6XkjEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK+rlmM6pZW87ip\
            xZzR8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZImlJnt1ir/md2cXjbDaJWFBM5JDGFoqgCWjBH4d1QB7wC\
            CZAA62RjYJsWvIjJEubSfZGL+T0yjWW06XyxV3bqxbYoOb8VZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ
            """
}


/*
 all our keys are x509 certs
 
 certs include lots of info AND Public key
 
 certs have public and private key
 
 Im CA, gives me his certificate, then as CA I sign it, I hash his certificate and encrypt with my private key of my certificate.
 
 anyone who can decrypt their cert using the CA public key, and they can compare the hash of the leaf cert with the decrypted has using the CA public key.

 leaf certificate stored on device
 
 server will send you its certificate, usually sends the whole chain except root which is in the system.
 
 instead of including leaf cert, we include CA certificate.
 
 consensus TLS connection
 
 negotiate encryption key
 
 */
