import SwiftUI

struct OnboardingView: View {
    @State private var goToLogin = false
    @State private var goToRegister = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                Image(systemName: "note.text").resizable().scaledToFit().frame(width: 96, height: 96).foregroundColor(.indigo)
                Text("Welcome to Notable").font(.largeTitle).bold()
                Text("A clean, modern note-taking app").foregroundColor(.secondary)
                Spacer()
                NavigationLink("Login") { LoginView() }
                    .buttonStyle(.borderedProminent)
                NavigationLink("Register") { RegisterView() }
                    .buttonStyle(.bordered)
                Spacer(minLength: 32)
            }
            .padding()
        }
    }
}


