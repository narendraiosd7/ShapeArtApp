import UIKit

final class ShapeCanvasUIKitView: UIView {

    var viewModel: ShapeCanvasViewModel!

    private enum DragMode {
        case none
        case move(shapeID: UUID)
        case resize(shapeID: UUID, corner: Corner)
    }

    private enum Corner {
        case topLeft, topRight, bottomLeft, bottomRight
    }

    private var dragMode: DragMode = .none
    private var initialFrame: CGRect = .zero
    private var initialTouchPoint: CGPoint = .zero

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        backgroundColor = .systemBackground

        // drag & drop target (optional: from external toolbar)
        let dropInteraction = UIDropInteraction(delegate: self)
        addInteraction(dropInteraction)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }

    override func draw(_ rect: CGRect) {
        guard let vm = viewModel else { return }

        for shape in vm.shapes {
            // draw shape
            let path = shape.bezierPath(in: shape.frame)
            shape.color.setFill()
            path.fill()

            if shape.isSelected {
                // selection rect
                UIColor.systemBlue.setStroke()
                let selectionRect = UIBezierPath(rect: shape.frame)
                selectionRect.setLineDash([4, 2], count: 2, phase: 0)
                selectionRect.lineWidth = 1
                selectionRect.stroke()

                // corner handles
                let handleSize: CGFloat = 16
                for (corner, center) in cornerCenters(for: shape.frame) {
                    let handleRect = CGRect(
                        x: center.x - handleSize / 2,
                        y: center.y - handleSize / 2,
                        width: handleSize,
                        height: handleSize
                    )
                    UIColor.white.setFill()
                    UIColor.systemBlue.setStroke()
                    let r = UIBezierPath(rect: handleRect)
                    r.lineWidth = 2
                    r.fill()
                    r.stroke()
                    // corner parameter is only used for hit-testing, not drawing
                }
            }
        }
    }

    // MARK: - Helpers

    private func cornerCenters(for frame: CGRect) -> [(Corner, CGPoint)] {
        [
            (.topLeft, CGPoint(x: frame.minX, y: frame.minY)),
            (.topRight, CGPoint(x: frame.maxX, y: frame.minY)),
            (.bottomLeft, CGPoint(x: frame.minX, y: frame.maxY)),
            (.bottomRight, CGPoint(x: frame.maxX, y: frame.maxY))
        ]
    }

    private func shape(at point: CGPoint) -> DrawableShape? {
        viewModel.shapes.reversed().first { $0.hitTest(point) }
    }

    private func cornerHitTest(_ point: CGPoint, in frame: CGRect) -> Corner? {
        let size: CGFloat = 24
        let half = size / 2

        for (corner, center) in cornerCenters(for: frame) {
            let rect = CGRect(
                x: center.x - half,
                y: center.y - half,
                width: size,
                height: size
            )
            if rect.contains(point) {
                return corner
            }
        }
        return nil
    }

    // MARK: - Gestures

    @objc private func handleTap(_ gr: UITapGestureRecognizer) {
        let point = gr.location(in: self)
        guard let shape = shape(at: point) else {
            viewModel.selectShape(id: nil)
            setNeedsDisplay()
            return
        }
        viewModel.bringToFront(id: shape.id)
        viewModel.selectShape(id: shape.id)
        setNeedsDisplay()
    }

    @objc private func handlePan(_ gr: UIPanGestureRecognizer) {
        let point = gr.location(in: self)

        switch gr.state {
        case .began:
            guard let vm = viewModel else { return }
            if let selectedID = vm.selectedShapeID,
               let shape = vm.shapes.first(where: { $0.id == selectedID }),
               let corner = cornerHitTest(point, in: shape.frame) {
                dragMode = .resize(shapeID: shape.id, corner: corner)
                initialFrame = shape.frame
                initialTouchPoint = point
            } else if let shape = shape(at: point) {
                vm.bringToFront(id: shape.id)
                vm.selectShape(id: shape.id)
                dragMode = .move(shapeID: shape.id)
                initialFrame = shape.frame
                initialTouchPoint = point
            } else {
                dragMode = .none
            }

        case .changed:
            guard let vm = viewModel else { return }
            let dx = point.x - initialTouchPoint.x
            let dy = point.y - initialTouchPoint.y

            switch dragMode {
            case .move(let id):
                var newFrame = initialFrame
                newFrame.origin.x += dx
                newFrame.origin.y += dy
                vm.updateFrame(for: id, to: newFrame)

            case .resize(let id, let corner):
                var newFrame = initialFrame
                let minSize: CGFloat = 40

                switch corner {
                case .topLeft:
                    newFrame.origin.x += dx
                    newFrame.origin.y += dy
                    newFrame.size.width  -= dx
                    newFrame.size.height -= dy
                case .topRight:
                    newFrame.origin.y += dy
                    newFrame.size.width  += dx
                    newFrame.size.height -= dy
                case .bottomLeft:
                    newFrame.origin.x += dx
                    newFrame.size.width  -= dx
                    newFrame.size.height += dy
                case .bottomRight:
                    newFrame.size.width  += dx
                    newFrame.size.height += dy
                }

                newFrame.size.width  = max(newFrame.size.width, minSize)
                newFrame.size.height = max(newFrame.size.height, minSize)
                vm.updateFrame(for: id, to: newFrame)

            case .none:
                break
            }

            setNeedsDisplay()

        default:
            dragMode = .none
        }
    }
}

// MARK: - UIDropInteractionDelegate (optional drag & drop support)

extension ShapeCanvasUIKitView: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction,
                         canHandle session: UIDropSession) -> Bool {
        session.hasItemsConforming(toTypeIdentifiers: ["com.example.shape-type"])
    }

    func dropInteraction(_ interaction: UIDropInteraction,
                         sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        UIDropProposal(operation: .copy)
    }

    func dropInteraction(_ interaction: UIDropInteraction,
                         performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSString.self) { items in
            guard let raw = items.first as? String,
                  let type = ShapeType(rawValue: raw) else { return }
            let location = session.location(in: self)
            self.viewModel.addShape(of: type, at: location)
            self.setNeedsDisplay()
        }
    }
}
