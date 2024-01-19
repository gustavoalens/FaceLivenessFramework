import ARKit

protocol FaceRecognizerProtocol {
    func start()
    func stop()
    func didChanged(faceAnchor: ARFaceAnchor)
    func recognized() async -> Bool
}
