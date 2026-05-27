enum AppPermission: String, CaseIterable, Identifiable {
    case screenRecording
    case camera
    case microphone

    var id: String {
        rawValue
    }

    var displayName: String {
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

enum PermissionState: String {
    case unknown
    case notDetermined
    case granted
    case denied
}
