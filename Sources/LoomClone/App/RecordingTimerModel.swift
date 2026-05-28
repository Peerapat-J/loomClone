import Foundation
import LoomCloneCore

@MainActor
final class RecordingTimerModel: ObservableObject {
    @Published private(set) var elapsedDuration = RecordingDuration(seconds: 0)

    private var timerTask: Task<Void, Never>?

    deinit {
        timerTask?.cancel()
    }

    var elapsedTimeText: String {
        elapsedDuration.displayText
    }

    func start() {
        stop()
        timerTask = Task { @MainActor [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))

                guard let self, !Task.isCancelled else {
                    continue
                }

                elapsedDuration = RecordingDuration(seconds: elapsedDuration.seconds + 1)
            }
        }
    }

    func pause() {
        stop()
    }

    func reset() {
        elapsedDuration = RecordingDuration(seconds: 0)
    }

    private func stop() {
        timerTask?.cancel()
        timerTask = nil
    }
}
