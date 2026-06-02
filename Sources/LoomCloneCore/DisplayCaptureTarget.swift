public struct DisplayCaptureFrame: Equatable, Sendable {
    public let x: Int
    public let y: Int
    public let width: Int
    public let height: Int

    public init(x: Int, y: Int, width: Int, height: Int) {
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}

public struct DisplayCaptureTarget: Equatable, Identifiable, Sendable {
    public let id: UInt32
    public let name: String
    public let width: Int
    public let height: Int
    public let frame: DisplayCaptureFrame
    public let isMain: Bool

    public init(
        id: UInt32,
        name: String? = nil,
        width: Int,
        height: Int,
        frame: DisplayCaptureFrame,
        isMain: Bool = false
    ) {
        self.id = id
        self.name = Self.normalizedName(name, id: id, isMain: isMain)
        self.width = width
        self.height = height
        self.frame = frame
        self.isMain = isMain
    }

    public var dimensionsText: String {
        "\(width) x \(height)"
    }

    public var menuTitle: String {
        "\(name) (\(dimensionsText))"
    }

    public var isUsable: Bool {
        width > 0 && height > 0
    }

    public static func sortedForDisplayPicker(_ displays: [DisplayCaptureTarget]) -> [DisplayCaptureTarget] {
        displays
            .filter(\.isUsable)
            .sorted { lhs, rhs in
                if lhs.isMain != rhs.isMain {
                    return lhs.isMain
                }

                if lhs.frame.x != rhs.frame.x {
                    return lhs.frame.x < rhs.frame.x
                }

                if lhs.frame.y != rhs.frame.y {
                    return lhs.frame.y < rhs.frame.y
                }

                return lhs.id < rhs.id
            }
    }

    public static func preferredSelectionID(
        in displays: [DisplayCaptureTarget],
        currentSelectionID: UInt32?
    ) -> UInt32? {
        if let currentSelectionID,
           displays.contains(where: { $0.id == currentSelectionID }) {
            return currentSelectionID
        }

        return displays.first(where: \.isMain)?.id ?? displays.first?.id
    }

    private static func normalizedName(_ name: String?, id: UInt32, isMain: Bool) -> String {
        guard let name = name?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty else {
            return isMain ? "Main Display" : "Display \(id)"
        }

        return name
    }
}

public enum DisplayDetectionState: Equatable, Sendable {
    case unknown
    case loading
    case available
    case unavailable
    case failed(String)

    public var displayName: String {
        switch self {
        case .unknown:
            "Displays: Unknown"
        case .loading:
            "Displays: Checking"
        case .available:
            "Displays: Ready"
        case .unavailable:
            "Displays: None Found"
        case .failed:
            "Displays: Failed"
        }
    }
}
