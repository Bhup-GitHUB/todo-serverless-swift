import Foundation

enum APIConfig {
    static let baseURL = URL(string: "http://localhost:8787")!

    static let todos = "/todos"
    static let addTodo = "/add-todo"
    static let deleteTodo = "/delete-todo"
    static let updateTodo = "/update-todo"
}
