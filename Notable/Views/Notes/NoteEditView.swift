import SwiftUI

struct NoteEditView: View {
    var note: Note?
    var onSave: (Note) -> Void
    var onDelete: ((String) -> Void)?
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var showDeleteAlert = false

    init(note: Note?, onSave: @escaping (Note) -> Void, onDelete: ((String) -> Void)? = nil) {
        self.note = note
        self.onSave = onSave
        self.onDelete = onDelete
        _title = State(initialValue: note?.title ?? "")
        _description = State(initialValue: note?.description ?? "")
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                // Top bar: Back and Save (Android-like)
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 8) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.indigo)
                            Text("Back")
                                .foregroundColor(.indigo)
                        }
                    }

                    Spacer()

                    Button(action: saveNote) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.indigo)
                            Text("Save")
                                .foregroundColor(.indigo)
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.vertical, 8)

                // Title field (large, bold)
                TextField("Title", text: $title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .tint(.indigo)

                // Content field
                TextEditor(text: $description)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .tint(.indigo)
                    .frame(minHeight: 160)
                    .padding(.top, 4)

                Spacer(minLength: 20)

                // Delete button - BIG AND VISIBLE
                if let note = note {
                    Button(action: { showDeleteAlert = true }) {
                        VStack {
                            Image(systemName: "trash")
                                .font(.title2)
                            Text("DELETE NOTE")
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.red)
                        .cornerRadius(12)
                    }
                }

                // Bottom row: last edited (if available)
                if let updatedAt = (note?.updatedAt ?? Date()).formattedTime() {
                    HStack {
                        Text("Last edited on \(updatedAt)")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                }
            }
            .padding(16)
        }
        .alert("Delete Note", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let note = note {
                    onDelete?(note.id)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to delete this note? This action cannot be undone.")
        }
    }

    private func saveNote() {
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
    }
}

private extension Date {
    func formattedTime() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}

