//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import Foundation
import LibMobileCoin

final class FogKeyImageHttpConnection: ConnectionProtocol, FogKeyImageService {
    func checkKeyImages(
        request: FogLedger_CheckKeyImagesRequest,
        completion: @escaping (Result<FogLedger_CheckKeyImagesResponse, ConnectionError>) -> Void
    ) {
    }
}
