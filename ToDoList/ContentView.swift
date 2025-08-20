//
//  ContentView.swift
//  ToDoList
//
//  Created by N L on 20. 8. 2025..
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var vm = TodoViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(vm.filteredTodos) { todo in
                    TodoRowView(todo: todo)
                }
                .onDelete(perform: vm.delete)
            }
            .navigationTitle("Задачи")
            .searchable(text: $vm.searchText)
            .toolbar {
                Button {
                    vm.addTodo(title: "Новая задача", description: "Описание")
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct TodoRowView: View {
    let todo: Todo
    
    var body: some View {
        HStack {
            Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                .foregroundColor(todo.completed ? .green : .gray)
            VStack(alignment: .leading) {
                Text(todo.title).bold()
                if let desc = todo.description {
                    Text(desc).font(.subheadline).foregroundColor(.gray)
                }
            }
            Spacer()
            Text(todo.createdAt, style: .date)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
