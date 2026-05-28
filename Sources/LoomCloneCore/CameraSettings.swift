public struct CameraSettings: Equatable {
    public var isEnabled = false
    public var prefersCircularOverlay = true

    public init(isEnabled: Bool = false, prefersCircularOverlay: Bool = true) {
        self.isEnabled = isEnabled
        self.prefersCircularOverlay = prefersCircularOverlay
    }
}
