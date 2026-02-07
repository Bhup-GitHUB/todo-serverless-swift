import SwiftUI

struct QuickAddBar: View {
    @Binding var text: String
    let isSubmitting: Bool
    let onSubmit: () -> Void

    var body: some View {
        GlassSurface {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .foregroundStyle(AppTheme.secondary)
                    .font(.system(size: 22, weight: .semibold))

                TextField("Add a new task", text: $text)
                    .textInputAutocapitalization(.sentences)
                    .disableAutocorrection(false)
                    .foregroundStyle(AppTheme.textPrimary)
                    .font(.system(size: 17, weight: .medium, design: .rounded))

                Button(action: onSubmit) {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Add")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(AppTheme.primary)
                .disabled(isSubmitting || text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}
