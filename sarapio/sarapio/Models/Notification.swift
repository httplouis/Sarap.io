import Foundation
import SwiftUI

struct AppNotification: Identifiable, Codable {
    let id: UUID
    var type: NotificationType
    var title: String
    var message: String
    var timestamp: Date
    var isRead: Bool
    var relatedUserId: String?
    var relatedRecipeId: UUID?
    var actionUrl: String?
    
    enum NotificationType: String, Codable, CaseIterable {
        case like = "like"
        case comment = "comment"
        case follow = "follow"
        case save = "save"
        case share = "share"
        case system = "system"
        case achievement = "achievement"
        case recipeUpdate = "recipe_update"
        
        var icon: String {
            switch self {
            case .like: return "heart.fill"
            case .comment: return "text.bubble.fill"
            case .follow: return "person.crop.circle.badge.plus"
            case .save: return "bookmark.fill"
            case .share: return "square.and.arrow.up.fill"
            case .system: return "bell.fill"
            case .achievement: return "trophy.fill"
            case .recipeUpdate: return "sparkles"
            }
        }
        
        var color: Color {
            switch self {
            case .like: return .pink
            case .comment: return .blue
            case .follow: return .green
            case .save: return .orange
            case .share: return .purple
            case .system: return .gray
            case .achievement: return .yellow
            case .recipeUpdate: return Theme.olive
            }
        }
    }
    
    var formattedTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
}

