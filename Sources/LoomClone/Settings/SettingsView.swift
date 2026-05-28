import SwiftUI

struct SettingsView: View {
    @ObservedObject var appState: AppState

    var body: some View {
        Form {
            Section("App") {
                LabeledContent("Mode", value: "Menubar first")
                LabeledContent("Storage", value: appState.storageMode)
                LabeledContent("Minimum macOS", value: appState.minimumSupportedMacOS)
            }

            Section("MVP modules") {
                LabeledContent("Screen", value: "Planned")
                LabeledContent("Camera", value: "Planned")
                LabeledContent("Microphone", value: "Planned")
                LabeledContent("Overlay", value: "Planned")
                LabeledContent("Export", value: "Planned")
            }
        }
        .formStyle(.grouped)
        .padding(24)
        .frame(width: 460)
    }
}
