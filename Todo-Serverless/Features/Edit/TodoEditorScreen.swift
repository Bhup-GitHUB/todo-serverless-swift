import SwiftUI

struct TodoEditorScreen: View {
    enum Mode: Equatable {
        case create
        case edit(Todo)

        var title: String {
            switch self {
            case .create:
                return "Add Task"
            case .edit:
                return "Edit Task"
            }
        }

        var submitTitle: String {
            switch self {
            case .create:
                return "Create"
            case .edit:
                return "Save"
            }
        }
    }

    @ObservedObject var viewModel: TodoListViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var completed = false
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        GlassSurface {
                            VStack(alignment: .leading, spacing: 16) {
                                TextField("Task title", text: $title)
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                    .foregroundStyle(AppTheme.textPrimary)

                                if case .edit = viewModel.editorMode {
                                    Toggle(isOn: $completed) {
                                        Text("Mark as completed")
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundStyle(AppTheme.textSecondary)
                                    }
                                    .tint(AppTheme.secondary)
                                }

                                HStack {
                                    Text("\(title.trimmingCharacters(in: .whitespacesAndNewlines).count)/120")
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                        .foregroundStyle(AppTheme.textSecondary)

                                    Spacer()

                                    Button(action: submit) {
                                        if isSubmitting {
                                            ProgressView()
                                                .tint(.white)
                                        } else {
                                            Text(viewModel.editorMode.submitTitle)
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                        }
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(AppTheme.primary)
                                    .disabled(!canSubmit)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
            }
            .navigationTitle(viewModel.editorMode.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear(perform: configure)
        }
    }

    private var canSubmit: Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= 120 && !isSubmitting
    }

    private func configure() {
        switch viewModel.editorMode {
        case .create:
            title = ""
            completed = false
        case .edit(let todo):
            title = todo.title
            completed = todo.completed
        }
    }

    private func submit() {
        guard !isSubmitting else { return }
        isSubmitting = true

        let todoID: String?
        switch viewModel.editorMode {
        case .create:
            todoID = nil
        case .edit(let todo):
            todoID = todo.id
        }

        Task {
            let didSave = await viewModel.saveFromEditor(id: todoID, title: title, completed: completed)
            isSubmitting = false
            if didSave {
                dismiss()
            }
        }
    }
}
