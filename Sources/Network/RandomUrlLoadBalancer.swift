//
//  Copyright (c) 2020-2022 MobileCoin. All rights reserved.
//

class RandomUrlLoadBalancer<ServiceUrl: MobileCoinUrlProtocol> {

    static func make(urls: [ServiceUrl]) -> Result<RandomUrlLoadBalancer, InvalidInputError> {
        guard urls.isNotEmpty else {
            return .failure(InvalidInputError("url list cannot be empty"))
        }
        return .success(RandomUrlLoadBalancer(urls:urls))
    }

    private var rng = SystemRandomNumberGenerator()
    private let urlsTyped: [ServiceUrl]
    private(set) var currentUrl: ServiceUrl

    var urlsDescription: String {
        "\(urlsTyped)"
    }

    private init(urls: [ServiceUrl]) {
        self.urlsTyped = urls

        guard let nextUrl = urlsTyped.randomElement(using: &rng) else {
            // This condition should never happen
            logger.fatalError(
                "unable to get nextUrl() from RandomUrlLoadBalancer")
        }
        currentUrl = nextUrl
    }

    func nextUrl() -> ServiceUrl {
        guard urlsTyped.count > 1 else {
            return currentUrl
        }

        var nextUrl: ServiceUrl
        repeat {
            guard let url = urlsTyped.randomElement(using: &rng) else {
                // This condition should never happen
                logger.fatalError(
                    "unable to get nextUrl() from RandomUrlLoadBalancer")
            }
            nextUrl = url
        }
        while currentUrl.url == nextUrl.url

        currentUrl = nextUrl
        return currentUrl
    }

}
