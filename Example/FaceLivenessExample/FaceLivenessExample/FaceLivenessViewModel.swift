import SwiftUI
import FaceLivenessFramework
import Combine

final class FaceLivenessViewModel:/* FaceLivenessViewModelProtocol*/ ObservableObject {
    @Published var currentImage: CGImage?
    @Published var message: String = "Iniciando"
    private let liveness = FaceLiveness()
    
    func start() {
        Task {
            await liveness.startLiveness(with: self)
        }        
    }
}

extension FaceLivenessViewModel: FaceLivenessDelegate {
    func didUpdateVideo(currentImage: CGImage?) {
        self.currentImage = currentImage
    }
    
    func didDetect(detected: Bool) {
        message = detected ? "Blinked" : "Not blinked"
    }
}


//protocol FaceLivenessViewModelProtocol: ObservableObject {
//    var currentImage: Published<CGImage?> { get }
//}

