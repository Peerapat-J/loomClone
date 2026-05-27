enum ExportFormat: String, CaseIterable, Identifiable {
    case mov
    case mp4

    var id: String {
        rawValue
    }
}

struct ExportSettings: Equatable {
    var preferredFormat: ExportFormat = .mov
    var shouldRevealAfterExport = true
}
