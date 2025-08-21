//
//  ContentView.swift
//  ToDoList
//
//  Created by N L on 20. 8. 2025..
//

import SwiftUI
import CoreData

struct ToDoListView: View {
    @StateObject var vm = TodoViewModel()
    
    @State private var editTodo: Todo?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                SearchBar(text: $vm.searchText)
                    .padding(.horizontal, 20)
                
                List {
                    ForEach(vm.filteredTodos) { todo in
                        TodoRowView(
                            todo: todo,
                            onEdit: { editTodo = todo },
                            onShare: { share(todo) },
                            onDelete: { delete(todo) }
                        )
                            .listRowInsets(.init(top: 16, leading: 20, bottom: 12, trailing: 20))
                            .listRowSeparator(.visible)
                            .listRowSeparatorTint(Color.App.white.opacity(0.5))
                            .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: vm.delete)
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
                        Text("\(vm.filteredTodos.count) Задач")
                            .foregroundColor(.white.opacity(0.9))
                        Spacer()
                        Button(action: { /* TO DO */ }) {
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
        .sheet(item: $editTodo) { todo in
            EditTodoView(todo: todo)
        }
    }
    
    private func share(_ todo: Todo) {
        print("Share tapped for \(todo.title)")
    }

    private func delete(_ todo: Todo) {
        print("Delete tapped for \(todo.title)")
    }
}

struct TodoRowView: View {
    let todo: Todo
    
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
                Text(todo.title)
                    .font(.headline)
                    .foregroundColor(todo.completed ? Color.App.textSecondary : Color.App.textPrimary)
                    .strikethrough(todo.completed, color: Color.App.stroke)
                
                if let d = todo.description, !d.isEmpty {
                    Text(d)
                        .font(.subheadline)
                        .foregroundColor(Color.App.textSecondary)
                        .lineLimit(2)
                }
                Text(
                    todo.createdAt.formatted(
                        Date.VerbatimFormatStyle(
                            format: "dd/MM/yy",
                            timeZone: .current,
                            calendar: .current
                        )
                    )
                )
                .font(.caption)
                .foregroundColor(Color.App.textSecondary)
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
    ToDoListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
