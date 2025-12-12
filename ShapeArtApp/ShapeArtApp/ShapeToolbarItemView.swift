import SwiftUI

/// A reusable toolbar button for creating shapes.
///
/// This view displays an icon representing a shape type and executes a callback
/// when tapped. Each shape type has a corresponding SF Symbol icon.
struct ShapeToolbarItemView: View {
    /// The type of shape this button represents.
    ///
    /// This determines which icon is displayed and what shape will be created when tapped.
    let type: ShapeType
    
    /// A closure to execute when the button is tapped.
    ///
    /// This callback is provided by the parent view and typically creates a new shape.
    let onTap: () -> Void

    /// The body of the toolbar item, defining the visual appearance and interaction.
    ///
    /// Creates a resizable icon with fixed dimensions and padding, responding to tap gestures.
    ///
    /// - Returns: A view representing an interactive shape button.
    var body: some View {
        /// Display an SF Symbol image based on the shape type
        Image(systemName: systemImageName)
            /// Make the image resizable so it can be scaled to a specific size
            .resizable()
            /// Set a fixed frame of 32x32 points for consistent button sizing
            .frame(width: 32, height: 32)
            /// Add 8 points of padding around the icon for easier tapping
            .padding(8)
            /// Attach a tap gesture recognizer to detect user taps
            .onTapGesture {
                /// When the user taps this view, execute the provided callback
                onTap()
            }
    }

    /// Maps the shape type to its corresponding SF Symbol name.
    ///
    /// This computed property selects the appropriate system icon name based on
    /// the shape type, ensuring visual consistency with iOS design patterns.
    ///
    /// - Returns: A string containing the SF Symbol name for the shape.
    private var systemImageName: String {
        /// Use a switch statement to map each shape type to an icon name
        switch type {
        case .rectangle:
            /// Use the "square" SF Symbol for rectangles
            return "square"
        case .circle:
            /// Use the "circle" SF Symbol for circles
            return "circle"
        case .triangle:
            /// Use the "triangle" SF Symbol for triangles
            return "triangle"
        case .star:
            /// Use the "star" SF Symbol for stars
            return "star"
        }
    }
}

