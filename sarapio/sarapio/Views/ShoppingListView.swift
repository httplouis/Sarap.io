import SwiftUI

struct ShoppingListView: View {
    @EnvironmentObject private var shoppingList: ShoppingListStore
    @EnvironmentObject private var store: RecipeStore
    @State private var selectedCategory: Ingredient.IngredientCategory? = nil
    @State private var showAddItem = false
    
    private var filteredItems: [ShoppingItem] {
        let items = shoppingList.getItems(by: selectedCategory)
        return items.sorted { !$0.isChecked && $1.isChecked }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryChip(title: "All", isSelected: selectedCategory == nil) {
                            selectedCategory = nil
                        }
                        ForEach(Ingredient.IngredientCategory.allCases, id: \.self) { category in
                            CategoryChip(title: category.rawValue, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
                .background(Theme.card)
                
                if filteredItems.isEmpty {
                    EmptyShoppingListView()
                } else {
                    List {
                        ForEach(filteredItems) { item in
                            ShoppingItemRow(item: item)
                                .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 8, trailing: 20))
                                .listRowBackground(Color.clear)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                shoppingList.delete(filteredItems[index])
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle("Shopping List")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            shoppingList.clearChecked()
                        } label: {
                            Label("Clear Checked", systemImage: "checkmark.circle")
                        }
                        Button(role: .destructive) {
                            shoppingList.clearAll()
                        } label: {
                            Label("Clear All", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                HStack(spacing: 16) {
                    Button {
                        showAddItem = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Item")
                        }
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.olive))
                        .foregroundStyle(.white)
                    }
                    
                    if shoppingList.checkedCount > 0 {
                        Text("\(shoppingList.checkedCount)/\(shoppingList.totalCount)")
                            .font(.headline)
                            .foregroundStyle(Theme.olive)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.oliveSoft))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Theme.card)
            }
            .sheet(isPresented: $showAddItem) {
                AddShoppingItemView()
            }
        }
    }
}

private struct ShoppingItemRow: View {
    @EnvironmentObject private var shoppingList: ShoppingListStore
    let item: ShoppingItem
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                shoppingList.toggleCheck(item)
            } label: {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(item.isChecked ? Theme.olive : Theme.subtext)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.display)
                    .font(.body)
                    .strikethrough(item.isChecked)
                    .foregroundStyle(item.isChecked ? Theme.subtext : Theme.text)
                
                HStack(spacing: 8) {
                    Image(systemName: item.category.icon)
                        .font(.caption2)
                        .foregroundStyle(Theme.subtext)
                    Text(item.category.rawValue)
                        .font(.caption2)
                        .foregroundStyle(Theme.subtext)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
        .opacity(item.isChecked ? 0.6 : 1.0)
    }
}

private struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.footnote)
                .fontWeight(.semibold)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 20).fill(isSelected ? Theme.olive : Theme.oliveSoft))
                .foregroundStyle(isSelected ? .white : Theme.olive)
        }
    }
}

private struct EmptyShoppingListView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart.badge.plus")
                .font(.system(size: 64))
                .foregroundStyle(Theme.subtext)
            Text("Your shopping list is empty")
                .font(.headline)
                .foregroundStyle(Theme.text)
            Text("Add ingredients from recipes or create items manually")
                .font(.footnote)
                .foregroundStyle(Theme.subtext)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct AddShoppingItemView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var shoppingList: ShoppingListStore
    @State private var name = ""
    @State private var amount = ""
    @State private var unit = ""
    @State private var category: Ingredient.IngredientCategory = .other
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Item name", text: $name)
                    TextField("Amount (optional)", text: $amount)
                        .keyboardType(.decimalPad)
                    Picker("Unit", selection: $unit) {
                        Text("None").tag("")
                        ForEach(Ingredient.commonUnits.filter { !$0.isEmpty }, id: \.self) { unit in
                            Text(unit).tag(unit)
                        }
                    }
                    Picker("Category", selection: $category) {
                        ForEach(Ingredient.IngredientCategory.allCases, id: \.self) { cat in
                            Label(cat.rawValue, systemImage: cat.icon).tag(cat)
                        }
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let ingredient = Ingredient(name, amount: amount, unit: unit, category: category)
                        shoppingList.addIngredient(ingredient)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

