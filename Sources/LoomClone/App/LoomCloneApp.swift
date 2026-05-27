import LoomCloneCore
import SwiftUI

@main
struct LoomCloneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra(AppConfiguration.appName, systemImage: "record.circle") {
            MenuBarContentView(appState: appState)
        }
        .menuBarExtraStyle(.menu)

        Settings {
            SettingsView(appState: appState)
        }
    }
}
