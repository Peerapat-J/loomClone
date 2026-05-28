public enum AppPermission: String, CaseIterable, Identifiable {
    case screenRecording
    case camera
    case microphone

    public var id: String {
        rawValue
    }

    public var displayName: String {
        switch self {
        case .screenRecording:
            "Screen Recording"
        case .camera:
            "Camera"
        case .microphone:
            "Microphone"
        }
    }
}

public enum PermissionState: String {
    case unknown
    case notDetermined
    case granted
    case denied
}
