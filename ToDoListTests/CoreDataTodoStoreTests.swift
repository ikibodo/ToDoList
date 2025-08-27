//
//  CoreDataTodoStoreTests.swift
//  ToDoListTests
//
//  Created by N L on 27. 8. 2025..
//

import XCTest
import CoreData
@testable import ToDoList

@MainActor
final class CoreDataTodoStoreTests: XCTestCase {

    private func makeInMemoryStore() -> CoreDataTodoStore {
        let pc = PersistenceController(inMemory: true)
        return CoreDataTodoStore(viewContext: pc.container.viewContext)
    }

    func test_add_and_load() throws {
        let store = makeInMemoryStore()

        _ = try store.add(title: "One", description: "A")
        _ = try store.add(title: "Two", description: nil)

        let all = try store.load(query: nil)
        XCTAssertEqual(all.count, 2)
        XCTAssertEqual(all.first?.title, "Two")
    }

    func test_search() throws {
        let store = makeInMemoryStore()

        _ = try store.add(title: "Buy milk", description: "2L")
        _ = try store.add(title: "Walk dog", description: nil)

        let milk = try store.load(query: "milk")
        XCTAssertEqual(milk.count, 1)
        XCTAssertEqual(milk.first?.title, "Buy milk")

        let dog = try store.load(query: "dog")
        XCTAssertEqual(dog.count, 1)
        XCTAssertEqual(dog.first?.title, "Walk dog")
    }

    func test_update() throws {
        let store = makeInMemoryStore()
        let t = try store.add(title: "Old", description: nil)

        var updated = t
        updated.title = "New"
        updated.description = "Desc"
        try store.update(updated)

        let loaded = try store.load(query: "New")
        XCTAssertEqual(loaded.first?.title, "New")
        XCTAssertEqual(loaded.first?.description, "Desc")
    }

    func test_toggle() throws {
        let store = makeInMemoryStore()
        let t = try store.add(title: "Task", description: nil)

        try store.toggle(id: t.id)
        let reloaded = try store.load(query: "Task").first
        XCTAssertEqual(reloaded?.completed, true)

        try store.toggle(id: t.id)
        let reloaded2 = try store.load(query: "Task").first
        XCTAssertEqual(reloaded2?.completed, false)
    }

    func test_delete() throws {
        let store = makeInMemoryStore()
        let t1 = try store.add(title: "A", description: nil)
        _ = try store.add(title: "B", description: nil)

        try store.delete(id: t1.id)
        let all = try store.load(query: nil)
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.title, "B")
    }

    func test_mapping_roundtrip() throws {
        let store = makeInMemoryStore()
        let created = try store.add(title: "Round", description: "Trip")

        var u = created
        u.title = "Round 2"
        u.description = "Trip 2"
        u.completed = true
        try store.update(u)

        let loaded = try store.load(query: "Round 2").first
        XCTAssertEqual(loaded?.title, "Round 2")
        XCTAssertEqual(loaded?.description, "Trip 2")
        XCTAssertEqual(loaded?.completed, true)
    }
}
