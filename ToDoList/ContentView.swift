//
//  ContentView.swift
//  ToDoList
//
//  Created by N L on 20. 8. 2025..
//

import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject var vm = TodoViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                SearchBar(text: $vm.searchText)
                    .padding(.horizontal, 16)
                
                List {
                    ForEach(vm.filteredTodos) { todo in
                        TodoRowView(todo: todo)
                            .listRowInsets(.init(top: 10, leading: 16, bottom: 10, trailing: 16))
                            .listRowSeparator(.visible)
                            .listRowSeparatorTint(.gray.opacity(0.4))
                            .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: vm.delete)
                }
                .listStyle(.plain)
                .background(Color.black)
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
            .toolbarBackground(.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .preferredColorScheme(.dark)
            .background(Color.black.ignoresSafeArea())
        }
        .statusBar(hidden: false)
    }
}
struct TodoRowView: View {
    let todo: Todo
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: todo.completed ? "checkmark.circle" : "circle")
                .font(.title3)
                .foregroundColor(.yellow)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(todo.title)
                    .font(.headline)
                    .foregroundColor(todo.completed ? .gray : .primary)
                    .strikethrough(todo.completed, color: .gray)
                
                if let d = todo.description, !d.isEmpty {
                    Text(d).font(.subheadline).foregroundColor(.secondary).lineLimit(2)
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
                .foregroundColor(.secondary)
            }
            Spacer()
        }
        .contentShape(Rectangle())
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
        .foregroundColor(.secondary)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.12))
        )
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
