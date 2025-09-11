import Foundation

final class NotesService {
    static let shared = NotesService()
    private init() {}

    func fetchNotes(pageSize: Int = 100) async throws -> [Note] {
        let request = URLRequest.authorized(path: "notes/", method: "GET")
        let response: NotesResponse = try await NetworkManager.shared.perform(request, decode: NotesResponse.self)
        let notes: [Note] = response.results.map { dto in
            Note(
                id: String(dto.id),
                title: dto.title,
                description: dto.description,
                backgroundColorHex: Note.randomColorHex(),
                createdAt: ISO8601DateFormatter().date(from: dto.created_at) ?? Date(),
                updatedAt: ISO8601DateFormatter().date(from: dto.updated_at) ?? Date(),
                creatorUsername: dto.creator_username
            )
        }
        return notes
    }

    func create(title: String, description: String) async throws -> Note {
        let body = try JSONEncoder().encode(CreateNoteRequest(title: title, description: description))
        let request = URLRequest.authorized(path: "notes/", method: "POST", body: body)
        let res: NoteResponse = try await NetworkManager.shared.perform(request, decode: NoteResponse.self)
        return Note(
            id: String(res.id),
            title: res.title,
            description: res.description,
            backgroundColorHex: Note.randomColorHex(),
            createdAt: ISO8601DateFormatter().date(from: res.created_at) ?? Date(),
            updatedAt: ISO8601DateFormatter().date(from: res.updated_at) ?? Date()
        )
    }

    func update(id: String, title: String, description: String) async throws -> Note {
        let body = try JSONEncoder().encode(UpdateNoteRequest(title: title, description: description))
        let request = URLRequest.authorized(path: "notes/\(id)/", method: "PUT", body: body)
        let res: NoteResponse = try await NetworkManager.shared.perform(request, decode: NoteResponse.self)
        return Note(
            id: String(res.id),
            title: res.title,
            description: res.description,
            backgroundColorHex: Note.randomColorHex(),
            createdAt: ISO8601DateFormatter().date(from: res.created_at) ?? Date(),
            updatedAt: ISO8601DateFormatter().date(from: res.updated_at) ?? Date()
        )
    }

    func delete(id: String) async throws {
        var req = URLRequest.authorized(path: "notes/\(id)/")
        req.httpMethod = "DELETE"
        try await NetworkManager.shared.performNoContent(req)
    }
}


