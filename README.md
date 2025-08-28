[Читать на русском](./README.ru.md)

# ToDoList iOS App

A simple **ToDo list app** built with **SwiftUI** and **Core Data**.  
Supports creating, editing, deleting, searching tasks, and marking them as completed.

## ✨ Features
- Add new tasks  
- Edit and delete tasks  
- Search by title or description  
- Mark tasks as completed / in progress  
- Completed tasks show with strikethrough and checkmark  
- Share task details  

- On first launch the app seeds initial tasks from API  
- If API is unavailable or URL invalid → app still works offline with Core Data  
- Data stored in **Core Data**  
- Core Data operations run in background (UI never blocks)  
- Clean architecture: Views → ViewModel → Store → Core Data  

- Unit tests:
  - `TodoViewModel` with mock store  
  - `CoreDataTodoStore` with in-memory Core Data    


## Tech Stack
- Swift 5 / SwiftUI  
- Core Data  
- MVVM  
- XCTest  
- GCD / Core Data background context  


## Requirements
- Xcode 15+  
- iOS 16+  
