import AppKit
import SwiftUI

struct MenuBarContentView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        Text(appState.productName)
            .font(.headline)

        Text("Status: \(appState.recordingState.displayName)")

        Divider()

        SettingsLink {
            Text("Settings...")
        }

        Button("Quit \(appState.productName)") {
            NSApplication.shared.terminate(nil)
        }
    }
}
