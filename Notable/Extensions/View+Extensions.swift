import SwiftUI

extension View {
    func fullWidth() -> some View { 
        self.frame(maxWidth: .infinity) 
    }

    func loadingOverlay(isLoading: Bool) -> some View {
        ZStack {
            self
            if isLoading {
                Color.black.opacity(0.2).ignoresSafeArea()
                ProgressView().progressViewStyle(CircularProgressViewStyle())
            }
        }
    }
}


