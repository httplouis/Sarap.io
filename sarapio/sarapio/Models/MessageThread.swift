import Foundation

struct MessageThread: Identifiable, Hashable, Codable {
    struct ChatMessage: Identifiable, Hashable, Codable {
        let id: UUID
        let text: String
        let isMe: Bool
        let timestamp: Date

        init(id: UUID = UUID(), text: String, isMe: Bool, timestamp: Date = .init()) {
            self.id = id
            self.text = text
            self.isMe = isMe
            self.timestamp = timestamp
        }
    }

    let id: UUID
    var user: String
    var preview: String
    var relativeDate: String
    var messages: [ChatMessage]

    init(
        id: UUID = UUID(),
        user: String,
        preview: String,
        relativeDate: String,
        messages: [ChatMessage]
    ) {
        self.id = id
        self.user = user
        self.preview = preview
        self.relativeDate = relativeDate
        self.messages = messages
    }
}
