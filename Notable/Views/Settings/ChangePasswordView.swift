import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SettingsViewModel()
    @State private var current: String = ""
    @State private var newPass: String = ""

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
                    }.disabled(current.isEmpty || newPass.count < 8)
                }
            }
        }
    }
}


