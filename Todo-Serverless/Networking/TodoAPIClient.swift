import Foundation

protocol TodoServicing {
    func fetchTodos() async throws -> [Todo]
    func addTodo(title: String) async throws -> Todo
    func deleteTodo(id: String) async throws
    func updateTodo(id: String, title: String, completed: Bool) async throws -> Todo
}

enum APIError: LocalizedError {
    case invalidResponse
    case decodingFailed
    case serverMessage(String)
    case network(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."
        case .decodingFailed:
            return "The response could not be decoded."
        case .serverMessage(let message):
            return message
        case .network:
            return "Network request failed."
        }
    }
}

struct TodoAPIClient: TodoServicing {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func fetchTodos() async throws -> [Todo] {
        let data = try await request(path: APIConfig.todos, method: "GET", body: Optional<Data>.none)

        if let todos = try? JSONDecoder().decode([Todo].self, from: data) {
            return todos
        }

        if let wrapped = try? JSONDecoder().decode(TodoListResponse.self, from: data) {
            return wrapped.todos
        }

        throw APIError.decodingFailed
    }

    func addTodo(title: String) async throws -> Todo {
        let body = try JSONEncoder().encode(CreateTodoRequest(title: title))
        let data = try await request(path: APIConfig.addTodo, method: "POST", body: body)

        guard let todo = try? JSONDecoder().decode(Todo.self, from: data) else {
            throw APIError.decodingFailed
        }

        return todo
    }

    func deleteTodo(id: String) async throws {
        let body = try JSONEncoder().encode(DeleteTodoRequest(id: id))
        _ = try await request(path: APIConfig.deleteTodo, method: "DELETE", body: body)
    }

    func updateTodo(id: String, title: String, completed: Bool) async throws -> Todo {
        let body = try JSONEncoder().encode(UpdateTodoRequest(id: id, title: title, completed: completed))
        let data = try await request(path: APIConfig.updateTodo, method: "PUT", body: body)

        guard let todo = try? JSONDecoder().decode(Todo.self, from: data) else {
            throw APIError.decodingFailed
        }

        return todo
    }

    private func request(path: String, method: String, body: Data?) async throws -> Data {
        let cleanPath = path.hasPrefix("/") ? String(path.dropFirst()) : path
        var request = URLRequest(url: APIConfig.baseURL.appendingPathComponent(cleanPath))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                if let serverError = try? JSONDecoder().decode(ServerErrorResponse.self, from: data) {
                    throw APIError.serverMessage(serverError.message)
                }
                throw APIError.serverMessage("Request failed with status \(httpResponse.statusCode).")
            }

            return data
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.network(error)
        }
    }
}

private struct CreateTodoRequest: Codable {
    let title: String
}

private struct DeleteTodoRequest: Codable {
    let id: String
}

private struct UpdateTodoRequest: Codable {
    let id: String
    let title: String
    let completed: Bool
}

private struct TodoListResponse: Codable {
    let todos: [Todo]
}

private struct ServerErrorResponse: Codable {
    let message: String
}
