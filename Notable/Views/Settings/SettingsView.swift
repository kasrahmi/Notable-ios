import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showChangePassword = false

    var body: some View {
        List {
            Section(header: Text("Account")) {
                if let user = viewModel.user {
                    VStack(alignment: .leading) {
                        Text(user.email).bold()
                        Text("User ID: \(user.id)").font(.caption).foregroundColor(.secondary)
                    }
                } else if viewModel.isLoading {
                    LoadingView()
                } else if let err = viewModel.errorMessage { Text(err).foregroundColor(.red) }
            }
            Section {
                Button("Change Password", systemImage: "key.fill") { showChangePassword = true }
                Button("Logout", role: .destructive, action: authViewModel.logout)
            }
        }
        .onAppear { viewModel.loadUser() }
        .navigationTitle("Settings")
        .sheet(isPresented: $showChangePassword) { ChangePasswordView() }
    }
}


