import Foundation

struct APIErrorResponse: Codable, Error { 
    let detail: String 
}

struct TokenResponse: Codable { 
    let access: String
    let refresh: String 
}

struct AccessTokenResponse: Codable { 
    let access: String 
}

struct RegisterRequest: Codable {
    let username: String
    let password: String
    let email: String
    let first_name: String
    let last_name: String
}

struct RegisterResponse: Codable {
    let username: String
    let email: String
    let first_name: String
    let last_name: String
}

struct TokenRequest: Codable { 
    let username: String
    let password: String 
}

struct RefreshTokenRequest: Codable { 
    let refresh: String 
}

struct NoteDTO: Codable {
    let id: Int
    let title: String
    let description: String
    let created_at: String
    let updated_at: String
    let creator_name: String?
    let creator_username: String?
}

struct NotesResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [NoteDTO]
}

struct NoteResponse: Codable {
    let id: Int
    let title: String
    let description: String
    let created_at: String
    let updated_at: String
}

struct CreateNoteRequest: Codable { 
    let title: String
    let description: String 
}

struct UpdateNoteRequest: Codable { 
    let title: String
    let description: String 
}

struct ChangePasswordRequest: Codable { 
    let old_password: String
    let new_password: String 
}

struct ChangePasswordResponse: Codable { 
    let detail: String 
}


