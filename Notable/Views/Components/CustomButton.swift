import SwiftUI

struct CustomButton: View {
    let title: String
    let action: () -> Void
    var disabled: Bool = false

    var body: some View {
        Button(action: action) {
            Text(title).bold().frame(maxWidth: .infinity).padding()
                .background(disabled ? Color.gray.opacity(0.4) : Color.indigo)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(disabled)
    }
}


