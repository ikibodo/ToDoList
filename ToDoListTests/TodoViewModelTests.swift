//
//  TodoViewModelTests.swift
//  ToDoListTests
//
//  Created by N L on 27. 8. 2025..
//

import XCTest
@testable import ToDoList

@MainActor
final class TodoViewModelTests: XCTestCase {

    // MARK: - Mock Store

    final class MockTodoStore: TodoStore {
        private(set) var items: [Todo] = []
        private var lastId: Int = 0 
        
        private func nextId() -> Int {
            lastId += 1
            return lastId
        }

        func load(query: String?) throws -> [Todo] {
            guard let q = query?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !q.isEmpty else { return items }
            return items.filter {
                $0.title.localizedCaseInsensitiveContains(q) ||
                ($0.description?.localizedCaseInsensitiveContains(q) ?? false)
            }
        }

        @discardableResult
        func add(title: String, description: String?) throws -> Todo {
            let t = Todo(
                id: nextId(),
                title: title,
                description: description,
                completed: false,
                createdAt: Date()
            )
            items.insert(t, at: 0)
            return t
        }
        
        @discardableResult
        func add(todo: ToDoList.Todo) throws -> ToDoList.Todo {
            items.insert(todo, at: 0)
            return todo
        }

        func update(_ todo: Todo) throws {
            if let idx = items.firstIndex(where: { $0.id == todo.id }) {
                items[idx] = todo
            } else {
                items.append(todo)
            }
        }

        func toggle(id: Int) throws {
            guard let i = items.firstIndex(where: { $0.id == id }) else {
                throw NSError(domain: "MockTodoStore", code: 404)
            }
            items[i].completed.toggle()
        }

        func delete(id: Int) throws {
            items.removeAll { $0.id == id }
        }

        func get(id: Int) throws -> Todo? {
            items.first(where: { $0.id == id })
        }
    }

    // MARK: - Tests

    func test_add_toggle_delete_and_search_in_viewModel() throws {
        let store = MockTodoStore()
        let vm = TodoViewModel(store: store)

        vm.addTodo(title: "Buy milk", details: "2L")
        vm.addTodo(title: "Walk dog")
        XCTAssertEqual(vm.todos.count, 2)

        vm.search("milk")
        XCTAssertEqual(vm.todos.count, 1)
        XCTAssertEqual(vm.todos.first?.title, "Buy milk")

        guard let item = vm.todos.first else { return XCTFail("No item") }
        let id = item.id
        vm.toggle(item)

        vm.search("")
        let toggled = vm.todos.first(where: { $0.id == id })
        XCTAssertEqual(toggled?.completed, true)

        vm.delete(item)

        vm.search("")
        XCTAssertFalse(vm.todos.contains(where: { $0.id == id }))
    }

    func test_update_in_viewModel() throws {
        let store = MockTodoStore()
        let vm = TodoViewModel(store: store)

        vm.addTodo(title: "Title", details: nil)
        guard var t = vm.todos.first else { return XCTFail("No item") }
        let id = t.id

        t.title = "Updated"
        t.description = "Desc"
        vm.update(t)

        let reloaded = vm.todos.first(where: { $0.id == id })
        XCTAssertEqual(reloaded?.title, "Updated")
        XCTAssertEqual(reloaded?.description, "Desc")
    }
    
    func test_ids_are_unique_when_adding_multiple_todos() throws {
        let store = MockTodoStore()
        let vm = TodoViewModel(store: store)

        vm.addTodo(title: "Task 1")
        vm.addTodo(title: "Task 2")

        let ids = vm.todos.map { $0.id }
        let uniqueIDs = Set(ids)

        XCTAssertEqual(ids.count, uniqueIDs.count, "IDs must be unique for each todo")
    }
}
