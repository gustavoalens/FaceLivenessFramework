import ARKit
import Combine

final class SmileRecognizer: FaceExpressionRecognizerProtocol {
    let shapeType: Set<ARFaceAnchor.BlendShapeLocation> = [.mouthSmileLeft, .mouthSmileRight]
    private var subscriptions: Set<AnyCancellable> = Set()
    private let controlPublisher: PassthroughSubject<FaceAnchorChange, Never> = PassthroughSubject<FaceAnchorChange, Never>()
    
    private let queue: DispatchQueue = .init(label: String(describing: SmileRecognizer.self))
    @Published private var result: Bool = false
    
    func start() {
        setupPublisher()
    }
    
    func stop() {
        // TODO: implement
    }
    
    func didChanged(variations: [ARFaceAnchor.BlendShapeLocation : NSNumber?]) {
        controlPublisher.send(variations)
    }
    
    func recognized() async -> Bool {
        start()
        let result = (try? await $result.async()) ?? false
        stop()
        return result
    }
    
    // MARK: - Methods
    private func setupPublisher() {
        controlPublisher
            .collect(.byTime(DispatchQueue.main, .seconds(1)))
            .receive(on: queue)
            .reduce([ARFaceAnchor.BlendShapeLocation: [NSNumber]](), { partial, changes in
                var new = partial
                changes.forEach { changes in
                    changes.forEach { dictChange in
                        new.add(onKey: dictChange.key, value: dictChange.value)
                    }
                }
                return new
            })
            .sink { [weak self] variationsByShape in
                self?.checkVariation(variationsByShape: variationsByShape)
            }
            .store(in: &subscriptions)
    }
    
    private func checkVariation(variationsByShape: [ARFaceAnchor.BlendShapeLocation: [NSNumber]]) {
        let didBlink = shapeType.allSatisfy { type in
            guard let variation = variationsByShape[type] else { return false } // TODO: Send error result?
            return isSmile(variation: variation)
        }
        if didBlink {
            result = true
        }
    }
    
    private func isSmile(variation: [NSNumber]) -> Bool {
        return false
    }
}

