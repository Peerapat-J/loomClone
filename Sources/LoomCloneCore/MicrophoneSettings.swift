public struct MicrophoneSettings: Equatable {
    public var isEnabled = false
    public var selectedDeviceID: String?

    public init(isEnabled: Bool = false, selectedDeviceID: String? = nil) {
        self.isEnabled = isEnabled
        self.selectedDeviceID = selectedDeviceID
    }
}
