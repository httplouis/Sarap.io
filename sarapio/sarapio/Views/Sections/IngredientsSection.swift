import SwiftUI

struct IngredientsSection: View {
    @Binding var ingredients: [Ingredient]

    var body: some View {
        Section("INGREDIENTS") {
            ForEach($ingredients) { $ing in
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Ingredient", text: $ing.name)
                        .textInputAutocapitalization(.words)
                    HStack {
                        TextField("Amount", text: $ing.amount)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Theme.subtext)
                        Spacer()
                        Menu {
                            ForEach(Ingredient.commonUnits, id: \.self) { unit in
                                Button(unit.isEmpty ? "No unit" : unit) { ing.unit = unit }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.down.circle.fill")
                                Text(ing.unit.isEmpty ? "Unit" : ing.unit)
                            }
                            .foregroundStyle(Theme.olive)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(RoundedRectangle(cornerRadius: 10).fill(Theme.oliveSoft.opacity(0.6)))
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
                ingredients.append(Ingredient("", amount: "", unit: ""))
            } label: {
                Label("Add Ingredient", systemImage: "plus")
            }
        }
        .listRowBackground(Theme.card)
    }
}
