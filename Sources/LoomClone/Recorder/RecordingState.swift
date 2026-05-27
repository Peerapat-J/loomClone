enum RecordingState: String, CaseIterable, Identifiable {
    case idle
    case recording
    case paused

    var id: String {
        rawValue
    }

    var displayName: String {
        switch self {
        case .idle:
            "Idle"
        case .recording:
            "Recording"
        case .paused:
            "Paused"
        }
    }
}
