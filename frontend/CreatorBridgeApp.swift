import SwiftUI

/// App entry point - use this when running the package standalone.
/// When used as a library, the host app (e.g. creator-bridge) provides its own @main.
struct CreatorBridgeApp: App {
    @StateObject private var session = SessionManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(session)
        }
    }
}

