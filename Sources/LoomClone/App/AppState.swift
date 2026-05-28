import Combine
import Foundation
import LoomCloneCore

@MainActor
final class AppState: ObservableObject {
    @Published var recordingState: RecordingState = .idle

    let productName = AppConfiguration.appName
    let minimumSupportedMacOS = AppConfiguration.minimumMacOSVersion
    let storageMode = AppConfiguration.storageMode
}
