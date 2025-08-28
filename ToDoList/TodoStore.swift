//
//  TodoStore.swift
//  ToDoList
//
//  Created by N L on 27. 8. 2025..
//

import Foundation

@MainActor
protocol TodoStore {
    func load(query: String?) throws -> [Todo]
    
    @discardableResult
    func add(title: String, description: String?) throws -> Todo
    
    @discardableResult
    func add(todo: Todo) throws -> Todo

    func update(_ todo: Todo) throws

    func toggle(id: Int) throws

    func delete(id: Int) throws
    
    func get(id: Int) throws -> Todo? 
}
