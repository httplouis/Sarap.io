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

    // Ownership
    var authorEmail: String?
    var authorName: String?

    // Images
    var imageData: Data? = nil
    var assetName: String? = nil
    var imageName: String? = nil

    mutating func assignAuthor(email: String?, name: String?) {
        authorEmail = email
        authorName = name
    }

    mutating func regenerateIdentity() {
        id = UUID()
    }
}
