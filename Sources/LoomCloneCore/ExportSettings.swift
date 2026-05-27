public enum ExportFormat: String, CaseIterable, Identifiable {
    case mov
    case mp4

    public var id: String {
        rawValue
    }
}

public struct ExportSettings: Equatable {
    public var preferredFormat: ExportFormat = .mov
    public var shouldRevealAfterExport = true
}
