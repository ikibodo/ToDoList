//
//  Todo.swift
//  ToDoList
//
//  Created by N L on 20. 8. 2025..
//

import Foundation

struct Todo: Identifiable, Equatable {
    let id: Int
    var title: String
    var description: String?
    var completed: Bool
    var createdAt: Date
}

struct RemoteTodoResponse: Decodable {
    let todos: [RemoteTodo]
}

struct RemoteTodo: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
}
