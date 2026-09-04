// swiftlint:disable:this file_name
//
//  Copyright (c) 2020-2023 MobileCoin. All rights reserved.
//

import Foundation

// The HTTP-only stand-in for GrpcProtocolConnectionFactory lives with every
// other declaration of that type, in GrpcProtocolConnectionFactory+HTTPonly.swift.

// GRPC-Only
// Cannot import HTTP, can import GRPC == GRPC-only
#if canImport(LibMobileCoinHTTP)
#else

    #if canImport(LibMobileCoinGRPC)
    class HttpProtocolConnectionFactory: ProtocolConnectionFactory {}
    #else
    #endif

#endif
