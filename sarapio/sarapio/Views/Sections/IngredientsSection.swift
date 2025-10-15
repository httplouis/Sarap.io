import SwiftUI

struct IngredientsSection: View {
    @Binding var ingredients: [Ingredient]
    var unitOptions: [String]

    var body: some View {
        Section("INGREDIENTS") {
            ForEach($ingredients) { $ing in
                HStack {
                    TextField("Ingredient", text: $ing.name)
                    TextField("Amount", text: $ing.amount)
                        .multilineTextAlignment(.trailing)
                        .foregroundStyle(Theme.subtext)
                    HStack(spacing: 4) {
                        TextField("Unit", text: $ing.unit)
                            .frame(width: 60)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(Theme.subtext)
                        Menu {
                            ForEach(unitOptions, id: \.self) { option in
                                Button(option) { ing.unit = option }
                            }
                            Button("Clear") { ing.unit = "" }
                        } label: {
                            Image(systemName: "chevron.down")
                                .padding(6)
                                .background(RoundedRectangle(cornerRadius: 8).fill(Theme.bg))
                        }
                    }
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
