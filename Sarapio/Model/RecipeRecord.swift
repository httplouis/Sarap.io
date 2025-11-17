// sarapio/Model/RecipeRecord.swift
import Foundation

struct RecipeRecord: Codable {
    let id: UUID
    let title: String
    let minutes: Int?
    let servings: Int?
    let cuisine: String?
    let region: String?
    let ingredients: [IngredientRecord]?  // JSONB array
    let steps: [StepRecord]?  // JSONB array
    let is_favorite: Bool?
    let user_id: UUID?
    let photo_url: String?
    let created_at: String?
    
    struct IngredientRecord: Codable {
        let name: String
        let quantity: String?
    }
    
    struct StepRecord: Codable {
        let order_num: Int
        let instruction: String
    }
}
