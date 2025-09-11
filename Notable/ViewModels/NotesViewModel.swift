import Foundation
import Combine

final class NotesViewModel: ObservableObject {
    @Published private(set) var notes: [Note] = []
    @Published var searchQuery: String = ""
    @Published private(set) var isLoading: Bool = true
    @Published private(set) var isSearchActive: Bool = false
    @Published private(set) var hasSearchResults: Bool = true
    @Published var errorMessage: String?

    private var allNotes: [Note] = []
    private var cancellables: Set<AnyCancellable> = []

    init() {
        observeSearchQuery()
        Task { await loadNotes() }
    }

    @MainActor
    func loadNotes() async {
        isLoading = true
        do {
            // Load from local first
            let local = try PersistenceController.shared.fetchNotes()
            self.allNotes = try await filterNotesForCurrentUser(local)
            if self.searchQuery.isEmpty {
                self.notes = local
                self.isSearchActive = false
                self.hasSearchResults = true
            } else {
                applySearch(self.searchQuery)
            }

            // Sync from network
            let remote = try await NotesService.shared.fetchNotes()
            for note in remote { try? PersistenceController.shared.upsert(note) }
            let all = try PersistenceController.shared.fetchNotes()
            self.allNotes = try await filterNotesForCurrentUser(all)
            if self.searchQuery.isEmpty {
                self.notes = self.allNotes
                self.isSearchActive = false
                self.hasSearchResults = true
            } else {
                applySearch(self.searchQuery)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func filterNotesForCurrentUser(_ notes: [Note]) async throws -> [Note] {
        do {
            let user = try await AuthService.shared.getUserInfo()
            let filtered = notes.filter { note in
                // Prefer server-sent creatorUsername when available
                if let creator = note.creatorUsername, !creator.isEmpty {
                    return creator == user.username
                }
                // If missing, we cannot reliably determine ownership; default to include
                return true
            }
            return filtered
        } catch {
            return notes
        }
    }

    private func observeSearchQuery() {
        $searchQuery
            .removeDuplicates()
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)  // Match Android's 300ms debounce
            .sink { [weak self] query in
                self?.applySearch(query)
            }
            .store(in: &cancellables)
    }

    private func applySearch(_ query: String) {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            notes = allNotes
            isSearchActive = false
            hasSearchResults = true
        } else {
            let q = query.lowercased()
            let filtered = allNotes.filter { $0.title.lowercased().contains(q) || $0.description.lowercased().contains(q) }
            notes = filtered
            isSearchActive = true
            hasSearchResults = !filtered.isEmpty
        }
    }

    func clearSearch() { searchQuery = "" }

    func createNote(title: String, description: String) {
        Task { @MainActor in
            do {
                let note = try await NotesService.shared.create(title: title, description: description)
                try? PersistenceController.shared.upsert(note)
                await loadNotes()
            } catch { errorMessage = error.localizedDescription }
        }
    }

    func updateNote(id: String, title: String, description: String) {
        Task { @MainActor in
            do {
                let note = try await NotesService.shared.update(id: id, title: title, description: description)
                try? PersistenceController.shared.upsert(note)
                await loadNotes()
            } catch { errorMessage = error.localizedDescription }
        }
    }

    func deleteNote(id: String) {
        Task { @MainActor in
            do {
                try await NotesService.shared.delete(id: id)
                try? PersistenceController.shared.deleteNote(id: id)
                await loadNotes()
            } catch { errorMessage = error.localizedDescription }
        }
    }
}


