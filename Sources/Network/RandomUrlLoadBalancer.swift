//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

//protocol UrlLoadBalancer {
//    associatedtype AnyScheme: Scheme
//    func getNextUrl() -> MobileCoinUrl<AnyScheme>
//}


class RandomUrlLoadBalancer<Url: MobileCoinUrlProtocol> {
    var rng = SystemRandomNumberGenerator()

    let urlsTyped: [Url]
    private(set) var currentUrl: Url?
    
    init(urls: [Url]) throws {
        guard !urls.isEmpty else {
            throw InvalidInputError("urls array must not be empty")
        }
        self.urlsTyped = urls
        _ = nextUrl()
    }
    
    func nextUrl() -> Url? {
        currentUrl =  urlsTyped.randomElement(using:&rng)
        return currentUrl
    }
}
