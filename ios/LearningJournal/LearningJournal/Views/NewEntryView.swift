import SwiftUI
import PencilKit

struct NewEntryView: View {
    @Environment(\.dismiss) private var dismiss

    var onSaved: () -> Void

    @State private var question1 = ""
    @State private var question2 = ""
    @State private var sketchDrawing = PKDrawing()
    @State private var showSketchPad = false
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Question 1 — Scribble-compatible text field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("¿Qué hiciste hoy?")
                            .font(.headline)

                        ScribbleTextField(
                            text: $question1,
                            placeholder: "Escribe lo que construiste o hiciste…",
                            minHeight: 120
                        )
                    }

                    // Question 2 — Scribble-compatible text field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("¿Qué aprendiste?")
                            .font(.headline)

                        ScribbleTextField(
                            text: $question2,
                            placeholder: "Escribe lo que aprendiste…",
                            minHeight: 120
                        )
                    }

                    // PencilKit sketch canvas (collapsible)
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showSketchPad.toggle()
                            }
                        } label: {
                            Label(
                                showSketchPad ? "Ocultar boceto" : "Agregar boceto",
                                systemImage: showSketchPad
                                    ? "chevron.up"
                                    : "pencil.tip.crop.circle"
                            )
                            .font(.subheadline.weight(.medium))
                        }
                        .buttonStyle(.bordered)
                        .tint(.accentColor)

                        if showSketchPad {
                            SketchPadView(drawing: $sketchDrawing)
                                .transition(
                                    .opacity.combined(with: .move(edge: .top))
                                )
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Nueva Entrada")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cerrar") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        Task { await saveEntry() }
                    }
                    .disabled(question1.isEmpty && question2.isEmpty)
                    .bold()
                }
            }
            .overlay {
                if isSaving {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                    ProgressView("Guardando…")
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func saveEntry() async {
        isSaving = true
        defer { isSaving = false }
        do {
            _ = try await APIService.shared.createEntry(
                question1: question1,
                question2: question2
            )
            onSaved()
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

/// A multi-line text field that supports Apple Pencil Scribble input.
/// TextEditor natively supports Scribble — handwriting with Apple Pencil
/// is automatically converted to text on iPad.
struct ScribbleTextField: View {
    @Binding var text: String
    let placeholder: String
    let minHeight: CGFloat

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
            }

            TextEditor(text: $text)
                .frame(minHeight: minHeight)
                .scrollContentBackground(.hidden)
        }
        .padding(4)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    NewEntryView(onSaved: {})
}
