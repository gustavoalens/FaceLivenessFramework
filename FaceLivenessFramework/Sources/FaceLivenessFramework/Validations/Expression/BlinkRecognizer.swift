import ARKit

final class BlinkRecognizer: FaceExpressionRecognizerProtocol {
    let shapeType: Set<ARFaceAnchor.BlendShapeLocation> = [.eyeBlinkLeft, .eyeBlinkRight]
    
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
