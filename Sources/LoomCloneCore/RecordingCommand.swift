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
            state.canStartRecording
        case .pause:
            state.canPauseRecording
        case .resume:
            state.canResumeRecording
        case .stop:
            state.canStopRecording
        case .openLastRecording:
            state.canOpenLastRecording(hasLastRecording: hasLastRecording)
        }
    }
}

public extension RecordingState {
    var isIdle: Bool {
        self == .idle
    }

    var isRecording: Bool {
        self == .recording
    }

    var isPaused: Bool {
        self == .paused
    }

    var canStartRecording: Bool {
        isIdle
    }

    var canPauseRecording: Bool {
        isRecording
    }

    var canResumeRecording: Bool {
        isPaused
    }

    var canStopRecording: Bool {
        isRecording || isPaused
    }

    func canOpenLastRecording(hasLastRecording: Bool) -> Bool {
        isIdle && hasLastRecording
    }
}
