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
            VStack(alignment: .leading, spacing: 6) {
                Text("Messages")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)
                Text("Chat with the community")
                    .font(.subheadline)
                    .foregroundStyle(Theme.subtext)
            }
            Spacer()
            
            Button {
                HapticManager.shared.light()
                // New message
            } label: {
                Image(systemName: "square.and.pencil")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Theme.olive, Theme.oliveDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Theme.olive.opacity(0.4), radius: 12, y: 6)
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private var conversationPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Array(conversations.enumerated()), id: \.offset) { index, conversation in
                    Button {
                        HapticManager.shared.selection()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            selectedConversationIndex = index
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(conversation.partner)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundStyle(selectedConversationIndex == index ? .white : Theme.text)
                            Text(conversation.preview)
                                .font(.caption)
                                .foregroundStyle(selectedConversationIndex == index ? .white.opacity(0.9) : Theme.subtext)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(
                                    selectedConversationIndex == index ?
                                    LinearGradient(
                                        colors: [Theme.olive, Theme.oliveDark],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ) :
                                    LinearGradient(
                                        colors: [Theme.card, Theme.card],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(
                                    color: selectedConversationIndex == index ? Theme.olive.opacity(0.3) : .black.opacity(0.05),
                                    radius: selectedConversationIndex == index ? 8 : 5,
                                    y: selectedConversationIndex == index ? 4 : 3
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(
                                    selectedConversationIndex == index ? Color.clear : Theme.border,
                                    lineWidth: 1
                                )
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
                        HStack(alignment: .bottom, spacing: 8) {
                            if message.isMe { Spacer() }
                            VStack(alignment: message.isMe ? .trailing : .leading, spacing: 6) {
                                Text(message.text)
                                    .font(.system(size: 15, weight: .regular, design: .rounded))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(
                                                message.isMe ?
                                                LinearGradient(
                                                    colors: [Theme.olive, Theme.oliveDark],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ) :
                                                LinearGradient(
                                                    colors: [Theme.card, Theme.card],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                            .shadow(
                                                color: message.isMe ? Theme.olive.opacity(0.2) : .black.opacity(0.05),
                                                radius: 8,
                                                y: 4
                                            )
                                    )
                                    .foregroundStyle(message.isMe ? .white : Theme.text)
                                Text(message.time)
                                    .font(.caption2)
                                    .foregroundStyle(Theme.subtext)
                                    .padding(.horizontal, 4)
                            }
                            if !message.isMe { Spacer() }
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
            .onChange(of: selectedConversationIndex) { oldValue, newValue in
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
                .textInputAutocapitalization(.sentences)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Theme.card)
                        .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Theme.border, lineWidth: 1)
                )
            
            Button {
                let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                HapticManager.shared.success()
                let message = ChatMessage(text: trimmed, isMe: true, time: "Now")
                conversations[selectedConversationIndex].messages.append(message)
                conversations[selectedConversationIndex].preview = trimmed
                inputText = ""
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Theme.olive, Theme.oliveDark],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Theme.olive.opacity(0.3), radius: 8, y: 4)
                    )
            }
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [Theme.bg, Theme.bg.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
