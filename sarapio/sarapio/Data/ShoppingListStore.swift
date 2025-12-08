import Foundation
import SwiftUI

final class ShoppingListStore: ObservableObject {
    @Published var items: [ShoppingItem] = [] {
        didSet {
            saveItems()
        }
    }
    
    private let itemsKey = "sarapio.shoppingList"
    
    init() {
        loadItems()
    }
    
    func addIngredient(_ ingredient: Ingredient) {
        let item = ShoppingItem(from: ingredient)
        if !items.contains(where: { $0.name.lowercased() == item.name.lowercased() }) {
            items.append(item)
        }
    }
    
    func addIngredients(from recipe: Recipe) {
        for ingredient in recipe.ingredients {
            addIngredient(ingredient)
        }
    }
    
    func toggleCheck(_ item: ShoppingItem) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[index].isChecked.toggle()
    }
    
    func delete(_ item: ShoppingItem) {
        items.removeAll { $0.id == item.id }
    }
    
    func clearChecked() {
        items.removeAll { $0.isChecked }
    }
    
    func clearAll() {
        items.removeAll()
    }
    
    func getItems(by category: Ingredient.IngredientCategory?) -> [ShoppingItem] {
        guard let category else { return items }
        return items.filter { $0.category == category }
    }
    
    var checkedCount: Int {
        items.filter { $0.isChecked }.count
    }
    
    var totalCount: Int {
        items.count
    }
    
    private func saveItems() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: itemsKey)
        }
    }
    
    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: itemsKey),
              let decoded = try? JSONDecoder().decode([ShoppingItem].self, from: data) else {
            return
        }
        items = decoded
    }
}

struct ShoppingItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var amount: String
    var unit: String
    var isChecked: Bool
    var category: Ingredient.IngredientCategory
    var addedAt: Date
    
    init(id: UUID = UUID(), name: String, amount: String = "", unit: String = "", isChecked: Bool = false, category: Ingredient.IngredientCategory = .other, addedAt: Date = Date()) {
        self.id = id
        self.name = name
        self.amount = amount
        self.unit = unit
        self.isChecked = isChecked
        self.category = category
        self.addedAt = addedAt
    }
    
    init(from ingredient: Ingredient) {
        self.id = UUID()
        self.name = ingredient.name
        self.amount = ingredient.amount
        self.unit = ingredient.unit
        self.isChecked = false
        self.category = ingredient.category
        self.addedAt = Date()
    }
    
    var display: String {
        if !amount.isEmpty && !unit.isEmpty {
            return "\(amount) \(unit) \(name)"
        } else if !amount.isEmpty {
            return "\(amount) \(name)"
        } else {
            return name
        }
    }
}

