//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import GRPC
import NIO
import NIOHPACK


public struct HttpCallResult<ResponsePayload> {
    let status: HTTPStatus
    let initialMetadata: HTTPURLResponse?
    let response: ResponsePayload?
}

extension HttpCallResult {
    init(
        status: GRPCStatus,
        initialMetadata: HTTPURLResponse?,
        response: ResponsePayload?
    ) {
        // TODO REMOVE
        self.init(status: HTTPStatus(grpcStatus: status), initialMetadata: initialMetadata, response: response)
    }
}

protocol HttpClientCall {
    /// The type of the request message for the call.
    associatedtype RequestPayload
    
    /// The type of the response message for the call.
    associatedtype ResponsePayload
    
    /// The event loop this call is running on.
    var eventLoop: NIOCore.EventLoop { get }
    
    /// The options used to make the RPC.
    var options: GRPC.CallOptions { get }
    
    /// HTTP/2 stream that requests and responses are sent and received on.
    var subchannel: NIOCore.EventLoopFuture<NIOCore.Channel> { get }
    
    /// Initial response metadata.
    var initialMetadata: NIOCore.EventLoopFuture<NIOHPACK.HPACKHeaders> { get }
    
    /// Status of this call which may be populated by the server or client.
    ///
    /// The client may populate the status if, for example, it was not possible to connect to the service.
    ///
    /// Note: despite `GRPCStatus` conforming to `Error`, the value will be __always__ delivered as a __success__
    /// result even if the status represents a __negative__ outcome. This future will __never__ be fulfilled
    /// with an error.
    var status: NIOCore.EventLoopFuture<GRPC.GRPCStatus> { get }
    
    /// Trailing response metadata.
    var trailingMetadata: NIOCore.EventLoopFuture<NIOHPACK.HPACKHeaders> { get }
    
    /// Cancel the current call.
    ///
    /// Closes the HTTP/2 stream once it becomes available. Additional writes to the channel will be ignored.
    /// Any unfulfilled promises will be failed with a cancelled status (excepting `status` which will be
    /// succeeded, if not already succeeded).
    func cancel(promise: NIOCore.EventLoopPromise<Void>?)
    
    var response: NIOCore.EventLoopFuture<Self.ResponsePayload> { get }
}

//struct HttpResponseClientCall : HttpClientCall {
//    var response: EventLoopFuture<Int>
//
//    var eventLoop: EventLoop
//
//    var options: CallOptions
//
//    var subchannel: EventLoopFuture<Channel>
//
//    var initialMetadata: EventLoopFuture<HPACKHeaders>
//
//    var status: EventLoopFuture<GRPCStatus>
//
//    var trailingMetadata: EventLoopFuture<HPACKHeaders>
//
//    func cancel(promise: EventLoopPromise<Void>?) {
//
//    }
//
//    typealias RequestPayload = Int
//
//    typealias ResponsePayload = Int
//
//    var callResult: EventLoopFuture<HttpCallResult<ResponsePayload>> {
//        var resolvedInitialMetadata: HPACKHeaders?
//        initialMetadata.whenSuccess { resolvedInitialMetadata = $0 }
//        var resolvedResponse: ResponsePayload?
//        response.whenSuccess { resolvedResponse = $0 }
//        var resolvedTrailingMetadata: HPACKHeaders?
//        trailingMetadata.whenSuccess { resolvedTrailingMetadata = $0 }
//
//        return status.flatMap { status in
//            self.eventLoop.makeSucceededFuture(
//                HttpCallResult(
//                    status: status,
//                    initialMetadata: resolvedInitialMetadata,
//                    response: resolvedResponse,
//                    trailingMetadata: resolvedTrailingMetadata))
//        }
//    }
//}



/// Encapsulates the result of a gRPC call.
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



