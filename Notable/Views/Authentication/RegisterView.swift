import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var username: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Register").font(.largeTitle).bold().frame(maxWidth: .infinity, alignment: .leading)
            CustomTextField(icon: "person.fill", placeholder: "Username", text: $username)
            CustomTextField(icon: "envelope.fill", placeholder: "Email", text: $email, keyboard: .emailAddress)
            CustomTextField(icon: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
            HStack {
                CustomTextField(icon: "textformat", placeholder: "First name", text: $firstName)
                CustomTextField(icon: "textformat", placeholder: "Last name", text: $lastName)
            }
            if let error = authViewModel.errorMessage { Text(error).foregroundColor(.red).frame(maxWidth: .infinity, alignment: .leading) }
            CustomButton(title: authViewModel.isLoading ? "Registering..." : "Create account", action: {
                authViewModel.register(username: username, password: password, email: email, firstName: firstName, lastName: lastName)
            }, disabled: authViewModel.isLoading || username.isEmpty || !email.contains("@") || password.count < 6)
        }
        .padding()
        .onReceive(authViewModel.$errorMessage) { _ in }
    }
}


