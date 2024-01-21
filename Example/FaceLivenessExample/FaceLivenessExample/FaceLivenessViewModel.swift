import SwiftUI
import FaceLivenessFramework
import Combine
import ARKit

final class FaceLivenessViewModel:/* FaceLivenessViewModelProtocol*/ ObservableObject {
    @Published var currentImage: CGImage?
    @Published var message: String = "Iniciando"
    var sceneView: ARSCNView { liveness.sceneView }
    
    private let liveness = FaceLiveness()
    
    func start() {
        Task {
            await liveness.startLiveness(validations: [.blink, .horizontalMovement, .verticalMovement, .smile])
        }        
    }
}

//extension FaceLivenessViewModel: FaceLivenessDelegate {
//    
//    func didDetect(detected: Bool) {
//        message = detected ? "Blinked" : "Not blinked"
//    }
//}
