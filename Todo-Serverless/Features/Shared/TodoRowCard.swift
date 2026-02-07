import SwiftUI

struct TodoRowCard: View {
    let todo: Todo
    let isBusy: Bool
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onOpen: () -> Void

    var body: some View {
        GlassSurface {
            HStack(spacing: 12) {
                Button(action: onToggle) {
                    Image(systemName: todo.completed ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(todo.completed ? AppTheme.secondary : AppTheme.textSecondary)
                }
                .buttonStyle(.borderless)
                .disabled(isBusy)

                VStack(alignment: .leading, spacing: 6) {
                    Text(todo.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(AppTheme.textPrimary)
                        .strikethrough(todo.completed)
                        .opacity(todo.completed ? 0.72 : 1)
                        .lineLimit(2)

                    Text(todo.completed ? "Completed" : "Pending")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(todo.completed ? AppTheme.secondary : AppTheme.accent)
                }

                Spacer(minLength: 0)

                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .bold))
                }
                .buttonStyle(.borderless)
                .disabled(isBusy)

                Button(action: onOpen) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(AppTheme.textSecondary)
                        .padding(8)
                        .background(Circle().fill(Color.white.opacity(0.1)))
                }
                .buttonStyle(.borderless)
            }
        }
    }
}
