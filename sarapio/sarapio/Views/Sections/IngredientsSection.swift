import SwiftUI

struct IngredientsSection: View {
    @Binding var ingredients: [Ingredient]

    var body: some View {
        Section("INGREDIENTS") {
            ForEach($ingredients) { $ing in
                HStack {
                    TextField("Ingredient", text: $ing.name)
                    TextField("Amount", text: $ing.amount)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(Theme.subtext)
                    TextField("Unit", text: $ing.unit)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(Theme.subtext)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        if let idx = ingredients.firstIndex(where: { $0.id == ing.id }) {
                            ingredients.remove(at: idx)
                        }
                    } label: { Label("Delete", systemImage: "trash") }
                }
            }
            .onDelete { indices in
                ingredients.remove(atOffsets: indices)
            }

            Button {
                ingredients.append(Ingredient("New Ingredient"))
            } label: {
                Label("Add Ingredient", systemImage: "plus")
            }
        }
        .listRowBackground(Theme.card)
    }
}
