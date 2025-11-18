import SwiftUI

struct MessagesView: View {
    struct Conversation: Identifiable {
        let id = UUID()
        var partner: String
        var preview: String
        var messages: [ChatMessage]
    }

    struct ChatMessage: Identifiable {
        let id = UUID()
        let text: String
        let isMe: Bool
        let time: String
    }

    @EnvironmentObject private var bottomBar: BottomBarState

    @State private var conversations: [Conversation] = [
        Conversation(partner: "Ana", preview: "Loved your shrimp recipe!", messages: [
            ChatMessage(text: "Hey! I loved your Shrimp recipe 🍤", isMe: false, time: "7:42 PM"),
            ChatMessage(text: "Thanks! It’s my go-to weeknight dish.", isMe: true, time: "7:45 PM"),
            ChatMessage(text: "Can you send me the steps?", isMe: false, time: "7:46 PM")
        ]),
        Conversation(partner: "Miko", preview: "Game for collab post?", messages: [
            ChatMessage(text: "Game for a collab post this weekend?", isMe: false, time: "3:12 PM"),
            ChatMessage(text: "Sure! Let’s plan a halo-halo recipe. 😄", isMe: true, time: "3:14 PM")
        ])
    ]

    @State private var selectedConversationIndex: Int = 0
    @State private var inputText = ""

    private var selectedConversation: Conversation {
        conversations[selectedConversationIndex]
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            conversationPicker
            Divider()
            chatLog
            messageComposer
        }
        .background(Theme.bg.ignoresSafeArea())
        .onAppear { bottomBar.reset() }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Messages")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("Real-time chat coming Finals week!")
                    .font(.footnote)
                    .foregroundStyle(Theme.subtext)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    private var conversationPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(conversations.enumerated()), id: \.offset) { index, conversation in
                    Button {
                        withAnimation(.easeInOut) { selectedConversationIndex = index }
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(conversation.partner)
                                .font(.headline)
                                .foregroundStyle(selectedConversationIndex == index ? .white : Theme.text)
                            Text(conversation.preview)
                                .font(.caption)
                                .foregroundStyle(selectedConversationIndex == index ? .white.opacity(0.8) : Theme.subtext)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(selectedConversationIndex == index ? Theme.olive : Theme.card)
                                .shadow(color: .black.opacity(0.05), radius: 5, y: 3)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    private var chatLog: some View {
        ScrollViewReader { proxy in
            ScrollView {
                GeometryReader { proxyGeo in
                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: proxyGeo.frame(in: .global).minY)
                }
                .frame(height: 0)

                LazyVStack(spacing: 12) {
                    ForEach(selectedConversation.messages) { message in
                        HStack {
                            if message.isMe { Spacer() }
                            VStack(alignment: message.isMe ? .trailing : .leading, spacing: 6) {
                                Text(message.text)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .background(RoundedRectangle(cornerRadius: 18).fill(message.isMe ? Theme.olive : Theme.card))
                                    .foregroundStyle(message.isMe ? .white : Theme.text)
                                Text(message.time)
                                    .font(.caption2)
                                    .foregroundStyle(Theme.subtext)
                            }
                            if !message.isMe { Spacer() }
                        }
                        .transition(.opacity)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .onChange(of: selectedConversationIndex) { _, _ in
                if let last = selectedConversation.messages.last {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(last.id, anchor: .bottom)
                    }
                }
            }
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { bottomBar.handleScroll(offset: $0) }
    }

    private var messageComposer: some View {
        HStack(spacing: 12) {
            TextField("Message…", text: $inputText)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
            Button {
                let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                let message = ChatMessage(text: trimmed, isMe: true, time: "Now")
                conversations[selectedConversationIndex].messages.append(message)
                conversations[selectedConversationIndex].preview = trimmed
                inputText = ""
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.title3)
                    .foregroundStyle(Theme.olive)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Theme.bg)
    }
}
