import SwiftUI
import FaceLivenessFramework

struct ContentView: View {
    
    @StateObject var viewModel = FaceLivenessViewModel()
    var body: some View {
        VStack {
            Text(viewModel.message)
            UIContainerView(view: viewModel.sceneView)
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


struct UIContainerView: UIViewRepresentable {
    var view: UIView
    
    func makeUIView(context: Context) -> some UIView {
        let container = UIView()
        container.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        return container
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // update if needed
    }
}
