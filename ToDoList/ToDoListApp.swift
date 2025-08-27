//
//  ToDoListApp.swift
//  ToDoList
//
//  Created by N L on 20. 8. 2025..
//

import SwiftUI

@main
struct ToDoListApp: App {
    let persistenceController = PersistenceController.shared
    let store: TodoStore
    @StateObject var vm: TodoViewModel

    init() {
        let s = CoreDataTodoStore(viewContext: persistenceController.container.viewContext)
        self.store = s
        _vm = StateObject(wrappedValue: TodoViewModel(store: s))

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.App.black)

        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.App.white),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        let navBar = UINavigationBar.appearance()
        navBar.standardAppearance = appearance
        navBar.scrollEdgeAppearance = appearance
        navBar.compactAppearance = appearance
        navBar.tintColor = UIColor(Color.App.white) 
    }
    
    var body: some Scene {
        WindowGroup {
            ToDoListView(vm: vm)
        }
    }
}
