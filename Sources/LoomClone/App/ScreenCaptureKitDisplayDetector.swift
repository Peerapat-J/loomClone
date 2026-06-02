import AppKit
import CoreGraphics
import Foundation
import LoomCloneCore
import ScreenCaptureKit

protocol DisplayCaptureDetecting: Sendable {
    func availableDisplays() async throws -> [DisplayCaptureTarget]
}

struct ScreenCaptureKitDisplayDetector: DisplayCaptureDetecting {
    func availableDisplays() async throws -> [DisplayCaptureTarget] {
        let content = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        let targets = content.displays.map(DisplayCaptureTarget.init(screenCaptureDisplay:))
        return DisplayCaptureTarget.sortedForDisplayPicker(targets)
    }
}

private extension DisplayCaptureTarget {
    init(screenCaptureDisplay display: SCDisplay) {
        let frame = display.frame
        let displayID = display.displayID
        let isMain = CGDisplayIsMain(displayID) != 0

        self.init(
            id: displayID,
            name: Self.localizedDisplayName(for: displayID),
            width: display.width,
            height: display.height,
            frame: DisplayCaptureFrame(
                x: Int(frame.origin.x.rounded()),
                y: Int(frame.origin.y.rounded()),
                width: Int(frame.width.rounded()),
                height: Int(frame.height.rounded())
            ),
            isMain: isMain
        )
    }

    private static func localizedDisplayName(for displayID: CGDirectDisplayID) -> String? {
        NSScreen.screens.first { screen in
            guard let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
                return false
            }

            return screenNumber.uint32Value == displayID
        }?.localizedName
    }
}
