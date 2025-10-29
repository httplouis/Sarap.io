import Foundation

struct SocialPost: Identifiable {
    let id: UUID
    let user: String
    let avatar: String?
    let caption: String
    var recipe: Recipe
    var likes: Int
    var comments: [String]
    var rating: Int
    var isLiked: Bool = false
    var isSaved: Bool = false
    var userRating: Int = 0
}
