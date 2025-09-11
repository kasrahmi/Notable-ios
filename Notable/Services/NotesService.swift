import Foundation

final class NotesService {
    static let shared = NotesService()
    private init() {}

    private static let isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private func parseISO8601(_ str: String) -> Date? {
        // Try with fractional seconds first, then without
        if let d = NotesService.isoFormatter.date(from: str) { return d }
        let f2 = ISO8601DateFormatter()
        f2.formatOptions = [.withInternetDateTime]
        return f2.date(from: str)
    }

    func fetchNotes(pageSize: Int = 100) async throws -> [Note] {
        let request = URLRequest.authorized(path: "notes/", method: "GET")
        let response: NotesResponse = try await NetworkManager.shared.perform(request, decode: NotesResponse.self)
        let notes: [Note] = response.results.map { dto in
            Note(
                id: String(dto.id),
                title: dto.title,
                description: dto.description,
                backgroundColorHex: Note.randomColorHex(),
                createdAt: parseISO8601(dto.created_at) ?? Date.distantPast,
                updatedAt: parseISO8601(dto.updated_at) ?? Date.distantPast,
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
            createdAt: parseISO8601(res.created_at) ?? Date(),
            updatedAt: parseISO8601(res.updated_at) ?? Date()
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
            createdAt: parseISO8601(res.created_at) ?? Date(),
            updatedAt: parseISO8601(res.updated_at) ?? Date()
        )
    }

    func delete(id: String) async throws {
        var req = URLRequest.authorized(path: "notes/\(id)/")
        req.httpMethod = "DELETE"
        try await NetworkManager.shared.performNoContent(req)
    }
}


