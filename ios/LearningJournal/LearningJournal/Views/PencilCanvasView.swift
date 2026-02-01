import SwiftUI
import PencilKit

/// A SwiftUI wrapper around PKCanvasView for Apple Pencil drawing.
///
/// Provides a PencilKit canvas with tool picker support. On iPad with Apple Pencil,
/// the tool picker appears automatically. On iPhone, finger drawing is enabled.
struct PencilCanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var drawing: PKDrawing

    /// Whether to show the PencilKit tool picker (pen, marker, eraser, etc.)
    var showToolPicker: Bool = true

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.delegate = context.coordinator
        canvasView.drawing = drawing
        canvasView.backgroundColor = .secondarySystemBackground
        canvasView.isOpaque = false

        // Allow finger drawing on devices without Apple Pencil
        #if targetEnvironment(simulator)
        canvasView.drawingPolicy = .anyInput
        #else
        canvasView.drawingPolicy = .pencilOnly
        #endif

        // Set default tool
        canvasView.tool = PKInkingTool(.pen, color: .label, width: 3)

        if showToolPicker {
            let toolPicker = PKToolPicker()
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
            // Store reference so it doesn't get deallocated
            context.coordinator.toolPicker = toolPicker
        }

        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        // Only update if the drawing has changed externally
        if uiView.drawing != drawing {
            uiView.drawing = drawing
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        @Binding var drawing: PKDrawing
        var toolPicker: PKToolPicker?

        init(drawing: Binding<PKDrawing>) {
            _drawing = drawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing = canvasView.drawing
        }
    }
}

/// A view that combines a PencilKit canvas with a clear button.
struct SketchPadView: View {
    @Binding var drawing: PKDrawing
    @State private var canvasView = PKCanvasView()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Boceto", systemImage: "pencil.tip.crop.circle")
                    .font(.headline)

                Spacer()

                Button {
                    drawing = PKDrawing()
                    canvasView.drawing = PKDrawing()
                } label: {
                    Label("Limpiar", systemImage: "trash")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }

            PencilCanvasView(
                canvasView: $canvasView,
                drawing: $drawing
            )
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}
