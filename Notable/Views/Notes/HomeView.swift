import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    @State private var showEditor: Bool = false
    @State private var selectedForEdit: Note?
    @State private var selectedForDetail: Note?

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 16) {
                searchBar
                content
                Spacer(minLength: 80)
            }
            .padding()

            addFab
        }
        .sheet(item: $selectedForEdit) { note in
            NoteEditView(note: note) { updated in
                viewModel.updateNote(id: updated.id, title: updated.title, description: updated.description)
            }
        }
        .sheet(isPresented: $showEditor) {
            NoteEditView(note: nil) { created in
                viewModel.createNote(title: created.title, description: created.description)
            }
        }
        .sheet(item: $selectedForDetail) { note in
            NavigationStack {
                NoteDetailView(note: note)
                    .environmentObject(viewModel)
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .navigationTitle(viewModel.isSearchActive ? "Search Results" : "Notes")
        .navigationBarTitleDisplayMode(.large)
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass").foregroundColor(.gray)
            TextField("Search...", text: $viewModel.searchQuery)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            if !viewModel.searchQuery.isEmpty {
                Button(action: { viewModel.clearSearch() }) {
                    Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                }
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(25)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isSearchActive && !viewModel.hasSearchResults {
            NoSearchResultsView(query: viewModel.searchQuery) { viewModel.clearSearch() }
        } else {
            if viewModel.notes.isEmpty {
                EmptyHomeView()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.notes) { note in
                            NoteCardView(note: note) { selectedForEdit = note }
                        }
                    }
                }
            }
        }
    }

    private var addFab: some View {
        Button(action: { showEditor = true }) {
            Image(systemName: "plus")
                .font(.title)
                .foregroundColor(.white)
                .padding()
                .background(Circle().fill(Color.indigo))
                .shadow(radius: 4)
        }
        .padding(.bottom, 40)
    }
}

private struct NoSearchResultsView: View {
    let query: String
    let onClear: () -> Void
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundColor(.gray.opacity(0.6))
            Text("No results found").font(.title3).bold().foregroundColor(.gray)
            Text("No notes match \(query)").foregroundColor(.gray)
            Button("Clear Search", action: onClear)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


