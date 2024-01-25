import ARKit

final class SmileRecognizer: FaceExpressionRecognizerProtocol {
    let shapeType: Set<ARFaceAnchor.BlendShapeLocation> = [.mouthSmileLeft, .mouthSmileRight]
    
    func start() {
        // TODO: implement
    }
    
    func stop() {
        // TODO: implement
    }
    
    func didChanged(variations: [ARFaceAnchor.BlendShapeLocation : NSNumber?]) {
        // TODO: implement
    }
    
    func recognized() async -> Bool {
        // TODO: implement
        return false
    }
}
