import ARKit

protocol FaceExpressionRecognizerProtocol: FaceRecognizerProtocol {
    var shapeType: ARFaceAnchor.BlendShapeLocation { get }
    func didChanged(variation: NSNumber?)
}

extension FaceExpressionRecognizerProtocol {
    func didChanged(faceAnchor: ARFaceAnchor) {
        didChanged(variation: faceAnchor.blendShapes[shapeType])
    }
}
