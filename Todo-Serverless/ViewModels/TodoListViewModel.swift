import Foundation
import Combine

@MainActor
final class TodoListViewModel: ObservableObject {
    enum Filter: String, CaseIterable {
        case all = "All"
        case pending = "Pending"
        case completed = "Completed"
    }

    @Published private(set) var todos: [Todo] = []
    @Published var searchText = ""
    @Published var quickAddText = ""
    @Published var selectedFilter: Filter = .all
    @Published var isLoading = false
    @Published var isSubmittingQuickAdd = false
    @Published var isShowingEditor = false
    @Published var editorMode: TodoEditorScreen.Mode = .create
    @Published var errorMessage: String?

    private let service: TodoServicing
    private var busyIDs: Set<String> = []
    private var hasLoadedTodos = false

    init(service: TodoServicing) {
        self.service = service
    }

    var pendingCount: Int {
        todos.filter { !$0.completed }.count
    }

    var completedCount: Int {
        todos.filter { $0.completed }.count
    }

    var completedTodos: [Todo] {
        sorted(todos.filter { $0.completed })
    }

    var visibleTodos: [Todo] {
        let base: [Todo]

        switch selectedFilter {
        case .all:
            base = todos
        case .pending:
            base = todos.filter { !$0.completed }
        case .completed:
            base = todos.filter { $0.completed }
        }

        let searched: [Todo]
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        if query.isEmpty {
            searched = base
        } else {
            searched = base.filter { $0.title.localizedCaseInsensitiveContains(query) }
        }

        return sorted(searched)
    }

    func isBusy(todoID: String) -> Bool {
        busyIDs.contains(todoID)
    }

    func loadTodos(force: Bool = false) async {
        guard force || !hasLoadedTodos else { return }
        isLoading = true
        errorMessage = nil

        do {
            let fetched = try await service.fetchTodos()
            todos = sorted(fetched)
            hasLoadedTodos = true
        } catch {
            errorMessage = friendlyError(error)
        }

        isLoading = false
    }

    func addQuickTodo() async {
        let trimmed = normalize(quickAddText)
        guard !trimmed.isEmpty else { return }
        guard trimmed.count <= 120 else {
            errorMessage = "Todo title should be 120 characters or less."
            return
        }
        guard !isSubmittingQuickAdd else { return }

        isSubmittingQuickAdd = true
        errorMessage = nil

        do {
            let created = try await service.addTodo(title: trimmed)
            todos.insert(created, at: 0)
            todos = sorted(todos)
            quickAddText = ""
        } catch {
            errorMessage = friendlyError(error)
        }

        isSubmittingQuickAdd = false
    }

    func toggle(todo: Todo) async {
        guard !isBusy(todoID: todo.id) else { return }
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }

        busyIDs.insert(todo.id)
        errorMessage = nil

        let original = todos[index]
        todos[index].completed.toggle()
        todos = sorted(todos)

        do {
            let updated = try await service.updateTodo(id: original.id, title: nil, completed: !original.completed)
            replace(todo: updated)
        } catch {
            replace(todo: original)
            errorMessage = friendlyError(error)
        }

        busyIDs.remove(todo.id)
    }

    func delete(todo: Todo) async {
        guard !isBusy(todoID: todo.id) else { return }
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }

        busyIDs.insert(todo.id)
        errorMessage = nil

        let removed = todos.remove(at: index)

        do {
            try await service.deleteTodo(id: removed.id)
        } catch {
            todos.insert(removed, at: min(index, todos.count))
            todos = sorted(todos)
            errorMessage = friendlyError(error)
        }

        busyIDs.remove(todo.id)
    }

    func openCreate() {
        editorMode = .create
        isShowingEditor = true
    }

    func openEdit(todo: Todo) {
        editorMode = .edit(todo)
        isShowingEditor = true
    }

    func saveFromEditor(id: String?, title: String, completed: Bool) async -> Bool {
        let trimmed = normalize(title)
        guard !trimmed.isEmpty else {
            errorMessage = "Title cannot be empty."
            return false
        }
        guard trimmed.count <= 120 else {
            errorMessage = "Todo title should be 120 characters or less."
            return false
        }

        errorMessage = nil

        do {
            if let id {
                guard let original = todos.first(where: { $0.id == id }) else { return false }
                busyIDs.insert(id)
                replace(todo: Todo(id: id, title: trimmed, completed: completed))

                do {
                    let updated = try await service.updateTodo(id: id, title: trimmed, completed: completed)
                    replace(todo: updated)
                } catch {
                    replace(todo: original)
                    busyIDs.remove(id)
                    errorMessage = friendlyError(error)
                    return false
                }

                busyIDs.remove(id)
            } else {
                let created = try await service.addTodo(title: trimmed)
                todos.append(created)
                todos = sorted(todos)
            }

            isShowingEditor = false
            return true
        } catch {
            errorMessage = friendlyError(error)
            return false
        }
    }

    func todo(for id: String) -> Todo? {
        todos.first(where: { $0.id == id })
    }

    private func replace(todo: Todo) {
        guard let index = todos.firstIndex(where: { $0.id == todo.id }) else { return }
        todos[index] = todo
        todos = sorted(todos)
    }

    private func normalize(_ text: String) -> String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func sorted(_ items: [Todo]) -> [Todo] {
        items.sorted { lhs, rhs in
            if lhs.completed != rhs.completed {
                return rhs.completed
            }
            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }
    }

    private func friendlyError(_ error: Error) -> String {
        if let apiError = error as? APIError {
            return apiError.localizedDescription
        }
        return error.localizedDescription
    }
}
