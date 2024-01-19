import ARKit

/// FaceLiveness helps to evaluate if person on front device is moving to increase security of selfie validation
public final class FaceLiveness: NSObject, FaceLivenessProtocol {
    // MARK: - Properties
    weak var delegate: FaceLivenessDelegate?
    public let sceneView: ARSCNView = ARSCNView()
    private var validations: [LivenessValidation] = []
    private var validateds: Set<LivenessValidation> = Set()
    private var currentValidation: LivenessValidation? { validations.first }
    
    // MARK: - Protocol Methods
    public func startLiveness(validations: [LivenessValidation], with delegate: FaceLivenessDelegate) async {
        self.delegate = delegate
        guard await isAuthorized() else { return } // TODO: Add error
        startSession(delegate: delegate)
    }
    
    public func stop() {
        sceneView.session.pause()
    }
    
    // MARK: - Private Methods
    private func startSession(delegate: FaceLivenessDelegate) {
        sceneView.delegate = self
        sceneView.session.run(getConfiguration(), options: [.resetTracking, .removeExistingAnchors])
        
        
    }
    
    private func getConfiguration() -> ARFaceTrackingConfiguration {
        let configuration = ARFaceTrackingConfiguration()
        configuration.maximumNumberOfTrackedFaces = 1
        configuration.isLightEstimationEnabled = true
        return configuration
    }
    
    
    
    private func getRotations(fromMatrix matrix: matrix_float4x4) -> FaceRotation {
        // Get quaternions
        // http://www.euclideanspace.com/maths/geometry/rotations/conversions/matrixToQuaternion/index.htm
        let qw = sqrt(1 + matrix.columns.0.x + matrix.columns.1.y + matrix.columns.2.z) / 2.0
        let qx = (matrix.columns.2.y - matrix.columns.1.z) / (qw * 4.0)
        let qy = (matrix.columns.0.z - matrix.columns.2.x) / (qw * 4.0)
        let qz = (matrix.columns.1.x - matrix.columns.0.y) / (qw * 4.0)
        
        // Deduce euler angles with some cosines
        // https://en.wikipedia.org/wiki/Conversion_between_quaternions_and_Euler_angles
        /// yaw (z-axis rotation)
        let siny = 2.0 * (qw * qz + qx * qy)
        let cosy = 1.0 - 2.0 * (qy * qy + qz * qz)
        let yaw = matrix.radiansToDegress(radians: atan2(siny, cosy))
        // pitch (y-axis rotation)
        let sinp = 2.0 * (qw * qy - qz * qx)
        var pitch: Float
        if abs(sinp) >= 1 {
            pitch = matrix.radiansToDegress(radians: copysign(Float.pi / 2, sinp))
        } else {
            pitch = matrix.radiansToDegress(radians: asin(sinp))
        }
        /// roll (x-axis rotation)
        let sinr = +2.0 * (qw * qx + qy * qz)
        let cosr = +1.0 - 2.0 * (qx * qx + qy * qy)
        let roll = matrix.radiansToDegress(radians: atan2(sinr, cosr))
        
        /// return array containing ypr values
        return FaceRotation(fromXAxis: roll, fromYAxis: pitch, fromZAxis: yaw)
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
        
        // TODO: Next Steps:
        // add combine to get an array of anchors and calculate delta to can regonize the facial expression or movement
        // pop first to set of validates
        // update delegate to know and can show new orientations to user
        // if array is empty, thats finished
        // send to delegate and finished flow
        // function of validation need received the data in a protocol to unit tests
        print("----------------rotations----------------")
        print(getRotations(fromMatrix: faceAnchor.transform))
        print("----------------eyes-blink----------------")
        print("blink left: \(faceAnchor.blendShapes[.eyeBlinkLeft])")
        print("blink right: \(faceAnchor.blendShapes[.eyeBlinkRight])")
        print("----------------smile----------------")
        print("mouthSmileLeft: \(faceAnchor.blendShapes[.mouthSmileLeft])")
        print("mouthSmileRight: \(faceAnchor.blendShapes[.mouthSmileRight])")
        print("--------------------------------")
        
        
    }
}

extension FaceLiveness: ARSCNViewDelegate {
    public func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        recognizeAction(faceAnchor: faceAnchor)
    }
}

public protocol FaceLivenessDelegate: AnyObject {
    func didDetect(detected: Bool)
}

public protocol FaceLivenessProtocol {
    func startLiveness(validations: [LivenessValidation], with delegate: FaceLivenessDelegate) async
    func stop()
}

enum FaceLivenessError {
    case unauthorized
}

public enum LivenessValidation {
    case blink
    case smile
    case verticalMovement
    case horizontalMovement
}

struct FaceRotation {
    let fromXAxis: Float
    let fromYAxis: Float
    let fromZAxis: Float
}
