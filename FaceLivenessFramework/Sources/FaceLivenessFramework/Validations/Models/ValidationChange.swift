public enum ValidationChange {
    case timeoutRecognization
    case noFaceFounded
    case changed(to: LivenessValidation)
}
