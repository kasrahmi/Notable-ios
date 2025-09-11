import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var connectionStatus: String = "Unknown"
    @Published var registrationSuccess: Bool = false

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
        registrationSuccess = false
        isLoading = true
        Task { @MainActor in
            do {
                try await AuthService.shared.register(username: username, password: password, email: email, firstName: firstName, lastName: lastName)
                registrationSuccess = true
                // Auto-login after successful registration for seamless experience
                try await AuthService.shared.login(username: username, password: password)
                isAuthenticated = true
            } catch {
                errorMessage = (error as? APIErrorResponse)?.detail ?? error.localizedDescription
            }
            isLoading = false
        }
    }

    func logout() {
        AuthService.shared.logout()
        isAuthenticated = false
        // Reset registration state so Register screen starts fresh next time
        registrationSuccess = false
        errorMessage = nil
    }
}


