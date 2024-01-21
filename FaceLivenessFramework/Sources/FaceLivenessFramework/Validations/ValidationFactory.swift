final class ValidationFactory {
    static func getRecognizer(for type: LivenessValidation) -> FaceRecognizerProtocol {
        switch type {
            case .blink: return BlinkRecognizer()
            case .smile: return SmileRecognizer()
            case .verticalMovement: return FaceVerticalMovementRecognizer()
            case .horizontalMovement: return FaceHorizontalMovementRecognizer()
        }
    }
}
