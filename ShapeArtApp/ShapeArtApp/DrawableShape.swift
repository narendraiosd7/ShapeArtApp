import UIKit

protocol DrawableShape {
    var id: UUID { get }
    var type: ShapeType { get }
    var frame: CGRect { get set }
    var color: UIColor { get set }
    var isSelected: Bool { get set }

    func bezierPath(in bounds: CGRect) -> UIBezierPath
    func hitTest(_ point: CGPoint) -> Bool
}

extension DrawableShape {
    func hitTest(_ point: CGPoint) -> Bool {
        bezierPath(in: frame).contains(point)
    }
}

// MARK: - Rectangle

struct RectangleShape: DrawableShape {
    let id = UUID()
    let type: ShapeType = .rectangle
    var frame: CGRect
    var color: UIColor
    var isSelected: Bool = false

    func bezierPath(in bounds: CGRect) -> UIBezierPath {
        UIBezierPath(rect: bounds)
    }
}

// MARK: - Circle

struct CircleShape: DrawableShape {
    let id = UUID()
    let type: ShapeType = .circle
    var frame: CGRect
    var color: UIColor
    var isSelected: Bool = false

    func bezierPath(in bounds: CGRect) -> UIBezierPath {
        UIBezierPath(ovalIn: bounds)
    }
}

// MARK: - Triangle

struct TriangleShape: DrawableShape {
    let id = UUID()
    let type: ShapeType = .triangle
    var frame: CGRect
    var color: UIColor
    var isSelected: Bool = false

    func bezierPath(in bounds: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let top = CGPoint(x: bounds.midX, y: bounds.minY)
        let left = CGPoint(x: bounds.minX, y: bounds.maxY)
        let right = CGPoint(x: bounds.maxX, y: bounds.maxY)
        path.move(to: top)
        path.addLine(to: left)
        path.addLine(to: right)
        path.close()
        return path
    }
}

// MARK: - Star (simple 5-point)

struct StarShape: DrawableShape {
    let id = UUID()
    let type: ShapeType = .star
    var frame: CGRect
    var color: UIColor
    var isSelected: Bool = false

    func bezierPath(in bounds: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let points = 5
        let outerRadius = min(bounds.width, bounds.height) / 2
        let innerRadius = outerRadius * 0.4

        for i in 0..<(points * 2) {
            let angle = CGFloat(i) * .pi / CGFloat(points)
            let radius = (i % 2 == 0) ? outerRadius : innerRadius
            let pt = CGPoint(
                x: center.x + radius * sin(angle),
                y: center.y - radius * cos(angle)
            )
            if i == 0 {
                path.move(to: pt)
            } else {
                path.addLine(to: pt)
            }
        }
        path.close()
        return path
    }
}
