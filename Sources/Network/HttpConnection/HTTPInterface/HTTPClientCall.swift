//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import SwiftProtobuf


public protocol HTTPClientCall {
    /// The type of the request message for the call.
    associatedtype RequestPayload: SwiftProtobuf.Message
    
    /// The type of the response message for the call.
    associatedtype ResponsePayload: SwiftProtobuf.Message
    
    /// The resource path (generated)
    var path: String { get }
    
    /// The http method to use for the call
    var method: HTTPMethod { get }
    
    var requestPayload: RequestPayload? { get set }

    /// The response message returned from the service if the call is successful. This may be failed
    /// if the call encounters an error.
    ///
    /// Callers should rely on the `status` of the call for the canonical outcome.
    var responseType: ResponsePayload.Type { get set }
    
    /// The options used to make the session.
    var options: HTTPCallOptions? { get }
    
    /// Initial response metadata.
    var initialMetadata: HTTPURLResponse? { get }
    
    /// Status of this call which may be populated by the server or client.
    ///
    /// The client may populate the status if, for example, it was not possible to connect to the service.
    ///
    /// Note: despite `GRPCStatus` conforming to `Error`, the value will be __always__ delivered as a __success__
    /// result even if the status represents a __negative__ outcome. This future will __never__ be fulfilled
    /// with an error.
    var status: HTTPStatus? { get }
    
    /// Cancel the current call.
    ///
    /// Closes the HTTP/2 stream once it becomes available. Additional writes to the channel will be ignored.
    /// Any unfulfilled promises will be failed with a cancelled status (excepting `status` which will be
    /// succeeded, if not already succeeded).
    func cancel()
}

//public struct HTTPRestCall<RequestPayload, ResponsePayload> : HTTPClientCall {
//
//    /// The options used in the URLSession
//    public var options: HTTP.CallOptions?
//
//    /// Cancel this session if it hasn't already completed.
//    public func cancel() {
//
//    }
//
//    /// The initial metadata returned from the server.
//    public var initialMetadata: HTTPURLResponse?
//
//    /// The final status of the the session.
//    public var status: HTTPStatus?
//}
//
