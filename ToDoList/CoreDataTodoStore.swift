//
//  CoreDataTodoStore.swift
//  ToDoList
//
//  Created by N L on 27. 8. 2025..
//

import Foundation
import CoreData

@MainActor
final class CoreDataTodoStore: TodoStore {
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.viewContext.automaticallyMergesChangesFromParent = true
        self.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }
    
    // MARK: - TodoStore
    
    func load(query: String?) throws -> [Todo] {
        let request: NSFetchRequest<CDTodo> = CDTodo.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \CDTodo.createdAt, ascending: false)
        ]
        request.predicate = makeSearchPredicate(query)
        
        let objects = try viewContext.fetch(request)
        return objects.map { $0.toDomain() }
    }
    
    @discardableResult
    func add(title: String, description: String?) throws -> Todo {
        let obj = CDTodo(context: viewContext)
        obj.id = Int64(generateLocalId())
        obj.title = title
        obj.details = description
        obj.completed = false
        obj.createdAt = Date()
        
        try saveIfNeeded()
        return obj.toDomain()
    }
    
    func update(_ todo: Todo) throws {
        guard let obj = try fetchOne(by: todo.id) else {
            throw NSError(domain: "CoreDataTodoStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Todo not found"])
        }
        obj.apply(from: todo)
        try saveIfNeeded()
    }
    
    func toggle(id: Int) throws {
        guard let obj = try fetchOne(by: id) else {
            throw NSError(domain: "CoreDataTodoStore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Todo not found"])
        }
        obj.completed.toggle()
        try saveIfNeeded()
    }
    
    func delete(id: Int) throws {
        guard let obj = try fetchOne(by: id) else {
            return
        }
        viewContext.delete(obj)
        try saveIfNeeded()
    }
    
    func get(id: Int) throws -> Todo? {
        try fetchOne(by: id)?.toDomain()
    }
    
    // MARK: - Helpers
    
    private func saveIfNeeded() throws {
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }
    
    private func fetchOne(by id: Int) throws -> CDTodo? {
        let r: NSFetchRequest<CDTodo> = CDTodo.fetchRequest()
        r.fetchLimit = 1
        r.predicate = NSPredicate(format: "id == %d", id)
        return try viewContext.fetch(r).first
    }
    
    private func makeSearchPredicate(_ query: String?) -> NSPredicate? {
        guard let q = query?.trimmingCharacters(in: .whitespacesAndNewlines), !q.isEmpty else {
            return nil
        }
        return NSPredicate(format: "title CONTAINS[cd] %@ OR details CONTAINS[cd] %@", q, q)
    }
    
    private func generateLocalId() -> Int {
        Int(Date().timeIntervalSince1970 * 1000)
    }
}

private extension CDTodo {
    func toDomain() -> Todo {
        Todo(
            id: Int(self.id),
            title: self.title ?? "",
            description: self.details,
            completed: self.completed,
            createdAt: self.createdAt ?? Date()
        )
    }
    
    func apply(from domain: Todo) {
        self.id = Int64(domain.id)
        self.title = domain.title
        self.details = domain.description
        self.completed = domain.completed
        self.createdAt = domain.createdAt
    }
}
