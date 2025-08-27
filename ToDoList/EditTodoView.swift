//
//  EditTodoView.swift
//  ToDoList
//
//  Created by N L on 21. 8. 2025..
//

import SwiftUI

struct EditTodoView: View {
    let todo: Todo
    var onSave: (Todo) -> Void = { _ in }
    
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var details: String
    
    init(todo: Todo, onSave: @escaping (Todo) -> Void = { _ in }) {
        self.todo = todo
        self.onSave = onSave
        _title = State(initialValue: todo.title)
        _details = State(initialValue: todo.description ?? "")
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                
                TextField("To Do", text: $title)
                .font(.largeTitle.bold())
                .foregroundColor(Color.App.white)
                .padding(.horizontal)

                Text(todo.displayDateString)
                    .font(.subheadline)
                    .foregroundColor(Color.App.white.opacity(0.5))
                    .padding(.horizontal)

                TextEditor(text: $details)
                .font(.body)
                .foregroundColor(Color.App.white)
                .scrollContentBackground(.hidden)
                .padding(.horizontal)
            }
            .padding(.top)
            .background(Color.App.black.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        saveAndClose()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                            Text("Назад")
                        }
                    }
                }
            }
        }
        .tint(Color.App.yellow)
    }
    
    private func saveAndClose() {
        var updated = todo
        let trimmed = details.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.title = title
        updated.description = trimmed.isEmpty ? nil : trimmed
        onSave(updated)
        dismiss()
    }
}
