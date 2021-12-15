//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

class HttpProtocolConnectionFactory : ProtocolConnectionFactory {
    //    typealias ConsensusServiceProvider = ConsensusGrpcConnection
    //
    //    typealias BlockchainServiceProvider = BlockchainGrpcConnection
    //
    //    typealias FogViewServiceProvider = FogViewGrpcConnection
    //
    //    typealias FogMerkleProofServiceProvider = FogMerkleProofGrpcConnection
    //
    //    typealias FogKeyImageServiceProvider = FogKeyImageGrpcConnection
    //
    //    typealias FogBlockServiceProvider = FogBlockGrpcConnection
    //
    //    typealias FogUntrustedTxOutServiceProvider = FogUntrustedTxOutGrpcConnection
    //
    let requester : HttpRequester
    
    init(httpRequester: HttpRequester?) {
        self.requester = httpRequester ?? DefaultHttpRequester()
    }
    
    func makeConsensusService(
        config: AttestedConnectionConfig<ConsensusUrl>,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> ConsensusService {
        ConsensusHttpConnection(
                        config: config,
                        requester: RestApiRequester(requester: requester, baseUrl: config.url.httpBasedUrl),
                        targetQueue: targetQueue,
                        rng: rng,
                        rngContext: rngContext)
    }
    
    func makeBlockchainService(
        config: ConnectionConfig<ConsensusUrl>,
        targetQueue: DispatchQueue?
    ) -> BlockchainService {
        BlockchainHttpConnection(
                        config: config,
                        requester: RestApiRequester(requester: requester, baseUrl: config.url.httpBasedUrl),
                        targetQueue: targetQueue)
    }
    
    func makeFogViewService(
        config: AttestedConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> FogViewService {
        FogViewHttpConnection(
                config: config,
                requester: RestApiRequester(requester: requester, baseUrl: config.url.httpBasedUrl),
                targetQueue: targetQueue,
                rng: rng,
                rngContext: rngContext)
    }
        
    func makeFogMerkleProofService(
        config: AttestedConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> FogMerkleProofService {
        FogMerkleProofHttpConnection(
                        config: config,
                        requester: RestApiRequester(requester: requester, baseUrl: config.url.httpBasedUrl),
                        targetQueue: targetQueue,
                        rng: rng,
                        rngContext: rngContext)
    }
    
    func makeFogKeyImageService(
        config: AttestedConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?,
        rng: (@convention(c) (UnsafeMutableRawPointer?) -> UInt64)?,
        rngContext: Any?
    ) -> FogKeyImageService {
        FogKeyImageHttpConnection(
                        config: config,
                        requester: RestApiRequester(requester: requester, baseUrl: config.url.httpBasedUrl),
                        targetQueue: targetQueue,
                        rng: rng,
                        rngContext: rngContext)
    }
    
    func makeFogBlockService(
        config: ConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) -> FogBlockService {
        FogBlockHttpConnection(
                        config: config,
                        requester: RestApiRequester(requester: requester, baseUrl: config.url.httpBasedUrl),
                        targetQueue: targetQueue)
    }
    
    func makeFogUntrustedTxOutService(
        config: ConnectionConfig<FogUrl>,
        targetQueue: DispatchQueue?
    ) -> FogUntrustedTxOutService {
        FogUntrustedTxOutHttpConnection(
                        config: config,
                        requester: RestApiRequester(requester: requester, baseUrl: config.url.httpBasedUrl),
                        targetQueue: targetQueue)
    }
}

class DefaultHttpRequester: HttpRequester {
    let configuration : URLSessionConfiguration = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 30
        return config
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

        let session = URLSession(configuration: configuration)
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
}

