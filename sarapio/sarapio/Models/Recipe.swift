import Foundation
import SwiftUI

struct Recipe: Identifiable, Equatable, Hashable, Codable {
    var id = UUID()

    var title: String
    var minutes: Int
    var servings: Int
    var cuisine: String?
    var region: String?
    
    // Enhanced fields
    var difficulty: Difficulty = .medium
    var description: String = ""
    var prepTime: Int = 0 // separate prep time
    var cookTime: Int = 0 // separate cook time
    var calories: Int? = nil
    var protein: Double? = nil // grams
    var carbs: Double? = nil // grams
    var fat: Double? = nil // grams
    var tips: [String] = []
    var variations: [String] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var viewCount: Int = 0
    var rating: Double = 0.0
    var ratingCount: Int = 0

    var tags: [String] = []
    var ingredients: [Ingredient] = []
    var steps: [StepItem] = []
    var isFavorite: Bool = false

    // Ownership
    var authorEmail: String?
    var authorName: String?

    // Images
    var imageUrl: String? = nil
    var imageData: Data? = nil // Fallback for local images
    var assetName: String? = nil // Fallback for asset names
    var imageName: String? = nil // Deprecated - use imageUrl
    
    enum Difficulty: String, Codable, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        case expert = "Expert"
        
        var icon: String {
            switch self {
            case .easy: return "1.circle.fill"
            case .medium: return "2.circle.fill"
            case .hard: return "3.circle.fill"
            case .expert: return "4.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .easy: return .green
            case .medium: return .orange
            case .hard: return .red
            case .expert: return .purple
            }
        }
    }

    mutating func assignAuthor(email: String?, name: String?) {
        authorEmail = email
        authorName = name
    }

    mutating func regenerateIdentity() {
        id = UUID()
        createdAt = Date()
        updatedAt = Date()
    }
    
    mutating func incrementViewCount() {
        viewCount += 1
        updatedAt = Date()
    }
    
    var totalTime: Int {
        prepTime + cookTime > 0 ? prepTime + cookTime : minutes
    }
    
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}
