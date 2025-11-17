import SwiftUI

struct StepsSection: View {
    @Binding var steps: [StepItem]
    var reindexSteps: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("STEPS")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.text)
                .padding(.horizontal, 4)
            
            ForEach($steps) { $st in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text("\(st.order).")
                        .monospacedDigit()
                        .foregroundStyle(Theme.olive)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(width: 30)

                    TextField("", text: $st.text, axis: .vertical)
                        .placeholder(when: st.text.isEmpty) {
                            Text("Step description").foregroundColor(.gray)
                        }
                        .lineLimit(3...6)
                        .padding(12)
                        .background(Theme.card)
                        .cornerRadius(12)
                }
                .padding(12)
                .background(Theme.card)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        HapticManager.shared.medium()
                        withAnimation {
                            if let idx = steps.firstIndex(where: { $0.id == st.id }) {
                                steps.remove(at: idx)
                                reindexSteps()
                            }
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }

            Button {
                HapticManager.shared.light()
                withAnimation {
                    steps.append(StepItem((steps.last?.order ?? 0) + 1, ""))
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Step")
                }
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.olive)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Theme.oliveSoft.opacity(0.3))
                .cornerRadius(12)
            }
        }
    }
}
