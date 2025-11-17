import Foundation
import SwiftUI

struct Recipe: Identifiable, Equatable, Hashable, Codable {
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
    var user_id: UUID?
    var authorEmail: String?
    var authorName: String?

    // Images
    var photo_url: String?
    var imageData: Data? = nil
    var assetName: String? = nil
    var imageName: String? = nil
    
    var created_at: Date?

    mutating func assignAuthor(email: String?, name: String?) {
        authorEmail = email
        authorName = name
    }

    mutating func regenerateIdentity() {
        id = UUID()
    }
    
    // Custom encoding for Supabase (ingredients/steps as JSONB)
    enum CodingKeys: String, CodingKey {
        case id, title, minutes, servings, cuisine, region
        case ingredients, steps
        case is_favorite, user_id, photo_url, created_at
    }
    
    init(id: UUID = UUID(), title: String, minutes: Int, servings: Int, cuisine: String? = nil, region: String? = nil, tags: [String] = [], ingredients: [Ingredient] = [], steps: [StepItem] = [], isFavorite: Bool = false, user_id: UUID? = nil, authorEmail: String? = nil, authorName: String? = nil, photo_url: String? = nil, imageData: Data? = nil, assetName: String? = nil, imageName: String? = nil, created_at: Date? = nil) {
        self.id = id
        self.title = title
        self.minutes = minutes
        self.servings = servings
        self.cuisine = cuisine
        self.region = region
        self.tags = tags
        self.ingredients = ingredients
        self.steps = steps
        self.isFavorite = isFavorite
        self.user_id = user_id
        self.authorEmail = authorEmail
        self.authorName = authorName
        self.photo_url = photo_url
        self.imageData = imageData
        self.assetName = assetName
        self.imageName = imageName
        self.created_at = created_at
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        minutes = try container.decode(Int.self, forKey: .minutes)
        servings = try container.decode(Int.self, forKey: .servings)
        cuisine = try container.decodeIfPresent(String.self, forKey: .cuisine)
        region = try container.decodeIfPresent(String.self, forKey: .region)
        user_id = try container.decodeIfPresent(UUID.self, forKey: .user_id)
        photo_url = try container.decodeIfPresent(String.self, forKey: .photo_url)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .is_favorite) ?? false
        
        // Decode created_at as ISO8601 string
        if let dateString = try? container.decodeIfPresent(String.self, forKey: .created_at) {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            created_at = formatter.date(from: dateString) ?? ISO8601DateFormatter().date(from: dateString)
        }
        
        // Decode ingredients from JSONB (can be array or JSON string)
        if let ingredientsArray = try? container.decodeIfPresent([Ingredient].self, forKey: .ingredients) {
            ingredients = ingredientsArray
        } else {
            ingredients = []
        }
        
        // Decode steps from JSONB (can be array or JSON string)
        if let stepsArray = try? container.decodeIfPresent([StepItem].self, forKey: .steps) {
            steps = stepsArray
        } else {
            steps = []
        }
        
        tags = []
        authorEmail = nil
        authorName = nil
        imageData = nil
        assetName = nil
        imageName = nil
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(minutes, forKey: .minutes)
        try container.encode(servings, forKey: .servings)
        try container.encodeIfPresent(cuisine, forKey: .cuisine)
        try container.encodeIfPresent(region, forKey: .region)
        try container.encodeIfPresent(user_id, forKey: .user_id)
        try container.encodeIfPresent(photo_url, forKey: .photo_url)
        try container.encode(isFavorite, forKey: .is_favorite)
        
        // Encode created_at as ISO8601 string
        if let date = created_at {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            try container.encode(formatter.string(from: date), forKey: .created_at)
        }
        
        // Encode ingredients as JSONB array
        try container.encode(ingredients, forKey: .ingredients)
        
        // Encode steps as JSONB array
        try container.encode(steps, forKey: .steps)
    }
}
