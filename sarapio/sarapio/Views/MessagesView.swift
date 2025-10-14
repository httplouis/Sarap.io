import SwiftUI

struct MessagesView: View {
    @State private var threads: [MessageThread] = MessagingSampleData.threads

    var body: some View {
        List {
            Section("Inbox") {
                ForEach(threads) { thread in
                    NavigationLink(value: thread) {
                        ConversationCell(thread: thread)
                    }
                    .listRowBackground(Theme.card)
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.bg.ignoresSafeArea())
        .navigationDestination(for: MessageThread.self) { thread in
            ChatThreadView(thread: thread)
        }
        .navigationTitle("Messages")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("New Chat") { /* placeholder for finals */ }
                    .disabled(true)
            }
        }
    }
}

private struct ConversationCell: View {
    let thread: MessageThread

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Theme.olive)
                .frame(width: 46, height: 46)
                .overlay(Text(String(thread.user.prefix(2))).uppercase().fontWeight(.bold).foregroundStyle(.white))

            VStack(alignment: .leading, spacing: 4) {
                Text(thread.user)
                    .font(.headline)
                Text(thread.preview)
                    .font(.subheadline)
                    .foregroundStyle(Theme.subtext)
            }
            Spacer()
            Text(thread.relativeDate)
                .font(.caption)
                .foregroundStyle(Theme.subtext)
        }
        .padding(.vertical, 6)
    }
}

private struct ChatThreadView: View {
    @State private var thread: MessageThread
    @State private var inputText = ""

    init(thread: MessageThread) {
        _thread = State(initialValue: thread)
    }

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(thread.messages) { message in
                            HStack {
                                if message.isMe { Spacer() }
                                Text(message.text)
                                    .padding(10)
                                    .background(message.isMe ? Theme.olive : Theme.card)
                                    .foregroundStyle(message.isMe ? .white : Theme.text)
                                    .cornerRadius(12)
                                    .frame(maxWidth: 280, alignment: message.isMe ? .trailing : .leading)
                                if !message.isMe { Spacer() }
                            }
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onAppear {
                    if let last = thread.messages.last { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }

            HStack {
                TextField("Message...", text: $inputText)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.olive)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle(thread.user)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        thread.messages.append(.init(text: trimmed, isMe: true))
        inputText = ""
    }
}
