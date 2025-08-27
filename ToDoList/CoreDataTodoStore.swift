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
    private let backgroundContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.viewContext.automaticallyMergesChangesFromParent = true
        self.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        
        guard let psc = viewContext.persistentStoreCoordinator else {
            fatalError("No persistentStoreCoordinator on viewContext")
        }
        let bg = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        bg.persistentStoreCoordinator = psc
        bg.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        self.backgroundContext = bg
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
        try performOnBackground {  [self] ctx in
            let obj = CDTodo(context: ctx)
            obj.id = Int64(generateLocalId())
            obj.title = title
            obj.details = description
            obj.completed = false
            obj.createdAt = Date()
            try ctx.save()
            return obj.toDomain()
        }
    }
    
    func update(_ todo: Todo) throws {
        try performOnBackground { ctx in
            guard let obj = try self.fetchOneBG(by: todo.id, in: ctx) else {
                throw NSError(domain:
                                "CoreDataTodoStore",
                              code: 404,
                              userInfo: [NSLocalizedDescriptionKey: "Todo not found"])
            }
            obj.apply(from: todo)
            try ctx.save()
            return ()
        }
    }
    
    func toggle(id: Int) throws {
        try performOnBackground { ctx in
            guard let obj = try self.fetchOneBG(by: id, in: ctx) else {
                throw NSError(domain: "CoreDataTodoStore",
                              code: 404,
                              userInfo: [NSLocalizedDescriptionKey: "Todo not found"])
            }
            obj.completed.toggle()
            try ctx.save()
            return ()
        }
    }
    
    func delete(id: Int) throws {
        try performOnBackground { ctx in
            guard let obj = try self.fetchOneBG(by: id, in: ctx) else { return () }
            ctx.delete(obj)
            try ctx.save()
            return ()
        }
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
        r.predicate = NSPredicate(format: "id == %@", NSNumber(value: id))
        return try viewContext.fetch(r).first
    }
    
    private func fetchOneBG(by id: Int, in ctx: NSManagedObjectContext) throws -> CDTodo? {
        let r: NSFetchRequest<CDTodo> = CDTodo.fetchRequest()
        r.fetchLimit = 1
        r.predicate = NSPredicate(format: "id == %@", NSNumber(value: id))
        return try ctx.fetch(r).first
    }
    
    private func performOnBackground<T>(_ work: @escaping (NSManagedObjectContext) throws -> T) throws -> T {
        var result: Result<T, Error>?
        backgroundContext.performAndWait {
            do {
                let value = try work(self.backgroundContext)
                result = .success(value)
            } catch {
                result = .failure(error)
            }
        }
        
        viewContext.performAndWait {
            self.viewContext.refreshAllObjects()
        }
        
        switch result {
        case .success(let value): return value
        case .failure(let error): throw error
        case .none:
            throw NSError(domain: "CoreDataTodoStore",
                          code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "No result from background operation"]
            )
        }
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
