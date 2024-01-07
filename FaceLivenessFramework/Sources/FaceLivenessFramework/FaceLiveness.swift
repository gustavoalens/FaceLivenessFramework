import AVFoundation
import CoreImage
import ARKit

/// FaceLiveness helps to evaluate if person on front device is moving to increase security of selfie validation
public final class FaceLiveness: NSObject, FaceLivenessProtocol {
    // MARK: - Properties
    weak var delegate: FaceLivenessDelegate?
    public let sceneView: ARSCNView = ARSCNView()
    
    // MARK: - Protocol Methods
    public func startLiveness(with delegate: FaceLivenessDelegate) async {
        self.delegate = delegate
        guard await isAuthorized() else { return } // TODO: Add error
        startSession(delegate: delegate)
    }
    
    public func getConfiguration() -> ARFaceTrackingConfiguration {
        let configuration = ARFaceTrackingConfiguration()
        configuration.maximumNumberOfTrackedFaces = 1
        configuration.isLightEstimationEnabled = true
        return configuration
    }
    
    public func stop() {
        sceneView.session.pause()
    }
    
    // MARK: - Private Methods
    private func startSession(delegate: FaceLivenessDelegate) {
        sceneView.delegate = self
        sceneView.session.run(getConfiguration(), options: [.resetTracking, .removeExistingAnchors])
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
}

extension FaceLiveness: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        print(faceAnchor)
    }
}

public protocol FaceLivenessDelegate: AnyObject {
    func didDetect(detected: Bool)
}

public protocol FaceLivenessProtocol {
    func startLiveness(with delegate: FaceLivenessDelegate) async
    func getConfiguration() -> ARFaceTrackingConfiguration
    func stop()
}

enum FaceLivenessError {
    case unauthorized
}

enum LivenessValidations {
    case blink
    case smile
    case verticalMovement
    case horizontalMovement
}
