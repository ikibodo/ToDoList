//
//  ContentView.swift
//  ToDoList
//
//  Created by N L on 20. 8. 2025..
//

import SwiftUI

struct ToDoListView: View {
    @ObservedObject var vm: TodoViewModel
    
    @State private var editTodo: Todo?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                SearchBar(text: $vm.searchText)
                    .padding(.horizontal, 20)
                    .onChange(of: vm.searchText) { vm.search($0) }
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(vm.todos.enumerated()), id: \.element.id) { index, todo in
                            if index > 0 {
                                InsetDivider()
                                    .padding(.horizontal, 20)
                            }
                            
                            TodoRowView(
                                todo: todo,
                                onToggle: { vm.toggle(todo) },
                                onEdit:   { editTodo = todo },
                                onDelete: { vm.delete(todo) }
                            )
                            .padding(.top, 12)
                            .padding(.bottom, 12)
                            .padding(.horizontal, 20)
                            .background(Color.clear)
                        }
                    }
                }
                .background(Color.App.black)
            }
            .navigationTitle("Задачи")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        Text("\(vm.todos.count) Задач")
                            .foregroundColor(Color.App.white)
                        Spacer()
                        Button { vm.addTodo(title: "Новая задача")
                        } label: {
                            Image(systemName: "square.and.pencil")
                                .imageScale(.large)
                        }
                        .foregroundColor(Color.App.yellow)
                    }
                    .padding(.horizontal, 16)
                }
            }
            .toolbarBackground(Color.App.gray, for: .bottomBar)
            .toolbarBackground(.visible, for: .bottomBar)
            .background(Color.App.black.ignoresSafeArea(edges: .bottom))
        }
        .statusBar(hidden: false)
        .sheet(item: $editTodo, onDismiss: { vm.search(vm.searchText) }) { todo in
            EditTodoView(
                todo: todo,
                onSave: { updated in
                    vm.update(updated)
                }
            )
        }
    }
}

private struct InsetDivider: View {
    @Environment(\.displayScale) private var scale
    var body: some View {
        Rectangle()
            .fill(Color.App.white.opacity(0.5))
            .frame(height: 1 / scale)
    }
}

struct TodoRowView: View {
    let todo: Todo
    
    var onToggle: () -> Void = {}
    var onEdit:   () -> Void = {}
    var onDelete: () -> Void = {}
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .strokeBorder(
                    todo.completed ? Color.App.yellow : Color.App.stroke,
                    lineWidth: 1
                )
                .frame(width: 24, height: 24)
                .overlay {
                    if todo.completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(Color.App.yellow)
                    }
                }
                .onTapGesture { withAnimation { onToggle() } }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(todo.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(todo.completed ? Color.App.stroke : Color.App.white)
                    .strikethrough(todo.completed, color: Color.App.stroke)
                
                if let d = todo.description, !d.isEmpty {
                    Text(d)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(todo.completed ? Color.App.stroke : Color.App.white)
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
            ShareLink(item: todo.shareText) {
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
    let store = CoreDataTodoStore(viewContext: pc.container.viewContext)
    let vm = TodoViewModel(store: store)
    
    ToDoListView(vm: vm)
}
