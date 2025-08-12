import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var connectionStatus: String = "Unknown"

    func bootstrapAuthenticationState() {
        isAuthenticated = AuthService.shared.isLoggedIn()
    }

    func testConnection() async {
        await MainActor.run {
            connectionStatus = "Testing..."
        }
        
        let isConnected = await NetworkManager.shared.testConnection()
        
        await MainActor.run {
            connectionStatus = isConnected ? "Connected" : "Failed to connect"
        }
    }

    func login(username: String, password: String) {
        errorMessage = nil
        isLoading = true
        Task { @MainActor in
            do {
                try await AuthService.shared.login(username: username, password: password)
                isAuthenticated = true
            } catch {
                errorMessage = (error as? APIErrorResponse)?.detail ?? error.localizedDescription
            }
            isLoading = false
        }
    }

    func register(username: String, password: String, email: String, firstName: String, lastName: String) {
        errorMessage = nil
        isLoading = true
        Task { @MainActor in
            do {
                try await AuthService.shared.register(username: username, password: password, email: email, firstName: firstName, lastName: lastName)
            } catch {
                errorMessage = (error as? APIErrorResponse)?.detail ?? error.localizedDescription
            }
            isLoading = false
        }
    }

    func logout() {
        AuthService.shared.logout()
        isAuthenticated = false
    }
}


