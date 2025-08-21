//
//  EditTodoView.swift
//  ToDoList
//
//  Created by N L on 21. 8. 2025..
//

import SwiftUI

struct EditTodoView: View {
    let todo: Todo
    
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var description: String
    
    init(todo: Todo) {
        self.todo = todo
        _title = State(initialValue: todo.title)
        _description = State(initialValue: todo.description ?? "")
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                
                TextField("To Do", text: $title)
                    .font(.largeTitle.bold())
                    .foregroundColor(Color.App.white)
                    .padding(.horizontal)
                
                Text(
                    todo.createdAt.formatted(
                        Date.VerbatimFormatStyle(
                            format: "dd/MM/yy",
                            timeZone: .current,
                            calendar: .current
                        )
                    )
                )
                .font(.subheadline)
                .foregroundColor(Color.App.white.opacity(0.5))
                .padding(.horizontal)
                
                TextEditor(text: $description)
                    .font(.body)
                    .foregroundColor(Color.App.white)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal)
            }
            .padding(.top)
            .background(Color.App.black.ignoresSafeArea())
            .navigationTitle("")
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
        // TODO: сохранение
        dismiss()
    }
}

//#Preview {
//    EditTodoView()
//}
