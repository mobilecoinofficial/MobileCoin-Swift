//
//  Copyright (c) 2020-2021 MobileCoin. All rights reserved.
//

import UIKit
import MobileCoin

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let status = TransactionStatus.failed
        print(status)
        // Override point for customization after application launch.
        return true
    }

}
