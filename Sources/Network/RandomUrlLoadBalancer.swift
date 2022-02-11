//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//


class RandomUrlLoadBalancer<ServiceUrl: MobileCoinUrlProtocol> {

    static func make(urls: [ServiceUrl]) -> Result<RandomUrlLoadBalancer, InvalidInputError> {
        guard urls.isNotEmpty else {
            return .failure(InvalidInputError("url list cannot be empty"))
        }
        return .success(RandomUrlLoadBalancer.init(urls:urls))
    }

    var rng = SystemRandomNumberGenerator()
    let urlsTyped: [ServiceUrl]

    private init(urls: [ServiceUrl]) {
        self.urlsTyped = urls
    }
    
    func nextUrl() -> ServiceUrl {
        guard let nextUrl = urlsTyped.randomElement(using:&rng) else {
            // This condition should never happen
            logger.fatalError(
                "unable to get nextUrl() from RandomUrlLoadBalancer")
        }
        return nextUrl
    }
}
