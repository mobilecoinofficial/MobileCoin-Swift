//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import SwiftProtobuf
import LibMobileCoin

///// Usage: instantiate `ConsensusClient_ConsensusClientAPIRestClient`, then call methods of this protocol to make APIRest calls.
public protocol ConsensusClient_ConsensusClientAPIRestClientProtocol: HTTPClient {
  var serviceName: String { get }

  func clientTxPropose(
    _ request: Attest_Message,
    callOptions: HTTPCallOptions?
  ) -> HTTPUnaryCall<Attest_Message, ConsensusCommon_ProposeTxResponse>
}

extension ConsensusClient_ConsensusClientAPIRestClientProtocol {
  public var serviceName: String {
    return "consensus_client.ConsensusClientAPIRest"
  }

  //// This APIRest call is made with an encrypted payload for the enclave,
  //// indicating a new value to be acted upon.
  ///
  /// - Parameters:
  ///   - request: Request to send to ClientTxPropose.
  ///   - callOptions: Call options.
  /// - Returns: A `HTTPUnaryCall` with futures for the metadata, status and response.
  public func clientTxPropose(
    _ request: Attest_Message,
    callOptions: HTTPCallOptions? = nil
  ) -> HTTPUnaryCall<Attest_Message, ConsensusCommon_ProposeTxResponse> {
    return self.makeHTTPUnaryCall(
      path: "/consensus_client.ConsensusClientAPIRest/ClientTxPropose",
      request: request,
      callOptions: callOptions ?? self.defaultHTTPCallOptions
    )
  }
}

public protocol ConsensusClient_ConsensusClientAPIRestClientInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when invoking 'clientTxPropose'.
  func makeClientTxProposeInterceptors() -> [ClientInterceptor<Attest_Message, ConsensusCommon_ProposeTxResponse>]
}

public final class ConsensusClient_ConsensusClientAPIRestClient: ConsensusClient_ConsensusClientAPIRestClientProtocol {
  public var defaultHTTPCallOptions: HTTPCallOptions

  /// Creates a client for the consensus_client.ConsensusClientAPIRest service.
  ///
  /// - Parameters:
  ///   - channel: `HTTPChannel` to the service host.
  ///   - defaultHTTPCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    defaultHTTPCallOptions: HTTPCallOptions = HTTPCallOptions(),
    interceptors: ConsensusClient_ConsensusClientAPIRestClientInterceptorFactoryProtocol? = nil
  ) {
    self.defaultHTTPCallOptions = defaultHTTPCallOptions
  }
}

