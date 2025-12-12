import SwiftUI

struct ShapeCanvasView: UIViewRepresentable {
    @ObservedObject var viewModel: ShapeCanvasViewModel

    func makeUIView(context: Context) -> ShapeCanvasUIKitView {
        let view = ShapeCanvasUIKitView()
        view.viewModel = viewModel
        return view
    }

    func updateUIView(_ uiView: ShapeCanvasUIKitView, context: Context) {
        uiView.setNeedsDisplay()
    }
}
