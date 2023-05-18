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

public struct MistyswapConstants {
    /// Mixin asset ids we care about - these are fetched by querying https://mtgswap-api.fox.one/api/assets
//    pub const MIXIN_ASSET_ID_MOB: AssetId = AssetId(uuid!("eea900a8-b327-488c-8d8d-1428702fe240"));
//    pub const MIXIN_ASSET_ID_EUSD: AssetId = AssetId(uuid!("659c407a-0489-30bf-9e6f-84ef25c971c9"));
//    pub const MIXIN_ASSET_ID_USDC: AssetId = AssetId(uuid!("9b180ab6-6abe-3dc0-a13f-04169eb34bfa"));
//    pub const MIXIN_ASSET_ID_ETH: AssetId = AssetId(uuid!("43d61dcd-e413-450d-80b8-101d5e903357"));
//    pub const MIXIN_ASSET_ID_MATIC: AssetId = AssetId(uuid!("b7938396-3f94-4e0a-9179-d3440718156f"));
//    pub const MIXIN_ASSET_ID_USDC_POLYGON: AssetId =
//        AssetId(uuid!("80b65786-7c75-3523-bc03-fb25378eae41"));
//    pub const MIXIN_ASSET_ID_TRX_TRON: AssetId = AssetId(uuid!("25dabac5-056a-48ff-b9f9-f67395dc407c"));
//    pub const MIXIN_ASSET_ID_USDT_TRON: AssetId =
//        AssetId(uuid!("b91e18ff-a9ae-3dc7-8679-e935d9a4b34b"));
}
