import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SettingsViewModel()
    @State private var current: String = ""
    @State private var newPass: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Current Password") { SecureField("Current", text: $current) }
                Section("New Password") { SecureField("New", text: $newPass) }
                if let msg = viewModel.passwordChangeMessage { Text(msg).foregroundColor(.green) }
                if let err = viewModel.errorMessage { Text(err).foregroundColor(.red) }
            }
            .navigationTitle("Change Password")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.changePassword(current: current, new: newPass)
                    }.disabled(current.isEmpty || newPass.count < 6)
                }
            }
        }
    }
}


