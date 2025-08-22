//
//  TodoViewModel.swift
//  ToDoList
//
//  Created by N L on 20. 8. 2025..
//

import Foundation
import CoreData

@MainActor
final class TodoViewModel: ObservableObject {

    @Published var searchText = ""

    private let context: NSManagedObjectContext
    private let apiURL = URL(string: "https://dummyjson.com/todos")!
    private let seededKey = "seeded_v1"
    
    init(context: NSManagedObjectContext) {
        self.context = context
        ensureSeededIfNeeded()
    }

    func predicate(for text: String) -> NSPredicate? {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !t.isEmpty else { return nil }
        return NSPredicate(
            format: "title CONTAINS[cd] %@ OR details CONTAINS[cd] %@",
            t, t
        )
    }

    // MARK: - CRUD
    func addTodo(title: String, details: String? = nil) {
        let todo = CDTodo(context: context)
        todo.id = Int64(Date().timeIntervalSince1970)
        todo.title = title
        todo.details = details
        todo.completed = false
        todo.createdAt = Date()
        saveSilently()
    }

    func toggle(_ todo: CDTodo) {
        todo.completed.toggle()
        saveSilently()
    }

    func delete(_ todo: CDTodo) {
        context.delete(todo)
        saveSilently()
    }

    func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }

    private func saveSilently() {
        do { try save() } catch {
            print("CoreData save error:", error)
        }
    }

    // MARK: - Первый запуск: импорт из API → Core Data
    private func ensureSeededIfNeeded() {
        if UserDefaults.standard.bool(forKey: seededKey) { return }

        let req: NSFetchRequest<CDTodo> = CDTodo.fetchRequest()
        req.fetchLimit = 1
        do {
            if try context.count(for: req) > 0 {
                UserDefaults.standard.set(true, forKey: seededKey) // уже есть данные
                return
            }
        } catch {  }

        Task { await importFromAPI() }
    }

    private func importFromAPI() async {
        do {
            let (data, _) = try await URLSession.shared.data(from: apiURL)
            let remote = try JSONDecoder().decode(RemoteTodoResponse.self, from: data)
            let now = Date()

            context.performAndWait {
                for r in remote.todos {
                    let fr: NSFetchRequest<CDTodo> = CDTodo.fetchRequest()
                    fr.fetchLimit = 1
                    fr.predicate = NSPredicate(format: "id == %d", r.id)

                    let obj: CDTodo
                    if let existing = (try? context.fetch(fr))?.first {
                        obj = existing
                    } else {
                        obj = CDTodo(context: context)
                        obj.id = Int64(r.id)
                        obj.createdAt = now
                    }

                    obj.title = r.todo
                    obj.details = nil
                    obj.completed = r.completed
                }
                do { try context.save() } catch {
                    print("Seed save error:", error)
                }
            }

            UserDefaults.standard.set(true, forKey: seededKey)
        } catch {
            print("Import error:", error)
        }
    }
}
