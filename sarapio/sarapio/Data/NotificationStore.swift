import Foundation
import SwiftUI

final class NotificationStore: ObservableObject {
    @Published var notifications: [AppNotification] = [] {
        didSet {
            saveNotifications()
        }
    }
    
    private let notificationsKey = "sarapio.notifications"
    
    init() {
        loadNotifications()
        if notifications.isEmpty {
            generateSampleNotifications()
        }
    }
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    func markAsRead(_ notification: AppNotification) {
        guard let index = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        notifications[index].isRead = true
    }
    
    func markAllAsRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }
    
    func delete(_ notification: AppNotification) {
        notifications.removeAll { $0.id == notification.id }
    }
    
    func clearAll() {
        notifications.removeAll()
    }
    
    func filter(by type: AppNotification.NotificationType?) -> [AppNotification] {
        guard let type else { return notifications }
        return notifications.filter { $0.type == type }
    }
    
    func getUnread() -> [AppNotification] {
        return notifications.filter { !$0.isRead }
    }
    
    func add(_ notification: AppNotification) {
        notifications.insert(notification, at: 0)
    }
    
    private func generateSampleNotifications() {
        let sampleNotifications: [AppNotification] = [
            AppNotification(
                id: UUID(),
                type: .like,
                title: "Ana",
                message: "liked your recipe \"Garlic Butter Shrimp\"",
                timestamp: Date().addingTimeInterval(-7200),
                isRead: false,
                relatedUserId: "ana",
                relatedRecipeId: nil
            ),
            AppNotification(
                id: UUID(),
                type: .comment,
                title: "Miko",
                message: "commented: \"Grabe ang sarap nito! Perfect for dinner!\"",
                timestamp: Date().addingTimeInterval(-18000),
                isRead: false,
                relatedUserId: "miko",
                relatedRecipeId: nil
            ),
            AppNotification(
                id: UUID(),
                type: .save,
                title: "Veena",
                message: "saved your recipe \"Chicken Adobo\"",
                timestamp: Date().addingTimeInterval(-86400),
                isRead: true,
                relatedUserId: "veena",
                relatedRecipeId: nil
            ),
            AppNotification(
                id: UUID(),
                type: .follow,
                title: "Lara",
                message: "started following you",
                timestamp: Date().addingTimeInterval(-172800),
                isRead: true,
                relatedUserId: "lara"
            ),
            AppNotification(
                id: UUID(),
                type: .achievement,
                title: "Achievement Unlocked!",
                message: "You've reached 10 recipe views! Keep cooking! 🎉",
                timestamp: Date().addingTimeInterval(-259200),
                isRead: true
            ),
            AppNotification(
                id: UUID(),
                type: .share,
                title: "Chef Demo",
                message: "shared your recipe \"Veggie Stir-Fry\"",
                timestamp: Date().addingTimeInterval(-345600),
                isRead: true,
                relatedUserId: "chef_demo",
                relatedRecipeId: nil
            ),
            AppNotification(
                id: UUID(),
                type: .system,
                title: "Welcome to Sarap.io!",
                message: "Start sharing your favorite recipes with the community. Happy cooking! 👨‍🍳",
                timestamp: Date().addingTimeInterval(-604800),
                isRead: true
            ),
            AppNotification(
                id: UUID(),
                type: .recipeUpdate,
                title: "Recipe Updated",
                message: "Your recipe \"Chicken Adobo\" was updated with new tips",
                timestamp: Date().addingTimeInterval(-691200),
                isRead: true,
                relatedRecipeId: nil
            )
        ]
        
        notifications = sampleNotifications
    }
    
    private func saveNotifications() {
        if let encoded = try? JSONEncoder().encode(notifications) {
            UserDefaults.standard.set(encoded, forKey: notificationsKey)
        }
    }
    
    private func loadNotifications() {
        guard let data = UserDefaults.standard.data(forKey: notificationsKey),
              let decoded = try? JSONDecoder().decode([AppNotification].self, from: data) else {
            return
        }
        notifications = decoded
    }
}

