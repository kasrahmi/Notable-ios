import Foundation

final class AuthService {
    static let shared = AuthService()
    private init() {}

    func currentAccessToken() -> String? {
        if let d = KeychainManager.shared.get(TokenKeys.access) { return String(data: d, encoding: .utf8) }
        return nil
    }

    func isLoggedIn() -> Bool { currentAccessToken() != nil }

    func login(username: String, password: String) async throws {
        let payload = TokenRequest(username: username, password: password)
        let body = try JSONEncoder().encode(payload)
        let request = URLRequest.authorized(path: "auth/token/", method: "POST", body: body)
        let tokens: TokenResponse = try await NetworkManager.shared.perform(request, decode: TokenResponse.self)
        store(tokens: tokens)
    }

    func register(username: String, password: String, email: String, firstName: String, lastName: String) async throws {
        let req = RegisterRequest(username: username, password: password, email: email, firstName: firstName, lastName: lastName)
        let body = try JSONEncoder().encode(req)
        let request = URLRequest.authorized(path: "auth/register/", method: "POST", body: body)
        _ = try await NetworkManager.shared.perform(request, decode: RegisterResponse.self)
    }

    func getUserInfo() async throws -> User {
        let request = URLRequest.authorized(path: "auth/userinfo/")
        struct UserDTO: Codable { 
            let id: Int
            let username: String
            let email: String
            let first_name: String
            let last_name: String 
        }
        let dto: UserDTO = try await NetworkManager.shared.perform(request, decode: UserDTO.self)
        return User(id: String(dto.id), email: dto.email, createdAt: Date())
    }

    func changePassword(current: String, new: String) async throws {
        let req = ChangePasswordRequest(old_password: current, new_password: new)
        let body = try JSONEncoder().encode(req)
        let request = URLRequest.authorized(path: "auth/change-password/", method: "POST", body: body)
        _ = try await NetworkManager.shared.perform(request, decode: ChangePasswordResponse.self)
    }

    func refreshTokenIfPossible() async throws {
        guard let refresh = KeychainManager.shared.get(TokenKeys.refresh).flatMap({ String(data: $0, encoding: .utf8) }) else { return }
        let body = try JSONEncoder().encode(RefreshTokenRequest(refresh: refresh))
        let request = URLRequest.authorized(path: "auth/token/refresh/", method: "POST", body: body)
        let response: AccessTokenResponse = try await NetworkManager.shared.perform(request, decode: AccessTokenResponse.self)
        store(access: response.access, refresh: refresh)
    }

    func logout() {
        KeychainManager.shared.delete(TokenKeys.access)
        KeychainManager.shared.delete(TokenKeys.refresh)
        KeychainManager.shared.delete(TokenKeys.expiry)
    }

    private func store(tokens: TokenResponse) {
        store(access: tokens.access, refresh: tokens.refresh)
    }

    private func store(access: String, refresh: String) {
        KeychainManager.shared.set(Data(access.utf8), for: TokenKeys.access)
        KeychainManager.shared.set(Data(refresh.utf8), for: TokenKeys.refresh)
        let expiryMs = Date().addingTimeInterval(30*60).timeIntervalSince1970 * 1000
        KeychainManager.shared.set(Data(String(expiryMs).utf8), for: TokenKeys.expiry)
    }
}


