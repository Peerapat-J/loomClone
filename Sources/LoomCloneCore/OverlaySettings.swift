public struct OverlaySettings: Equatable {
    public var isCursorHighlightEnabled = false
    public var isPrivacyMaskEnabled = false
    public var isPenAnnotationEnabled = false

    public init(
        isCursorHighlightEnabled: Bool = false,
        isPrivacyMaskEnabled: Bool = false,
        isPenAnnotationEnabled: Bool = false
    ) {
        self.isCursorHighlightEnabled = isCursorHighlightEnabled
        self.isPrivacyMaskEnabled = isPrivacyMaskEnabled
        self.isPenAnnotationEnabled = isPenAnnotationEnabled
    }
}
