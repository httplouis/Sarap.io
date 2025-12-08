import Foundation

enum RecipeCollection: Identifiable, Hashable {
    case all
    case favorites
    case recent
    case popular
    case cuisine(String)
    case difficulty(Recipe.Difficulty)
    case tag(String)
    
    var id: String {
        switch self {
        case .all: return "all"
        case .favorites: return "favorites"
        case .recent: return "recent"
        case .popular: return "popular"
        case .cuisine(let name): return "cuisine_\(name)"
        case .difficulty(let level): return "difficulty_\(level.rawValue)"
        case .tag(let name): return "tag_\(name)"
        }
    }
    
    var title: String {
        switch self {
        case .all: return "All Recipes"
        case .favorites: return "Favorites"
        case .recent: return "Recent"
        case .popular: return "Popular"
        case .cuisine(let name): return name
        case .difficulty(let level): return level.rawValue
        case .tag(let name): return name
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .favorites: return "heart.fill"
        case .recent: return "clock.fill"
        case .popular: return "flame.fill"
        case .cuisine: return "globe"
        case .difficulty: return "chart.bar.fill"
        case .tag: return "tag.fill"
        }
    }
}

