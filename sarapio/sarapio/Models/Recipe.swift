import Foundation
import SwiftUI

struct Recipe: Identifiable, Equatable {
    let id = UUID()

    var title: String
    var minutes: Int
    var servings: Int
    var cuisine: String?
    var region: String?

    var tags: [String] = []
    var ingredients: [Ingredient] = []
    var steps: [StepItem] = []
    var isFavorite: Bool = false

    // Images
    /// If user added a photo, we store it here.
    var imageData: Data? = nil
    /// For seeded/static recipes, use an asset name (e.g., "shrimp", "chicken-adobo", "veggie").
    /// If `imageData` exists, it takes priority over `assetName`.
    var assetName: String? = nil
    var imageName: String? = nil
}
