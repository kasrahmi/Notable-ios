import SwiftUI

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var keyboard: UIKeyboardType = .default

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(.gray)
            if isSecure {
                SecureField(placeholder, text: $text)
                    .keyboardType(keyboard)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}


