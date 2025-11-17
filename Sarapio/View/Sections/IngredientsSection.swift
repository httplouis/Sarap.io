import SwiftUI

struct IngredientsSection: View {
    @Binding var ingredients: [Ingredient]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("INGREDIENTS")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.text)
                .padding(.horizontal, 4)
            
            ForEach($ingredients) { $ing in
                VStack(alignment: .leading, spacing: 8) {
                    TextField("Ingredient", text: $ing.name)
                        .textInputAutocapitalization(.words)
                        .padding(12)
                        .background(Theme.card)
                        .cornerRadius(12)
                    HStack {
                        TextField("Amount", text: $ing.amount)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(Theme.subtext)
                            .padding(12)
                            .background(Theme.card)
                            .cornerRadius(12)
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
                .padding(12)
                .background(Theme.card)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        HapticManager.shared.medium()
                        withAnimation {
                            if let idx = ingredients.firstIndex(where: { $0.id == ing.id }) {
                                ingredients.remove(at: idx)
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
                    ingredients.append(Ingredient("", amount: "", unit: ""))
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Ingredient")
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
