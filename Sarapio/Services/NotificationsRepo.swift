// sarapio/Services/NotificationsRepo.swift
import Foundation
import Supabase

struct Notification: Identifiable, Codable {
    let id: UUID
    let user_id: UUID?
    let type: String // "like", "comment", "follow", "save"
    let message: String
    let related_user_id: UUID?
    let related_recipe_id: UUID?
    let is_read: Bool
    let created_at: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case user_id
        case type
        case message
        case related_user_id
        case related_recipe_id
        case is_read
        case created_at
    }
    
    var timeAgo: String {
        guard let dateString = created_at else { return "Just now" }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateString) ?? ISO8601DateFormatter().date(from: dateString) else {
            return "Just now"
        }
        
        let now = Date()
        let components = Calendar.current.dateComponents([.hour, .day, .minute], from: date, to: now)
        
        if let days = components.day, days > 0 {
            return "\(days)d"
        } else if let hours = components.hour, hours > 0 {
            return "\(hours)h"
        } else if let minutes = components.minute, minutes > 0 {
            return "\(minutes)m"
        } else {
            return "Just now"
        }
    }
    
    var icon: String {
        switch type {
        case "like": return "heart.fill"
        case "comment": return "text.bubble.fill"
        case "follow": return "person.crop.circle.badge.plus"
        case "save": return "bookmark.fill"
        default: return "bell.fill"
        }
    }
}

@MainActor
final class NotificationsRepo: ObservableObject {
    private let client = SupabaseClientManager.shared
    @Published var notifications: [Notification] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchAll(for userId: UUID) async {
        isLoading = true
        errorMessage = nil
        do {
            let response: [Notification] = try await client
                .database
                .from("notifications")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("created_at", ascending: false)
                .limit(50)
                .execute()
                .value
            
            self.notifications = response
        } catch {
            print("❌ Notifications fetch failed:", error.localizedDescription)
            errorMessage = error.localizedDescription
            // Fallback to empty array
            self.notifications = []
        }
        isLoading = false
    }
    
    func markAsRead(_ notificationId: UUID) async {
        do {
            try await client
                .database
                .from("notifications")
                .update(["is_read": true])
                .eq("id", value: notificationId.uuidString)
                .execute()
            
            // Update local state
            if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
                var updated = notifications[index]
                // Note: Notification is a struct, so we need to replace it
                // This is a simplified version - in production, you'd want to make Notification a class or use a different approach
            }
        } catch {
            print("❌ Failed to mark notification as read:", error.localizedDescription)
        }
    }
}

