import SwiftUI

struct NoteCardView: View {
    let note: Note
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(note.title)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(note.description)
                .font(.system(size: 12))
                .foregroundColor(.gray)
                .lineLimit(6)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200, alignment: .topLeading)
        .background(note.backgroundColor)
        .cornerRadius(12)
        .onTapGesture(perform: onTap)
    }
}


