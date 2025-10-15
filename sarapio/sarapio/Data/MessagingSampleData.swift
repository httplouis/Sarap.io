import Foundation

enum MessagingSampleData {
    static let threads: [MessageThread] = [
        MessageThread(
            user: "Ana",
            preview: "Promise, papadala ko recipe bukas!",
            relativeDate: "Now",
            messages: [
                .init(text: "Hey! I loved your Shrimp recipe 🍤", isMe: false),
                .init(text: "Thanks! I’ll post my Adobo soon 😄", isMe: true),
                .init(text: "Promise, papadala ko recipe bukas!", isMe: false)
            ]
        ),
        MessageThread(
            user: "Chef Mio",
            preview: "Pwede bang makuha yung marinade?",
            relativeDate: "1h",
            messages: [
                .init(text: "Bro, pa-share naman ng marinade measurements 👨‍🍳", isMe: false),
                .init(text: "Sige, send ko maya-maya!", isMe: true)
            ]
        ),
        MessageThread(
            user: "veggiequeen",
            preview: "Try mo dagdagan ng tofu",
            relativeDate: "1d",
            messages: [
                .init(text: "Try mo dagdagan ng tofu para mas busog!", isMe: false),
                .init(text: "Uy nice idea! will tweak it 😍", isMe: true)
            ]
        )
    ]
}
