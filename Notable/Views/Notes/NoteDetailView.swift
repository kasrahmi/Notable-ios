import SwiftUI

struct NoteDetailView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    let note: Note
    @State private var showEdit = false
    @State private var lastEditedText: String = ""
    @State private var showDeleteAlert = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            // Note content
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
            
            // BIG RED DELETE BUTTON - VERY VISIBLE
            Button(action: { showDeleteAlert = true }) {
                VStack {
                    Image(systemName: "trash")
                        .font(.title)
                    Text("DELETE NOTE")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(Color.red)
                .cornerRadius(16)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Note")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { updateLastEditedText() }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button("Edit") { showEdit = true }
                Button(action: { showDeleteAlert = true }) {
                    Image(systemName: "trash")
                }
                .foregroundColor(.red)
            }
        }
        .alert("Delete Note", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                viewModel.deleteNote(id: note.id)
                dismiss()
            }
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
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
        // If updatedAt equals createdAt (no edits yet), show created time
        let hasEdits = note.updatedAt.timeIntervalSince1970 > note.createdAt.timeIntervalSince1970 + 1 // allow small parsing diffs
        let displayDate: Date = hasEdits ? note.updatedAt : note.createdAt
        lastEditedText = hasEdits
            ? "Last edited on \(formatter.string(from: displayDate))"
            : "Created on \(formatter.string(from: displayDate))"
    }
}


