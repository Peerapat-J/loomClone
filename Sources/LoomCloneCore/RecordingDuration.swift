import Foundation

public struct RecordingDuration: Equatable, Comparable {
    public let seconds: Int

    public init(seconds: Int) {
        self.seconds = max(0, seconds)
    }

    public var displayText: String {
        let hours = seconds / 3_600
        let minutes = (seconds % 3_600) / 60
        let remainingSeconds = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
        }

        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    public static func < (lhs: RecordingDuration, rhs: RecordingDuration) -> Bool {
        lhs.seconds < rhs.seconds
    }
}
