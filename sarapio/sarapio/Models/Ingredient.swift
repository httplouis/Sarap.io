import Foundation

struct Ingredient: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var amount: String   // numeric or text amount, e.g. "1", "2.5"
    var unit: String     // e.g. "pcs", "tsp", "tbsp", "g", "ml"

    init(_ name: String, amount: String = "", unit: String = "") {
        self.name = name
        self.amount = amount
        self.unit = unit
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
