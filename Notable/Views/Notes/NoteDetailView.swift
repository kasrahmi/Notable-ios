import SwiftUI

struct NoteDetailView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    let note: Note
    @State private var showEdit = false
    @State private var lastEditedText: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(note.title).font(.largeTitle).bold()
                Text(note.description).font(.body)
                Text(lastEditedText)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(note.backgroundColor)
            .cornerRadius(16)
            .padding()
        }
        .navigationTitle("Note")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { updateLastEditedText() }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Edit") { showEdit = true }
                Button(action: { viewModel.deleteNote(id: note.id) }) {
                    Image(systemName: "trash")
                }
                .foregroundColor(.red)
            }
        }
        .sheet(isPresented: $showEdit) {
            NoteEditView(note: note) { updated in
                viewModel.updateNote(id: updated.id, title: updated.title, description: updated.description)
            }
        }
    }

    private func updateLastEditedText() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let when = max(note.createdAt, note.updatedAt)
        // If updatedAt equals createdAt (no edits yet), show created time
        let displayDate: Date = (note.updatedAt > note.createdAt) ? note.updatedAt : note.createdAt
        lastEditedText = (note.updatedAt > note.createdAt)
            ? "Last edited on \(formatter.string(from: displayDate))"
            : "Created on \(formatter.string(from: displayDate))"
    }
}


