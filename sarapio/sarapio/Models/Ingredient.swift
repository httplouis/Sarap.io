import Foundation

struct Ingredient: Identifiable, Equatable {
    let id = UUID()
    var name: String
    var qty: String

    init(_ name: String, qty: String = "") {
        self.name = name
        self.qty = qty
    }
}
