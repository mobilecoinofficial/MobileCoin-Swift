//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: report.proto
//
//  swiftlint:disable all

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import NIO
import SwiftProtobuf
import LibMobileCoin


//// The public API for getting reports
///
/// Usage: instantiate `Report_ReportAPIRestClient`, then call methods of this protocol to make API calls.
public protocol Report_ReportAPIRestClientProtocol: HTTPClient {
  var serviceName: String { get }

  func getReports(
    _ request: Report_ReportRequest,
    callOptions: HTTPCallOptions?
  ) -> HTTPUnaryCall<Report_ReportRequest, Report_ReportResponse>
}

extension Report_ReportAPIRestClientProtocol {
  public var serviceName: String {
    return "report.ReportAPI"
  }

  //// Get all available pubkeys, with Intel SGX reports, fog urls, and expiry info
  ///
  /// - Parameters:
  ///   - request: Request to send to GetReports.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func getReports(
    _ request: Report_ReportRequest,
    callOptions: HTTPCallOptions? = nil
  ) -> HTTPUnaryCall<Report_ReportRequest, Report_ReportResponse> {
    return self.makeUnaryCall(
      path: "/report.ReportAPI/GetReports",
      request: request,
      callOptions: callOptions ?? self.defaultHTTPCallOptions
    )
  }
}

public final class Report_ReportAPIRestClient: Report_ReportAPIRestClientProtocol {
  public var defaultHTTPCallOptions: HTTPCallOptions

  /// Creates a client for the report.ReportAPI service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultHTTPCallOptions: Options to use for each service call if the user doesn't provide them.
  public init(
    defaultHTTPCallOptions: HTTPCallOptions = HTTPCallOptions()
  ) {
    self.defaultHTTPCallOptions = defaultHTTPCallOptions
  }
}

