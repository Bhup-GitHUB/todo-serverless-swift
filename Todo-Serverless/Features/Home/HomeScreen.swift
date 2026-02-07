import SwiftUI

struct HomeScreen: View {
    @ObservedObject var viewModel: TodoListViewModel
    @State private var animateCards = false
    @State private var selectedTodo: Todo?

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 14) {
                header
                QuickAddBar(text: $viewModel.quickAddText, isSubmitting: viewModel.isSubmittingQuickAdd) {
                    Task { await viewModel.addQuickTodo() }
                }
                filterBar
                content
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
        }
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.openCreate()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .bold))
                }
            }
        }
        .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search tasks")
        .task {
            await viewModel.loadTodos()
        }
        .sheet(isPresented: $viewModel.isShowingEditor) {
            TodoEditorScreen(viewModel: viewModel)
        }
        .navigationDestination(item: $selectedTodo) { todo in
            TodoDetailScreen(viewModel: viewModel, todoID: todo.id)
        }
        .alert("Something went wrong", isPresented: Binding(get: {
            viewModel.errorMessage != nil
        }, set: { isPresented in
            if !isPresented {
                viewModel.errorMessage = nil
            }
        })) {
            Button("OK", role: .cancel) {
                viewModel.errorMessage = nil
            }
            Button("Retry") {
                Task { await viewModel.loadTodos(force: true) }
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                animateCards = true
            }
        }
    }

    private var header: some View {
        GlassSurface {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Today’s Tasks")
                        .font(.system(size: 31, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("\(viewModel.pendingCount) pending • \(viewModel.completedCount) completed")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }

                Spacer()

                Circle()
                    .fill(
                        LinearGradient(colors: [AppTheme.secondary, AppTheme.primary], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 52, height: 52)
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 21, weight: .bold))
                            .foregroundStyle(.white)
                    )
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(TodoListViewModel.Filter.allCases, id: \.rawValue) { filter in
                    Button(filter.rawValue) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectedFilter = filter
                        }
                    }
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(
                        Capsule()
                            .fill(viewModel.selectedFilter == filter ? AppTheme.chipActive : AppTheme.chipInactive)
                    )
                }
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { _ in
                    GlassSurface {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 40)
                            .redacted(reason: .placeholder)
                    }
                }
            }
        } else if viewModel.visibleTodos.isEmpty {
            GlassSurface {
                VStack(spacing: 14) {
                    Image(systemName: "tray")
                        .font(.system(size: 36, weight: .semibold))
                        .foregroundStyle(AppTheme.secondary)
                    Text("No tasks here yet")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                    Text("Add a task to get started")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 28)
            }
        } else {
            List {
                ForEach(viewModel.visibleTodos) { todo in
                    TodoRowCard(todo: todo, isBusy: viewModel.isBusy(todoID: todo.id), onToggle: {
                        Task { await viewModel.toggle(todo: todo) }
                    }, onEdit: {
                        viewModel.openEdit(todo: todo)
                    }, onOpen: {
                        selectedTodo = todo
                    })
                    .scaleEffect(animateCards ? 1 : 0.96)
                    .opacity(animateCards ? 1 : 0.01)
                    .animation(.spring(response: 0.42, dampingFraction: 0.82).delay(Double(viewModel.visibleTodos.firstIndex(of: todo) ?? 0) * 0.03), value: animateCards)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 7, leading: 0, bottom: 7, trailing: 0))
                    .listRowBackground(Color.clear)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            Task { await viewModel.delete(todo: todo) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        Button {
                            Task { await viewModel.toggle(todo: todo) }
                        } label: {
                            Label(todo.completed ? "Pending" : "Done", systemImage: todo.completed ? "arrow.uturn.backward" : "checkmark")
                        }
                        .tint(todo.completed ? AppTheme.accent : AppTheme.secondary)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }
}
