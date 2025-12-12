import SwiftUI

/// The main content view of the ShapeArtApp.
///
/// This view serves as the root user interface and coordinates between the toolbar
/// and canvas components. It uses a `GeometryReader` to provide size information
/// to child views and manages the overall layout of the application.
struct ContentView: View {
  /// The view model that manages the state and business logic for the shape canvas.
  ///
  /// This property uses the `@StateObject` property wrapper to create and own
  /// a `ShapeCanvasViewModel` instance. The `@StateObject` ensures that the
  /// view model persists across view updates and isn't recreated when the view redraws.
  /// Being marked as `private` ensures encapsulation and prevents external modification.
  @StateObject private var viewModel = ShapeCanvasViewModel()
  
  /// The body of the view, defining the user interface layout.
  ///
  /// This computed property returns a view hierarchy that:
  /// 1. Uses a `GeometryReader` to access the available size
  /// 2. Stacks the toolbar and canvas vertically with no spacing
  /// 3. Ignores safe area insets at the bottom for a full-screen canvas
  ///
  /// - Returns: A view that represents the complete user interface.
  var body: some View {
    /// A container that provides its child views with the size of its parent.
    /// The `GeometryReader` exposes a `GeometryProxy` (named `geo`) that contains
    /// size and coordinate space information, which is passed to the toolbar.
    GeometryReader { geo in
      /// A vertical stack that arranges the toolbar and canvas from top to bottom.
      /// The `spacing: 0` parameter ensures there's no gap between the toolbar
      /// and the canvas, creating a seamless interface.
      VStack(spacing: 0) {
        /// The toolbar view containing shape selection and delete buttons.
        /// This view receives:
        /// - `viewModel`: The shared view model for coordinating actions
        /// - `canvasSize`: The available canvas size from the geometry reader
        ShapeToolbarView(
          viewModel: viewModel,
          canvasSize: geo.size
        )
        /// The main canvas view where shapes are drawn and manipulated.
        /// This view is a UIKit-backed view wrapped in SwiftUI that displays
        /// all the shapes and handles user interactions like dragging and tapping.
        ShapeCanvasView(viewModel: viewModel)
          /// Sets the background color to the system's secondary background color.
          /// This provides a subtle visual distinction from the toolbar
          /// and adapts automatically to light/dark mode.
          .background(Color(UIColor.secondarySystemBackground))
      }
      /// Extends the view into the safe area at the bottom edge.
      /// This allows the canvas to use the full screen height, including
      /// areas that might normally be reserved for system UI like the home indicator.
      .ignoresSafeArea(edges: .bottom)
    }
  }
}
