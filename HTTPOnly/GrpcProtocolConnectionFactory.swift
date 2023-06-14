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

        // Cannot import either SPM modules
        // Cocoapods version here
        #if canImport(GRPC)
        #else

        // Cannot import GRPC, so use empty protocol factory
        class GrpcProtocolConnectionFactory: ProtocolConnectionFactory {}
        #endif

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


