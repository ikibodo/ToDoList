//
//  TodoViewModel.swift
//  ToDoList
//
//  Created by N L on 20. 8. 2025..
//

import Foundation
 
@MainActor
final class TodoViewModel: ObservableObject {

    @Published var searchText = ""
    @Published private(set) var todos: [Todo] = []
    
    private let store: TodoStore
    private let apiURL = Constants.apiURL
    private let seededKey = Constants.seededKey
    
    init(store: TodoStore) {
        self.store = store
        ensureSeededIfNeeded()
        reload()
    }
    
    func search(_ text: String) {
        self.searchText = text
        reload(query: text)
    }
    
    // MARK: - CRUD
    
    func addTodo(title: String, details: String? = nil) {
        do {
            _ = try store.add(title: title, description: details)
            reload(query: searchText)
        } catch {
            print("Add error:", error)
        }
    }
    
    func toggle(_ todo: Todo) {
        do {
            try store.toggle(id: todo.id)
            reload(query: searchText)
        } catch {
            print("Toggle error:", error)
        }
    }
    
    func update(_ todo: Todo) {
        do {
            try store.update(todo)
            reload(query: searchText)
        } catch {
            print("Update error:", error)
        }
    }
    
    func delete(_ todo: Todo) {
        do {
            try store.delete(id: todo.id)
            reload(query: searchText)
        } catch {
            print("Delete error:", error)
        }
    }
    
    // MARK: - Loading
    
    private func reload(query: String? = nil) {
        do {
            todos = try store.load(query: normalized(query))
        } catch {
            print("Load error:", error)
            todos = []
        }
    }
    
    private func normalized(_ text: String?) -> String? {
        guard let t = text?.trimmingCharacters(in: .whitespacesAndNewlines), !t.isEmpty else { return nil }
        return t
    }
    
    // MARK: - Первый запуск: импорт из API → Store
    
    private func ensureSeededIfNeeded() {
        if UserDefaults.standard.bool(forKey: seededKey) { return }

        if (try? store.load(query: nil).isEmpty) == false {
            UserDefaults.standard.set(true, forKey: seededKey)
            return
        }

        Task { await importFromAPI() }
    }

    private func importFromAPI() async {
        guard let url = Constants.apiURL else {
            print("Invalid API URL")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let remote = try JSONDecoder().decode(RemoteTodoResponse.self, from: data)
            let now = Date()
            
            for r in remote.todos {
                let t = Todo(
                    id: r.id,
                    title: r.todo,
                    description: nil,
                    completed: r.completed,
                    createdAt: now
                )
                do {
                    if (try? store.get(id: r.id)) != nil {
                        try store.update(t)
                    } else {
                        _ = try store.add(todo: t)
                    }
                } catch {
                    print("Seed item error (id: \(r.id)):", error)
                }
            }
            
            UserDefaults.standard.set(true, forKey: seededKey)
                        reload()
        } catch {
            print("Import error:", error)
        }
    }
}
