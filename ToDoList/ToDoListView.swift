//
//  ContentView.swift
//  ToDoList
//
//  Created by N L on 20. 8. 2025..
//

import SwiftUI
import CoreData

struct ToDoListView: View {
    @ObservedObject var vm: TodoViewModel
    @Environment(\.managedObjectContext) private var context
    @State private var editTodo: CDTodo?
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \CDTodo.createdAt, ascending: false)],
        animation: .default
    )
    
    private var todos: FetchedResults<CDTodo>
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                SearchBar(text: $vm.searchText)
                    .padding(.horizontal, 20)
                    .onChange(of: vm.searchText) { newValue in
                        todos.nsPredicate = vm.predicate(for: newValue)
                    }
                
                List {
                    ForEach(todos) { todo in
                        TodoRowView(
                            todo: todo,
                            onEdit: { editTodo = todo },
                            onShare: { share(todo) },
                            onDelete: { vm.delete(todo) }
                        )
                            .listRowInsets(.init(top: 16, leading: 20, bottom: 12, trailing: 20))
                            .listRowSeparator(.visible)
                            .listRowSeparatorTint(Color.App.white.opacity(0.5))
                            .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: deleteOffsets)
                }
                .listStyle(.plain)
                .background(Color.App.black)
            }
            .navigationTitle("Задачи")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        Text("\(todos.count) Задач")
                            .foregroundColor(Color.App.white)
                        Spacer()
                        Button { vm.addTodo(title: "Новая задача")
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .imageScale(.large)
                        }
                        .foregroundColor(.yellow)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .toolbarBackground(Color.App.gray, for: .bottomBar)
            .toolbarBackground(.visible, for: .bottomBar)
            .background(Color.App.black.ignoresSafeArea(edges: .bottom))
        }
        .statusBar(hidden: false)
        .sheet(item: $editTodo) {
            EditTodoView(todo: $0)
        }
    }

    private func share(_ todo: CDTodo) {
        print("Share tapped for \(todo.title ?? "")")
    }

    private func deleteOffsets(_ offsets: IndexSet) {
        offsets.map { todos[$0] }.forEach(vm.delete)
    }
}

struct TodoRowView: View {
    let todo: CDTodo
    
    var onEdit: () -> Void = {}
    var onShare: () -> Void = {}
    var onDelete: () -> Void = {}
    
    @Environment(\.displayScale) private var scale
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: todo.completed ? "checkmark.circle" : "circle")
                .font(.title3)
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(todo.title ?? "")
                    .font(.headline)
                    .foregroundColor(todo.completed ? Color.App.stroke : Color.App.white)
                    .strikethrough(todo.completed, color: Color.App.stroke)

                if let d = todo.details, !d.isEmpty {
                    Text(d)
                        .font(.subheadline)
                        .foregroundColor(Color.App.white)
                        .lineLimit(2)
                }
                
                Text(todo.displayDateString)
                    .font(.caption)
                    .foregroundColor(Color.App.stroke)

            }
            Spacer()
        }
        .contentShape(Rectangle())
        .contextMenu {
            Button(action: onEdit) {
                Label("Редактировать", systemImage: "square.and.pencil")
            }
            Button(action: onShare) {
                Label("Поделиться", systemImage: "square.and.arrow.up")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Удалить", systemImage: "trash")
            }
            .foregroundColor(Color.App.stroke)
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var micTap: () -> Void = {}
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text("Search")
                }
                TextField("", text: $text)
            }
            Button(action: micTap) {
                Image(systemName: "mic.fill")
                
            }
        }
        .foregroundColor(Color.App.white.opacity(0.5))
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.App.gray)
        )
    }
}

#Preview {
    let pc = PersistenceController.preview
    let vm = TodoViewModel(context: pc.container.viewContext)
    ToDoListView(vm: vm)
        .environment(\.managedObjectContext, pc.container.viewContext)
}
