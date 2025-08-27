//
//  EditTodoView.swift
//  ToDoList
//
//  Created by N L on 21. 8. 2025..
//

import SwiftUI
import CoreData

struct EditTodoView: View {
    @ObservedObject var todo: CDTodo  
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                
                TextField("To Do", text: Binding(
                    get: { todo.title ?? "" },
                    set: { todo.title = $0 }
                ))
                .font(.largeTitle.bold())
                .foregroundColor(Color.App.white)
                .padding(.horizontal)
                
                if let created = todo.createdAt {
                    Text(created.ddMMyyString)
                    .font(.subheadline)
                    .foregroundColor(Color.App.white.opacity(0.5))
                    .padding(.horizontal)
                }
                
                TextEditor(text: Binding(
                    get: { todo.details ?? "" },
                    set: { todo.details = $0 }
                ))
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
        do {
            try context.save()
        } catch {
            print("Ошибка сохранения:", error)
        }
        dismiss()
    }
}
