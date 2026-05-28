import AppKit
import SwiftUI

@MainActor
final class FloatingControlPanelController {
    private var panel: NSPanel?

    func update(for appState: AppState) {
        if appState.shouldShowFloatingControlBar {
            show(appState: appState)
        } else {
            hide()
        }
    }

    private func show(appState: AppState) {
        if panel == nil {
            panel = makePanel(appState: appState)
        }

        panel?.orderFrontRegardless()
    }

    private func hide() {
        panel?.orderOut(nil)
    }

    private func makePanel(appState: AppState) -> NSPanel {
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 336, height: 52),
            styleMask: [.nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.title = "Recording Controls"
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.hidesOnDeactivate = false
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        let hostingView = NSHostingView(
            rootView: FloatingControlBarView(
                appState: appState,
                recordingTimer: appState.recordingTimer
            )
        )
        hostingView.wantsLayer = true
        hostingView.layer?.cornerRadius = 14
        hostingView.layer?.cornerCurve = .continuous
        hostingView.layer?.masksToBounds = true
        panel.contentView = hostingView

        position(panel)
        return panel
    }

    private func position(_ panel: NSPanel) {
        guard let screen = NSScreen.main else {
            return
        }

        let visibleFrame = screen.visibleFrame
        let panelSize = panel.frame.size
        let origin = NSPoint(
            x: visibleFrame.midX - (panelSize.width / 2),
            y: visibleFrame.maxY - panelSize.height - 24
        )

        panel.setFrameOrigin(origin)
    }
}
