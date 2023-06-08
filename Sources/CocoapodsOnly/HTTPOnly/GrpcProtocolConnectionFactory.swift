//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

// HTTP-Only
// Cannot import GRPC, can import HTTP == HTTP-only
#if canImport(LibMobileCoinGRPC) 
#else

    #if canImport(LibMobileCoinHTTP) 
    class GrpcProtocolConnectionFactory: ProtocolConnectionFactory {}
    #else
    
    // This is for Cocoapods, means we cannot import either SPM package.
    class GrpcProtocolConnectionFactory: ProtocolConnectionFactory {}
    #endif

#endif

    // GRPC-Only
    // Cannot import HTTP, can import GRPC == GRPC-only
    #if canImport(LibMobileCoinHTTP) 
    #else
    
    #if canImport(LibMobileCoinGRPC) 
    class HttpProtocolConnectionFactory: ProtocolConnectionFactory {}
    #else
    #endif

#endif
