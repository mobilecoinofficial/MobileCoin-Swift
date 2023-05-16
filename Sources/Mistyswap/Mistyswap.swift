//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
// swiftlint:disable closure_body_length multiline_function_chains

import Foundation
import LibMobileCoin

struct Mistyswap: MistyswapService & MistyswapUntrustedService {
    private let mistyswap: MistyswapService
    private let mistyswapUntrusted: MistyswapUntrustedService

    init(
        mistyswap: MistyswapService,
        mistyswapUntrusted: MistyswapUntrustedService
    ) {
        self.mistyswap = mistyswap
        self.mistyswapUntrusted = mistyswapUntrusted
    }
    
    func initiateOfframp(
        request: Mistyswap_InitiateOfframpRequest,
        completion: @escaping (Result<Mistyswap_InitiateOfframpResponse, ConnectionError>
    ) -> Void) {
        mistyswap.initiateOfframp(request: request, completion: completion)
    }
    
    func getOfframpStatus(
        request: Mistyswap_GetOfframpStatusRequest,
        completion: @escaping (Result<Mistyswap_GetOfframpStatusResponse, ConnectionError>
    ) -> Void) {
        mistyswap.getOfframpStatus(request: request, completion: completion)
    }
    
    func forgetOfframp(
        request: Mistyswap_ForgetOfframpRequest,
        completion: @escaping (Result<Mistyswap_ForgetOfframpResponse, ConnectionError>
    ) -> Void) {
        mistyswapUntrusted.forgetOfframp(request: request, completion: completion)
    }
}
