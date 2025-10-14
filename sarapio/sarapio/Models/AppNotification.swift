import Foundation

struct AppNotification: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var message: String
    var relativeDate: String
    var isRead: Bool

    init(id: UUID = UUID(), title: String, message: String, relativeDate: String, isRead: Bool = false) {
        self.id = id
        self.title = title
        self.message = message
        self.relativeDate = relativeDate
        self.isRead = isRead
    }
}
