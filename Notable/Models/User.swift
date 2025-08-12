import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    let createdAt: Date
}


