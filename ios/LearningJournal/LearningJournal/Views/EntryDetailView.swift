import SwiftUI

struct EntryDetailView: View {
    let entryId: String

    @State private var entry: JournalEntry?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showTagEditor = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Cargando…")
            } else if let entry {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Date
                        Label(entry.date.formatted(date: .long, time: .shortened), systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        // Tags
                        if !entry.tags.isEmpty {
                            FlowLayout(spacing: 6) {
                                ForEach(entry.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(.blue.opacity(0.12))
                                        .clipShape(Capsule())
                                }
                            }
                        }

                        // Question 1
                        VStack(alignment: .leading, spacing: 6) {
                            Text("¿Qué hiciste hoy?")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text(entry.question1)
                                .font(.body)
                        }

                        // Question 2
                        VStack(alignment: .leading, spacing: 6) {
                            Text("¿Qué aprendiste?")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Text(entry.question2)
                                .font(.body)
                        }
                    }
                    .padding()
                }
                .navigationTitle(entry.title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showTagEditor = true
                        } label: {
                            Label("Editar tags", systemImage: "tag")
                        }
                    }
                }
                .sheet(isPresented: $showTagEditor) {
                    TagEditorView(
                        entryId: entry.id,
                        currentTags: entry.tags,
                        onUpdated: { updated in
                            self.entry = updated
                        }
                    )
                }
            } else {
                ContentUnavailableView(
                    "Error",
                    systemImage: "exclamationmark.triangle",
                    description: Text(errorMessage ?? "No se pudo cargar la entrada")
                )
            }
        }
        .task {
            await loadEntry()
        }
    }

    private func loadEntry() async {
        isLoading = true
        defer { isLoading = false }
        do {
            entry = try await APIService.shared.getEntry(id: entryId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

/// Simple flow layout for wrapping tags.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}
