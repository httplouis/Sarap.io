import SwiftUI

struct SaveSection: View {
    var editing: Recipe?
    var isValid: Bool
    var saveAction: () -> Void

    var body: some View {
        Section {
            Button(action: saveAction) {
                Text(editing == nil ? "Save Recipe" : "Update Recipe")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.olive)
            .listRowBackground(Theme.card)
            .disabled(!isValid)
            .opacity(isValid ? 1 : 0.5)
        }
    }
}
