public enum RecordingCommand: String, CaseIterable, Identifiable {
    case start
    case pause
    case resume
    case stop
    case openLastRecording

    public var id: String {
        rawValue
    }

    public var displayName: String {
        switch self {
        case .start:
            "Start Recording"
        case .pause:
            "Pause"
        case .resume:
            "Resume"
        case .stop:
            "Stop"
        case .openLastRecording:
            "Open Last Recording"
        }
    }

    public func isEnabled(in state: RecordingState, hasLastRecording: Bool = false) -> Bool {
        switch self {
        case .start:
            state == .idle
        case .pause:
            state == .recording
        case .resume:
            state == .paused
        case .stop:
            state == .recording || state == .paused
        case .openLastRecording:
            state == .idle && hasLastRecording
        }
    }
}

public extension RecordingState {
    var canStartRecording: Bool {
        self == .idle
    }

    var canPauseRecording: Bool {
        self == .recording
    }

    var canResumeRecording: Bool {
        self == .paused
    }

    var canStopRecording: Bool {
        self == .recording || self == .paused
    }
}
