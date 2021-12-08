//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation

protocol PossibleNIOSSLCertificate {
    var trustRootsBytes : [Data] { get }
    
    init?(trustRootBytes: [Data]) throws
    
    static func trustRoots() -> Result<Any, InvalidInputError>
}

extension PossibleNIOSSLCertificate {
    init?(trustRootBytes: [Data]) {
        return nil
    }
    
    static func trustRoots() -> Result<Any, InvalidInputError> {
        return .failure(InvalidInputError("Not implemented"))
    }
    
    static func make(trustRootBytes: [Data]) -> Result<PossibleNIOSSLCertificate, InvalidInputError> {
        do {
            let certificate = try Self.init(trustRootBytes: trustRootBytes)
            if let certificate = certificate {
                return .success(certificate)
            } else {
                return .failure(InvalidInputError("Unable to create NIOSSLCertificate"))
            }
        } catch {
            switch error {
            case let error as InvalidInputError:
                return .failure(error)
            default:
                return .failure(InvalidInputError("Unable to create NIOSSLCertificate"))
            }
        }
    }
}
