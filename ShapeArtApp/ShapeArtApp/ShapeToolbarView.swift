import SwiftUI

/// A toolbar view containing shape creation buttons and a delete button.
///
/// This view displays a horizontal toolbar with shape type buttons on the left
/// and a delete button on the right. It observes the view model to update the
/// delete button's enabled state based on whether a shape is selected.
struct ShapeToolbarView: View {
    /// The view model containing the shapes and selection state.
    ///
    /// This property uses `@ObservedObject` to observe changes to the view model.
    /// When the view model's published properties change, this view automatically re-renders.
    @ObservedObject var viewModel: ShapeCanvasViewModel
    
    /// The size of the canvas area, used to constrain random shape placement.
    ///
    /// This size is passed from the parent view's `GeometryReader` to ensure
    /// shapes are positioned within the visible canvas bounds.
    let canvasSize: CGSize

    /// The body of the toolbar view, defining the layout and interactive elements.
    ///
    /// Creates a horizontal layout with shape buttons on the left, spacing in the middle,
    /// and a delete button on the right, all with a translucent material background.
    ///
    /// - Returns: A view representing the complete toolbar interface.
    var body: some View {
        /// A horizontal stack container for arranging toolbar items from left to right
        HStack {
            /// A horizontal stack for grouping the shape type buttons together
            HStack {
                /// Iterate over all available shape types to create a button for each
                /// `ShapeType.allCases` returns all cases because ShapeType conforms to CaseIterable
                /// Each type is used as its own identifier for SwiftUI's list management
                ForEach(ShapeType.allCases, id: \.self) { type in
                    /// Create a toolbar item view for this shape type
                    /// The closure is called when the user taps the button
                    ShapeToolbarItemView(type: type) {
                        /// When tapped, add a random instance of this shape type to the canvas
                        viewModel.addRandomShape(of: type, in: canvasSize)
                    }
                }
            }

            /// A flexible space that pushes content to the edges
            /// This pushes shape buttons to the left and delete button to the right
            Spacer()

            /// A delete button with destructive styling to remove the selected shape
            /// The `role: .destructive` parameter applies red/warning styling
            Button(role: .destructive) {
                /// When clicked, delete the currently selected shape
                viewModel.deleteSelected()
            } label: {
                /// Display a trash can icon from SF Symbols
                Image(systemName: "trash")
                    /// Set the icon to title3 size for better visibility
                    .font(.title3)
            }
            /// Disable the delete button when no shape is selected
            /// The button appears grayed out and non-interactive when disabled
            .disabled(viewModel.selectedShapeID == nil)
        }
        /// Add padding around all edges of the HStack for spacing from screen edges
        .padding()
        /// Apply an ultra-thick material background effect that adapts to light/dark mode
        /// This creates a translucent, frosted-glass appearance
        .background(.ultraThickMaterial)
    }
}
