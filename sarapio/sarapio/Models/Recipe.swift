import Foundation
import SwiftUI

struct Recipe: Identifiable, Equatable, Hashable {
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
    var imageData: Data? = nil
    var assetName: String? = nil
    var imageName: String? = nil
}
