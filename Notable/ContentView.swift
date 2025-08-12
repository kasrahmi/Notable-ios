import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .onAppear {
            authViewModel.bootstrapAuthenticationState()
        }
    }
}

private struct MainTabView: View {
    @StateObject private var notesViewModel = NotesViewModel()

    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
                    .environmentObject(notesViewModel)
            }
            .tabItem { 
                Label("Home", systemImage: "house.fill") 
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem { 
                Label("Settings", systemImage: "gearshape.fill") 
            }
        }
    }
}


