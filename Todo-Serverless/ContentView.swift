import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel: TodoListViewModel

    init(viewModel: TodoListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        TabView {
            NavigationStack {
                HomeScreen(viewModel: viewModel)
            }
            .tabItem {
                Label("Todos", systemImage: "checklist")
            }

            NavigationStack {
                CompletedScreen(viewModel: viewModel)
            }
            .tabItem {
                Label("Completed", systemImage: "checkmark.circle")
            }
        }
        .tint(AppTheme.primary)
    }
}

private struct CompletedScreen: View {
    @ObservedObject var viewModel: TodoListViewModel
    @State private var selectedTodo: Todo?

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Completed Tasks")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)

                    if viewModel.completedTodos.isEmpty {
                        GlassSurface {
                            VStack(spacing: 12) {
                                Image(systemName: "checkmark.seal")
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundStyle(AppTheme.primary)
                                Text("No completed tasks yet")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundStyle(AppTheme.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 28)
                        }
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.completedTodos) { todo in
                                TodoRowCard(todo: todo, isBusy: viewModel.isBusy(todoID: todo.id), onToggle: {
                                    Task { await viewModel.toggle(todo: todo) }
                                }, onEdit: {
                                    viewModel.openEdit(todo: todo)
                                }, onOpen: {
                                    selectedTodo = todo
                                })
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
        }
        .navigationDestination(item: $selectedTodo) { todo in
            TodoDetailScreen(viewModel: viewModel, todoID: todo.id)
        }
        .sheet(isPresented: $viewModel.isShowingEditor) {
            TodoEditorScreen(viewModel: viewModel)
        }
        .task {
            if viewModel.todos.isEmpty {
                await viewModel.loadTodos()
            }
        }
    }
}

#Preview {
    ContentView(viewModel: TodoListViewModel(service: TodoAPIClient()))
}
