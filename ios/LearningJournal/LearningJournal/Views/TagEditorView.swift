import SwiftUI

struct TagEditorView: View {
    @Environment(\.dismiss) private var dismiss

    let entryId: String
    let currentTags: [String]
    var onUpdated: (JournalEntry) -> Void

    @State private var allTags: [Tag] = []
    @State private var selectedTags: Set<String> = []
    @State private var isLoading = true
    @State private var isSaving = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Cargando tags…")
                } else {
                    List(allTags) { tag in
                        Button {
                            toggleTag(tag.name)
                        } label: {
                            HStack {
                                Circle()
                                    .fill(Color(hex: tag.color) ?? .blue)
                                    .frame(width: 12, height: 12)

                                Text(tag.name)
                                    .foregroundStyle(.primary)

                                Spacer()

                                if selectedTags.contains(tag.name) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                        .bold()
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Editar Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        Task { await saveTags() }
                    }
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
            .task {
                await loadTags()
            }
        }
    }

    private func toggleTag(_ name: String) {
        if selectedTags.contains(name) {
            selectedTags.remove(name)
        } else {
            selectedTags.insert(name)
        }
    }

    private func loadTags() async {
        isLoading = true
        defer { isLoading = false }
        do {
            allTags = try await APIService.shared.listTags()
            selectedTags = Set(currentTags)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func saveTags() async {
        isSaving = true
        defer { isSaving = false }
        do {
            let updated = try await APIService.shared.updateTags(
                entryId: entryId,
                tags: Array(selectedTags)
            )
            onUpdated(updated)
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Color hex init

extension Color {
    init?(hex: String) {
        var cleaned = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleaned.hasPrefix("#") {
            cleaned.removeFirst()
        }

        guard cleaned.count == 6,
              let rgb = UInt64(cleaned, radix: 16) else {
            return nil
        }

        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}
