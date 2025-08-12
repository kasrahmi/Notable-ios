import SwiftUI

struct EmptyHomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.and.pencil").font(.system(size: 56)).foregroundColor(.gray.opacity(0.6))
            Text("Create your first note").font(.title3).bold().foregroundColor(.gray)
            Text("Tap the + button below to add a note.").foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


