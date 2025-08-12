import Foundation

final class PersistenceController {
    static let shared = PersistenceController()

    private var notes: [Note] = []
    private let queue = DispatchQueue(label: "com.example.notable.persistence", qos: .userInitiated)

    private init() {}

    func save() {
        // In-memory storage, no need to save
    }
}

extension PersistenceController {
    func fetchNotes() throws -> [Note] {
        return notes
    }

    func upsert(_ note: Note) throws {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
        } else {
            notes.append(note)
        }
    }

    func deleteNote(id: String) throws {
        notes.removeAll { $0.id == id }
    }
}


