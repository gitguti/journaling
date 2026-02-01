import SwiftUI

struct HomeView: View {
    @State private var entries: [EntryListItem] = []
    @State private var isLoading = false
    @State private var showNewEntry = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                if isLoading && entries.isEmpty {
                    ProgressView("Cargando…")
                } else if entries.isEmpty {
                    ContentUnavailableView(
                        "Sin entradas",
                        systemImage: "book.closed",
                        description: Text("Toca + para crear tu primera entrada")
                    )
                } else {
                    List(entries) { entry in
                        NavigationLink(destination: EntryDetailView(entryId: entry.id)) {
                            EntryRow(entry: entry)
                        }
                    }
                    .refreshable {
                        await loadEntries()
                    }
                }
            }
            .navigationTitle("Mi Diario")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewEntry = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showNewEntry) {
                NewEntryView(onSaved: {
                    Task { await loadEntries() }
                })
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
            .task {
                await loadEntries()
            }
        }
    }

    private func loadEntries() async {
        isLoading = true
        defer { isLoading = false }
        do {
            entries = try await APIService.shared.listEntries()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

struct EntryRow: View {
    let entry: EntryListItem

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(entry.title)
                .font(.headline)

            Text(entry.preview)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            HStack(spacing: 6) {
                ForEach(entry.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.blue.opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            Text(entry.date, style: .date)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    HomeView()
}
