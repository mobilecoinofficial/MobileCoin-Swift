//
//  Copyright (c) 2020-2023 MobileCoin. All rights reserved.
//

// In SPM the target is a library linked into the unified test runner, whose
// own entry point collides with @main; only the xcodeproj builds the real app.
#if !SPM_BUILD
import SwiftUI

@available(iOS 14.0, *)
@main
struct TestSetupClientApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
#endif
