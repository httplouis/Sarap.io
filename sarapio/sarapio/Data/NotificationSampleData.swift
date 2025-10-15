import Foundation

enum NotificationSampleData {
    static let notifications: [AppNotification] = [
        AppNotification(title: "Ana liked your recipe", message: "Garlic Butter Shrimp gained a heart!", relativeDate: "2h"),
        AppNotification(title: "Chef Mio rated your Adobo", message: "5 ⭐️ — \"Sobrang sarap!\"", relativeDate: "5h"),
        AppNotification(title: "veggiequeen sent you a message", message: "Let's collab on a veggie menu?", relativeDate: "1d"),
        AppNotification(title: "New follower", message: "foodieluke is now following you", relativeDate: "2d"),
        AppNotification(title: "Ana liked your recipe", message: "Veggie Stir-Fry is trending!", relativeDate: "3d")
    ]
}
