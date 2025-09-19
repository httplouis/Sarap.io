import SwiftUI

struct StepsSection: View {
    @Binding var steps: [StepItem]
    var reindexSteps: () -> Void

    var body: some View {
        Section(header: Text("STEPS")) {
            ForEach($steps) { $st in
                HStack(alignment: .firstTextBaseline) {
                    Text("\(st.order).")
                        .monospacedDigit()
                        .foregroundStyle(Theme.subtext)

                    TextField("", text: $st.text)
                        .placeholder(when: st.text.isEmpty) {
                            Text("Step description").foregroundColor(.gray)
                        }
                }
                .swipeActions {
                    Button(role: .destructive) {
                        if let idx = steps.firstIndex(where: { $0.id == st.id }) {
                            steps.remove(at: idx)
                            reindexSteps()
                        }
                    } label: { Label("Delete", systemImage: "trash") }
                }
            }
            .onDelete {
                steps.remove(atOffsets: $0)
                reindexSteps()
            }

            Button {
                // 👇 no labels, just values
                steps.append(StepItem((steps.last?.order ?? 0) + 1, ""))
            } label: {
                Label("Add Step", systemImage: "plus")
            }
        }
        .listRowBackground(Theme.card)
    }
}
