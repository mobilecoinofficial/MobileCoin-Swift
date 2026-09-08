//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//
import Foundation

// `URLAuthenticationChallenge` demands a sender.
final class NullChallengeSender: NSObject, URLAuthenticationChallengeSender {
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {}
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {}
    func cancel(_ challenge: URLAuthenticationChallenge) {}
}
