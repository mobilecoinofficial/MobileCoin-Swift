//
//  Copyright (c) 2020-2023 MobileCoin. All rights reserved.
//

import Foundation


// HTTP-Only
// Cannot import GRPC, can import HTTP == HTTP-only
#if canImport(GRPC) 
#else

#if canImport(LibMobileCoinHTTP) 
class GrpcProtocolConnectionFactory: ProtocolConnectionFactory {}
#else
#endif

#endif

// GRPC-Only
// Cannot import HTTP, can import GRPC == GRPC-only
#if canImport(LibMobileCoinHTTP) 
#else

#if canImport(GRPC) 
class HttpProtocolConnectionFactory: ProtocolConnectionFactory {}
#else
#endif

#endif
