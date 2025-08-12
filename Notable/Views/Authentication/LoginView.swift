import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var username: String = ""
    @State private var password: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Login").font(.largeTitle).bold().frame(maxWidth: .infinity, alignment: .leading)
            
            // Connection status
            HStack {
                Text("Connection:")
                Text(authViewModel.connectionStatus)
                    .foregroundColor(authViewModel.connectionStatus == "Connected" ? .green : 
                                   authViewModel.connectionStatus == "Failed to connect" ? .red : .orange)
                Spacer()
                Button("Test") {
                    Task {
                        await authViewModel.testConnection()
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            CustomTextField(icon: "at", placeholder: "Username", text: $username)
            CustomTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
            if let error = authViewModel.errorMessage { Text(error).foregroundColor(.red).frame(maxWidth: .infinity, alignment: .leading) }
            CustomButton(title: authViewModel.isLoading ? "Logging in..." : "Login", action: {
                authViewModel.login(username: username, password: password)
            }, disabled: authViewModel.isLoading || username.isEmpty || password.count < 6)
        }
        .padding()
        .onChange(of: authViewModel.isAuthenticated) { _, new in if new { dismiss() } }
        .onAppear {
            Task {
                await authViewModel.testConnection()
            }
        }
    }
}


