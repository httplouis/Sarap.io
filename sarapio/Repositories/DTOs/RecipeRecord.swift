// sarapio/Repositories/DTOs/RecipeRecord.swift
import Foundation

struct RecipeRecord: Codable {
    let id: UUID
    let title: String
    let minutes: Int?
    let servings: Int?
    let cuisine: String?
    let region: String?
    let ingredients: [[String: String]]?  // JSONB array
    let steps: [[String: Any]]?  // JSONB array
    let is_favorite: Bool?
    let user_id: UUID?
    let photo_url: String?
    let created_at: String?
}
