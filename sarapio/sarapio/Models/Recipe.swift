import Foundation
import SwiftUI

struct Recipe: Identifiable, Equatable, Hashable {
    var id = UUID()

    var title: String
    var minutes: Int
    var servings: Int
    var cuisine: String?
    var region: String?

    var tags: [String] = []
    var ingredients: [Ingredient] = []
    var steps: [StepItem] = []
    var isFavorite: Bool = false
    var ownerId: UUID? = nil

    // Images
    var imageData: Data? = nil
    var assetName: String? = nil
    var imageName: String? = nil
}

extension Recipe {
    func duplicated(for ownerId: UUID?) -> Recipe {
        var copy = self
        copy.id = UUID()
        copy.ownerId = ownerId
        return copy
    }
}
