import AVFoundation
import CoreImage
import ARKit

public final class FaceLiveness: NSObject, FaceLivenessProtocol {
    weak var delegate: FaceLivenessDelegate?
    public let sceneView: ARSCNView = ARSCNView()
    
    public func startLiveness(with delegate: FaceLivenessDelegate) async {
        self.delegate = delegate
        guard await isAuthorized() else { return } // TODO: Add error
        prepareSession(delegate: delegate)
    }
    
    public func stop() {
        sceneView.session.pause()
    }
    
    private func prepareSession(delegate: FaceLivenessDelegate) {
        let configuration = ARFaceTrackingConfiguration()
        configuration.maximumNumberOfTrackedFaces = 1
        configuration.isLightEstimationEnabled = true
        // Run the view's session
        sceneView.delegate = self
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
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
