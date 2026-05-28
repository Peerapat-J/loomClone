import LoomCloneCore
import SwiftUI

struct FloatingControlBarView: View {
    private let cornerRadius: CGFloat = 14

    @ObservedObject var appState: AppState
    @ObservedObject var recordingTimer: RecordingTimerModel

    var body: some View {
        HStack(spacing: 10) {
            Label(appState.recordingState.displayName, systemImage: statusSystemImage)
                .labelStyle(.titleAndIcon)
                .font(.body.weight(.semibold))
                .imageScale(.medium)
                .frame(width: 128, alignment: .leading)

            Text(recordingTimer.elapsedTimeText)
                .font(.system(.body, design: .monospaced).weight(.medium))
                .monospacedDigit()
                .frame(width: 64, alignment: .trailing)

            Divider()
                .frame(height: 24)

            if appState.recordingState == .paused {
                controlButton(title: "Resume", systemImage: "play.fill") {
                    appState.resumeRecording()
                }
            } else {
                controlButton(title: "Pause", systemImage: "pause.fill") {
                    appState.pauseRecording()
                }
                .disabled(!appState.isCommandEnabled(.pause))
            }

            controlButton(title: "Stop", systemImage: "stop.fill") {
                appState.stopRecording()
            }
            .disabled(!appState.isCommandEnabled(.stop))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(width: 336, height: 52)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(.quaternary, lineWidth: 1)
        }
    }

    private var statusSystemImage: String {
        switch appState.recordingState {
        case .idle:
            "record.circle"
        case .recording:
            "record.circle.fill"
        case .paused:
            "pause.circle.fill"
        }
    }

    private func controlButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 17, weight: .semibold))
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.borderless)
        .help(title)
    }
}
