import Foundation
import Combine

final class FaceHorizontalMovementRecognizer: FaceMovementRecognizerProtocol, FaceRecognizerProtocol {
    
    // MARK: - Properties
    private var subscriptions: Set<AnyCancellable> = Set()
    private let facePublisher: PassthroughSubject<FaceRotation, Never> = PassthroughSubject<FaceRotation, Never>()
    
    private let queue: DispatchQueue = .init(label: String(describing: FaceHorizontalMovementRecognizer.self))
    @Published private var result: Bool = false
    
    // MARK: - Protocol Methods
    func start() {
        setupFacePublisher()
    }
    
    func stop() {
        //
    }
    
    func didChanged(transform: FaceRotation) {
        facePublisher.send(transform)
    }
    
    func recognized() async -> Bool {
        start()
        let result = (try? await $result.async()) ?? false
        stop()
        return result
    }
    
    // MARK: - Methods
    private func setupFacePublisher() {
        facePublisher
            .collect(.byTime(DispatchQueue.main, .seconds(1)))
            .receive(on: queue)
            .sink { [weak self] rotations in
                self?.calculatedRecognization(rotations: rotations)
            }
            .store(in: &subscriptions)
    }
    
    private func calculatedRecognization(rotations: [FaceRotation]) {
        let recognized = hasVerticalMovement(in: rotations)
        guard recognized else { return }
        result = recognized
    }
    
    func hasVerticalMovement(in rotations: [FaceRotation]) -> Bool {
        guard let first = rotations.first, let last = rotations.last else { return false }
        let delta = first.fromXAxis - last.fromXAxis
        return delta > 10 // TODO: Need to calibrate the value
    }
}
