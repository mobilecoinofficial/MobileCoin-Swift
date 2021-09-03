//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import NIO
import NIOHPACK


public struct HttpCallResult<ResponsePayload> {
    let status: HTTPStatus
    let metadata: HTTPURLResponse?
    let response: ResponsePayload?
}

extension HttpCallResult {
    init(
        status: HTTPStatus
    ) {
        // TODO REMOVE
        self.init(status: status, metadata: nil, response: nil)
    }
}

/// Encapsulates the result of a HTTP call.
public struct HTTPStatus : Error {
    
    /// The status code of the RPC.
    public var code: Int

    /// The status message of the RPC.
    public var message: String?

    /// Whether the status is '.ok'.
    public var isOk: Bool {
        (200...299).contains(code)
    }

    /// The default status to return for succeeded calls.
    ///
    /// - Important: This should *not* be used when checking whether a returned status has an 'ok'
    ///   status code. Use `HTTPStatus.isOk` or check the code directly.
    public static let ok: HTTPStatus = .init(code: 200, message: "Success")

    /// "Internal server error" status.
    public static let processingError: HTTPStatus = .init(code: 500, message: "Error")
}

extension HTTPStatus {
    init(grpcStatus: GRPCStatus) {
        self.init(code: grpcStatus.isOk ? 200 : 500, message: grpcStatus.message)
    }
    
    func temp(code: GRPCStatus.Code) -> Int{
        switch code {
        case .ok:
            return 200
        case .cancelled:
            return 500
        case .unknown:
            return 500
        case .invalidArgument:
            return 400
        case .deadlineExceeded:
            return 504
        case .notFound:
            return 404
        case .alreadyExists:
            return 409
        case .permissionDenied:
            return 403
        case .resourceExhausted:
            return 400
        case .failedPrecondition:
            return 412
        case .aborted:
            return 500
        case .outOfRange:
            return 400
        case .unimplemented:
            return 501
        case .internalError:
            return 500
        case .unavailable:
            return 503
        case .dataLoss:
            return 500
        case .unauthenticated:
            return 403
        default:
            return 500
        }
    }
}



