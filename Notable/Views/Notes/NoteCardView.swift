import SwiftUI

struct NoteCardView: View {
    let note: Note
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.title).font(.headline).foregroundColor(.black)
            Text(note.description).font(.subheadline).foregroundColor(.black.opacity(0.8)).lineLimit(4)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(note.backgroundColor)
        .cornerRadius(16)
        .onTapGesture(perform: onTap)
    }
}


