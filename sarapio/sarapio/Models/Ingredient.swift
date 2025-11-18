import Foundation

struct Ingredient: Identifiable, Hashable, Codable {
    var id = UUID()
    var name: String
    var amount: String   // numeric or text amount, e.g. "1", "2.5"
    var unit: String     // e.g. "pcs", "tsp", "tbsp", "g", "ml"
    var isChecked: Bool = false // for shopping list
    var category: IngredientCategory = .other

    static let commonUnits: [String] = [
        "", "g", "kg", "mg", "ml", "L", "cup", "tbsp", "tsp", "pcs", "cloves", "slices", "dash", "oz", "lb"
    ]
    
    enum IngredientCategory: String, Codable, CaseIterable {
        case produce = "Produce"
        case meat = "Meat & Seafood"
        case dairy = "Dairy"
        case pantry = "Pantry"
        case spices = "Spices & Herbs"
        case other = "Other"
        
        var icon: String {
            switch self {
            case .produce: return "leaf.fill"
            case .meat: return "fish.fill"
            case .dairy: return "drop.fill"
            case .pantry: return "cabinet.fill"
            case .spices: return "sparkles"
            case .other: return "square.grid.2x2"
            }
        }
    }

    init(_ name: String, amount: String = "", unit: String = "", category: IngredientCategory = .other) {
        self.name = name
        self.amount = amount
        self.unit = unit
        self.category = category
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
