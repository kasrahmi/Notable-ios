import SwiftUI

struct NoteEditView: View {
    var note: Note?
    var onSave: (Note) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var description: String = ""

    init(note: Note?, onSave: @escaping (Note) -> Void) {
        self.note = note
        self.onSave = onSave
        _title = State(initialValue: note?.title ?? "")
        _description = State(initialValue: note?.description ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Title")) {
                    TextField("Note title", text: $title)
                }
                Section(header: Text("Description")) {
                    TextEditor(text: $description).frame(minHeight: 200)
                }
            }
            .navigationTitle(note == nil ? "New Note" : "Edit Note")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let model = Note(
                            id: note?.id ?? UUID().uuidString,
                            title: title,
                            description: description,
                            backgroundColorHex: note?.backgroundColorHex ?? Note.randomColorHex(),
                            createdAt: note?.createdAt ?? Date(),
                            updatedAt: Date()
                        )
                        onSave(model)
                        dismiss()
                    }.disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}


