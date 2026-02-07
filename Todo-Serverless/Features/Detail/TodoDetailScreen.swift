import SwiftUI

struct TodoDetailScreen: View {
    @ObservedObject var viewModel: TodoListViewModel
    let todoID: String

    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()

            if let todo = viewModel.todo(for: todoID) {
                ScrollView {
                    VStack(spacing: 18) {
                        GlassSurface {
                            VStack(alignment: .leading, spacing: 14) {
                                Text(todo.title)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .strikethrough(todo.completed)

                                HStack {
                                    statusPill(completed: todo.completed)
                                    Spacer()
                                    Button(todo.completed ? "Mark Pending" : "Mark Done") {
                                        Task { await viewModel.toggle(todo: todo) }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(todo.completed ? AppTheme.accent : AppTheme.secondary)
                                    .disabled(viewModel.isBusy(todoID: todo.id))
                                }
                            }
                        }

                        HStack(spacing: 12) {
                            Button("Edit") {
                                viewModel.openEdit(todo: todo)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(AppTheme.primary)

                            Button("Delete", role: .destructive) {
                                showDeleteAlert = true
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
            } else {
                GlassSurface {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundStyle(AppTheme.accent)
                        Text("Task not found")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Task Detail")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $viewModel.isShowingEditor) {
            TodoEditorScreen(viewModel: viewModel)
        }
        .alert("Delete task?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                Task {
                    if let todo = viewModel.todo(for: todoID) {
                        await viewModel.delete(todo: todo)
                        dismiss()
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private func statusPill(completed: Bool) -> some View {
        Text(completed ? "Completed" : "In Progress")
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(completed ? AppTheme.secondary : AppTheme.accent)
            )
    }
}
