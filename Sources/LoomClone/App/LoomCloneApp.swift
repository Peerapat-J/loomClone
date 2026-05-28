import LoomCloneCore
import SwiftUI

@main
struct LoomCloneApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var appState = AppState()

    var body: some Scene {
        MenuBarExtra {
            MenuBarContentView(appState: appState)
        } label: {
            Label(appState.menuBarTitle, systemImage: appState.menuBarSystemImage)
        }
        .menuBarExtraStyle(.menu)

        Settings {}
    }
}
