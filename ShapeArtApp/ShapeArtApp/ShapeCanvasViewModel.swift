import UIKit
import Combine

/// The view model managing the state and business logic for the shape canvas.
///
/// This class serves as the single source of truth for all shapes on the canvas,
/// handling shape creation, selection, deletion, and manipulation. It conforms to
/// `ObservableObject` to enable SwiftUI views to automatically update when the state changes.
/// The `final` keyword prevents subclassing, ensuring this class is used as-is.
final class ShapeCanvasViewModel: ObservableObject {
    /// The collection of all shapes currently on the canvas.
    ///
    /// This array is marked with `@Published` so any changes automatically trigger
    /// UI updates in observing views. The `private(set)` access control means only
    /// this view model can modify the array, while external code can read it.
    /// Shapes are ordered from back to front (last shape is drawn on top).
    @Published private(set) var shapes: [DrawableShape] = []
    
    /// The unique identifier of the currently selected shape, if any.
    ///
    /// When `nil`, no shape is selected. This property is `@Published` so selection
    /// changes trigger UI updates (e.g., enabling/disabling the delete button).
    @Published var selectedShapeID: UUID?

    /// Adds a new shape of the specified type at the given point.
    ///
    /// This method creates a shape centered at the provided point with a random color.
    /// The newly created shape is automatically selected after being added.
    ///
    /// - Parameters:
    ///   - type: The type of shape to create (rectangle, circle, triangle, or star)
    ///   - point: The center point where the shape should be positioned
    func addShape(of type: ShapeType, at point: CGPoint) {
        /// Define a fixed size for all new shapes (120 points)
        let size: CGFloat = 120
        /// Calculate the origin point so the shape is centered at the provided point
        /// by offsetting half the size in both x and y directions
        let origin = CGPoint(x: point.x - size / 2, y: point.y - size / 2)
        /// Create a square frame with the calculated origin and size
        let frame = CGRect(origin: origin, size: CGSize(width: size, height: size))
        /// Generate a random color with RGB values between 0.2 and 0.9
        /// (avoiding too dark or too light colors) with full opacity
        let color = UIColor(
            red: .random(in: 0.2...0.9),
            green: .random(in: 0.2...0.9),
            blue: .random(in: 0.2...0.9),
            alpha: 1
        )

        /// Create the appropriate shape based on the requested type
        let shape: DrawableShape
        /// Use a switch to instantiate the correct shape struct
        switch type {
        case .rectangle:
            /// Create a RectangleShape with the calculated frame and color
            shape = RectangleShape(frame: frame, color: color)
        case .circle:
            /// Create a CircleShape with the calculated frame and color
            shape = CircleShape(frame: frame, color: color)
        case .triangle:
            /// Create a TriangleShape with the calculated frame and color
            shape = TriangleShape(frame: frame, color: color)
        case .star:
            /// Create a StarShape with the calculated frame and color
            shape = StarShape(frame: frame, color: color)
        }

        /// Add the newly created shape to the end of the shapes array
        /// (which means it will be drawn on top of existing shapes)
        shapes.append(shape)
        /// Automatically select the newly created shape
        selectShape(id: shape.id)
    }

    /// Adds a new shape at a random location within the canvas bounds.
    ///
    /// This method calculates a random position ensuring the shape is fully visible
    /// within the canvas (not clipped at edges), then calls the main `addShape` method.
    ///
    /// - Parameters:
    ///   - type: The type of shape to create
    ///   - canvasSize: The size of the canvas to constrain the random position
    func addRandomShape(of type: ShapeType, in canvasSize: CGSize) {
        /// The size of shapes to create (must match the size in addShape method)
        let size: CGFloat = 120
        /// Minimum X coordinate (half shape size from left edge)
        let minX = size / 2
        /// Maximum X coordinate (half shape size from right edge)
        let maxX = canvasSize.width - size / 2
        /// Minimum Y coordinate (half shape size from top edge)
        let minY = size / 2
        /// Maximum Y coordinate (half shape size from bottom edge)
        let maxY = canvasSize.height - size / 2

        /// Generate a random point within the calculated bounds
        let point = CGPoint(
            /// Random X coordinate between minX and maxX
            x: CGFloat.random(in: minX...maxX),
            /// Random Y coordinate between minY and maxY
            y: CGFloat.random(in: minY...maxY)
        )

        /// Call the main addShape method with the random position
        addShape(of: type, at: point)
    }

    /// Updates which shape is currently selected.
    ///
    /// This method handles both selecting a shape (when id is non-nil) and
    /// deselecting all shapes (when id is nil). It updates the `isSelected`
    /// property on all shapes to reflect the new selection state.
    ///
    /// - Parameter id: The UUID of the shape to select, or nil to deselect all
    func selectShape(id: UUID?) {
        /// Store the selected shape ID for external access
        selectedShapeID = id
        /// Map over all shapes to create new copies with updated selection state
        shapes = shapes.map { s in
            /// Create a mutable copy of the shape (since shapes are value types)
            var copy = s
            /// Set isSelected to true only if this shape's ID matches the provided ID
            copy.isSelected = (s.id == id)
            /// Return the modified copy
            return copy
        }
    }

    /// Deletes the currently selected shape from the canvas.
    ///
    /// If no shape is selected (selectedShapeID is nil), this method does nothing.
    /// After deletion, the selection is cleared.
    func deleteSelected() {
        /// Use guard to early-return if no shape is selected
        guard let id = selectedShapeID else { return }
        /// Remove all shapes whose ID matches the selected ID
        shapes.removeAll { $0.id == id }
        /// Clear the selection since the selected shape no longer exists
        selectedShapeID = nil
    }

    /// Moves the specified shape to the front (top) of the drawing order.
    ///
    /// This method is called when a shape is tapped or dragged, ensuring the
    /// manipulated shape appears on top of others. It works by removing the
    /// shape from its current position and appending it to the end of the array.
    ///
    /// - Parameter id: The unique identifier of the shape to bring forward
    func bringToFront(id: UUID) {
        /// Find the index of the shape with the given ID
        guard let index = shapes.firstIndex(where: { $0.id == id }) else { return }
        /// Remove the shape from its current position in the array
        let shape = shapes.remove(at: index)
        /// Append it to the end (making it drawn last, thus on top)
        shapes.append(shape)
    }

    /// Updates the frame (position and/or size) of a specific shape.
    ///
    /// This method is typically called during drag gestures to move shapes around
    /// the canvas. It creates a new copy of the shape with the updated frame.
    ///
    /// - Parameters:
    ///   - id: The unique identifier of the shape to update
    ///   - newFrame: The new CGRect defining the shape's position and size
    func updateFrame(for id: UUID, to newFrame: CGRect) {
        /// Map over all shapes to create updated copies
        shapes = shapes.map { s in
            /// If this isn't the shape we're updating, return it unchanged
            guard s.id == id else { return s }
            /// Create a mutable copy of the matching shape
            var copy = s
            /// Update the frame with the new value
            copy.frame = newFrame
            /// Return the modified copy
            return copy
        }
    }
}
