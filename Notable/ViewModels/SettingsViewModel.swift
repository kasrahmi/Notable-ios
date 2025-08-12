import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var passwordChangeMessage: String?

    func loadUser() {
        isLoading = true
        Task { @MainActor in
            defer { isLoading = false }
            do {
                user = try await AuthService.shared.getUserInfo()
            } catch { errorMessage = error.localizedDescription }
        }
    }

    func changePassword(current: String, new: String) {
        isLoading = true
        Task { @MainActor in
            defer { isLoading = false }
            do {
                try await AuthService.shared.changePassword(current: current, new: new)
                passwordChangeMessage = "Password changed successfully"
            } catch { errorMessage = error.localizedDescription }
        }
    }
}


