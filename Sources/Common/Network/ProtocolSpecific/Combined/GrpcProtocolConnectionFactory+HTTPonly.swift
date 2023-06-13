//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

#if canImport(LibMobileCoinGRPC) 
#else

class GrpcProtocolConnectionFactory: ProtocolConnectionFactory {}
#if canImport(LibMobileCoinHTTP) 
#else
#endif
#endif
