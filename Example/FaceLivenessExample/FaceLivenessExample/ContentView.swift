import SwiftUI
import FaceLivenessFramework

struct ContentView: View {
    
    @StateObject var viewModel = FaceLivenessViewModel()
    var body: some View {
        VStack {
            Text(viewModel.message)
            if let image = viewModel.currentImage {
                Image(image, scale: 2, orientation: .upMirrored, label: Text(""))
            }
        }
        .padding()
        .onAppear {
            viewModel.start()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
