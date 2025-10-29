// sarapio/Repositories/DTOs/RecipeRecord.swift
import Foundation

struct RecipeRecord: Codable {
    let id: UUID
    let title: String
    let minutes: Int
    let servings: Int
    let cuisine: String?
    let region: String?
    let tags: [String]
    let ingredients: [IngredientRecord]
    let steps: [StepRecord]
    let is_favorite: Bool
    let author_email: String?
    let author_name: String?
    let created_at: String?

    struct IngredientRecord: Codable {
        let name: String
        let amount: String
        let unit: String
    }

    struct StepRecord: Codable {
        let order: Int
        let text: String
    }
}
