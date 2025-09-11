import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SettingsViewModel()
    @State private var current: String = ""
    @State private var newPass: String = ""
    @State private var confirmPass: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Current Password") { 
                    SecureField("Current", text: $current)
                        .onChange(of: current) { _ in
                            viewModel.passwordChangeMessage = nil
                            viewModel.errorMessage = nil
                        }
                }
                Section("New Password (min 8 characters)") { 
                    SecureField("New", text: $newPass)
                        .onChange(of: newPass) { _ in
                            viewModel.passwordChangeMessage = nil
                            viewModel.errorMessage = nil
                        }
                    SecureField("Confirm new password", text: $confirmPass)
                        .onChange(of: confirmPass) { _ in
                            viewModel.passwordChangeMessage = nil
                            viewModel.errorMessage = nil
                        }
                    if !confirmPass.isEmpty && confirmPass != newPass {
                        Text("Passwords do not match").foregroundColor(.red)
                    }
                }
                if let msg = viewModel.passwordChangeMessage { Text(msg).foregroundColor(.green) }
                if let err = viewModel.errorMessage { Text(err).foregroundColor(.red) }
            }
            .navigationTitle("Change Password")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.changePassword(current: current, new: newPass)
                    }.disabled(current.isEmpty || newPass.count < 8 || newPass != confirmPass)
                }
            }
            .onChange(of: viewModel.passwordChangeMessage) { msg in
                // Dismiss on success
                if msg != nil { dismiss() }
            }
        }
    }
}


