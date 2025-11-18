import Foundation

struct SocialPost: Identifiable, Codable {
    let id: UUID
    let user: String
    let avatar: String?
    let caption: String
    var recipe: Recipe
    var likes: Int
    var comments: [Comment]
    var rating: Int
    var isLiked: Bool = false
    var isSaved: Bool = false
    var userRating: Int = 0
    var createdAt: Date = Date()
    var shares: Int = 0
    
    struct Comment: Identifiable, Codable, Equatable {
        let id: UUID
        let user: String
        let text: String
        let createdAt: Date
        
        init(id: UUID = UUID(), user: String, text: String, createdAt: Date = Date()) {
            self.id = id
            self.user = user
            self.text = text
            self.createdAt = createdAt
        }
    }
    
    var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: createdAt, relativeTo: Date())
    }
}
