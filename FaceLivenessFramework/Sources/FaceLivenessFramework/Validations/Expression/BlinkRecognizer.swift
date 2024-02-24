import ARKit
import Combine

final class BlinkRecognizer: FaceExpressionRecognizerProtocol {
    // MARK: - Properties
    let shapeType: Set<ARFaceAnchor.BlendShapeLocation> = [.eyeBlinkLeft, .eyeBlinkRight]
    private var subscriptions: Set<AnyCancellable> = Set()
    private let controlPublisher: PassthroughSubject<FaceAnchorChange, Never> = PassthroughSubject<FaceAnchorChange, Never>()
    
    private let queue: DispatchQueue = .init(label: String(describing: BlinkRecognizer.self), qos: .userInteractive)
    @Published private var result: Bool = false
    
    func start() {
        setupPublisher()
    }
    
    func stop() {
        // TODO: implement
    }
    
    func didChanged(variations: FaceAnchorChange) {
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
            .sink { [weak self] partialResult in
                let variationsByShape = partialResult.reduce([ARFaceAnchor.BlendShapeLocation: [Float]](), { partial, changes in
                    var new = partial // TODO: get only min and max
                    changes.forEach { changes in
                        new.add(onKey: changes.key, value: Float(truncating: changes.value ?? 0.0))
                    }
                    return new
                })
                self?.checkVariation(variationsByShape: variationsByShape)
            }
            .store(in: &subscriptions)
    }
    
    private func checkVariation(variationsByShape: [ARFaceAnchor.BlendShapeLocation: [Float]]) {
        let didBlink = shapeType.allSatisfy { type in
            guard let variation = variationsByShape[type] else {
                return false
            } // TODO: Send error result?
            print("\(type) - \(variation)")
            return isBlink(variation: variation)
        }
        if didBlink {
            DispatchQueue.main.async {
                self.result = true
            }
        }
    }
    
    private func isBlink(variation: [Float]) -> Bool {
        guard let max = variation.max(), let min = variation.min() else { return false }
        return max >= 0.85 && min <= 0.3
    }
}

typealias FaceAnchorChange = [ARFaceAnchor.BlendShapeLocation: NSNumber?]
