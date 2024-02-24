import ARKit

/// FaceLiveness helps to evaluate if person on front device is moving to increase security of selfie validation
public final class FaceLiveness: NSObject, FaceLivenessProtocol {
    // MARK: - Properties
    public let sceneView: ARSCNView = ARSCNView()
    private var validations: [LivenessValidation] = []
    private var validateds: Set<LivenessValidation> = Set()
    private var currentValidation: FaceRecognizerProtocol?
    @Published private var result: ValidationResult?
    
    // MARK: - Protocol Methods
    public func startLiveness(validations: [LivenessValidation]) async -> ValidationResult {
        guard await isAuthorized() else { return .unauthorized }
        self.validations = validations
        startSession()
        return (try? await $result.async()) ?? .invalid
    }
    
    public func stop() {
        sceneView.session.pause()
    }
    
    // MARK: - Private Methods
    private func startSession() {
        sceneView.delegate = self
        sceneView.session.run(getConfiguration(), options: [.resetTracking, .removeExistingAnchors])
        Task {
            await nextValidation()
        }
    }
    
    private func getConfiguration() -> ARFaceTrackingConfiguration {
        let configuration = ARFaceTrackingConfiguration()
        configuration.maximumNumberOfTrackedFaces = 1
        configuration.isLightEstimationEnabled = true
        return configuration
    }
    
    private func nextValidation() async {
        guard !validations.isEmpty else {
            result = .valid
            return
        }
        
        let newValidation = validations.removeFirst()
        let recognizer = ValidationFactory.getRecognizer(for: newValidation)
        recognizer.start()
        currentValidation = recognizer
        if await recognizer.recognized() {
            await nextValidation()
        }
//        ValidationChange.changed(to: newValidation) // TODO: send to caller the change to show orientations to user
    }
    
    // MARK: - Validation Methods
    private func isAuthorized() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                return await AVCaptureDevice.requestAccess(for: .video)
            case .restricted, .denied:
                return false
            case .authorized:
                return true
            @unknown default:
                return false
        }
    }
    
    deinit {
        stop()
    }
    
    fileprivate func recognizeAction(faceAnchor: ARFaceAnchor) {
        guard let currentValidation else { return }
        currentValidation.didChanged(faceAnchor: faceAnchor)
    }
}

extension FaceLiveness: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        recognizeAction(faceAnchor: faceAnchor)
    }
}

public protocol FaceLivenessProtocol {
    func startLiveness(validations: [LivenessValidation]) async -> ValidationResult
    func stop()
}

// TODO: Add delegate to handle with validations changes to show to user? Or completion?
