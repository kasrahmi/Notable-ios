import SwiftUI

struct NoteDetailView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    let note: Note
    @State private var showEdit = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(note.title).font(.largeTitle).bold()
                Text(note.description).font(.body)
            }
            .padding()
            .background(note.backgroundColor)
            .cornerRadius(16)
            .padding()
        }
        .navigationTitle("Note")
        .navigationBarTitleDisplayMode(.inline)
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
}


