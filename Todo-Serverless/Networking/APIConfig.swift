import Foundation

enum APIConfig {
    static let baseURL = URL(string: "https://my-next-app.4bhupeshkumar.workers.dev")!

    static let todos = "/api/todos"
    static let addTodo = "/api/add-todo"
    static let deleteTodo = "/api/delete-todo"
    static let updateTodo = "/api/update-todo"
}
