//
//  TodoViewModel.swift
//  ToDoList
//
//  Created by N L on 20. 8. 2025..
//

import Foundation

@MainActor
final class TodoViewModel: ObservableObject {
    @Published var todos: [Todo] = []
    @Published var searchText = ""

    private let apiURL = URL(string: "https://dummyjson.com/todos")!

    init() { loadTodos() }

    func loadTodos() {
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: apiURL)
                let remote = try JSONDecoder().decode(RemoteTodoResponse.self, from: data)
                let now = Date()
                self.todos = remote.todos.map {
                    Todo(id: $0.id, title: $0.todo, description: nil, completed: $0.completed, createdAt: now)
                }
            } catch { print("Load error:", error) }
        }
    }

    func addTodo(title: String, description: String? = nil) {
        let new = Todo(id: (todos.map{$0.id}.max() ?? 0) + 1,
                       title: title, description: description,
                       completed: false, createdAt: Date())
        todos.insert(new, at: 0)
    }

    func delete(at offsets: IndexSet) { todos.remove(atOffsets: offsets) }

    var filteredTodos: [Todo] {
        guard !searchText.isEmpty else { return todos }
        return todos.filter { $0.title.lowercased().contains(searchText.lowercased()) }
    }
}
