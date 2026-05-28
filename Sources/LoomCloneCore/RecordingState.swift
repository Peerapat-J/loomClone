public enum RecordingState: String, CaseIterable, Identifiable {
    case idle
    case recording
    case paused

    public var id: String {
        rawValue
    }

    public var displayName: String {
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
