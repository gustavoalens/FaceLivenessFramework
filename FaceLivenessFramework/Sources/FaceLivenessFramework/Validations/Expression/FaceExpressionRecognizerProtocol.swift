import ARKit

protocol FaceExpressionRecognizerProtocol: FaceRecognizerProtocol {
    var shapeType: Set<ARFaceAnchor.BlendShapeLocation> { get }
    func didChanged(variations: [ARFaceAnchor.BlendShapeLocation : NSNumber?])
}

extension FaceExpressionRecognizerProtocol {
    func didChanged(faceAnchor: ARFaceAnchor) {
        let keyPairArray = shapeType.compactMap { shapeType in
            return (shapeType, faceAnchor.blendShapes[shapeType])
        }
        didChanged(variations: Dictionary(uniqueKeysWithValues: keyPairArray))
    }
}
