import SwiftUI

struct MessagesView: View {
    struct ChatMessage: Identifiable {
        let id = UUID()
        let text: String
        let isMe: Bool
    }

    @State private var messages: [ChatMessage] = [
        ChatMessage(text: "Hey! I loved your Shrimp recipe 🍤", isMe: false),
        ChatMessage(text: "Thanks! I’ll post my Adobo soon 😄", isMe: true)
    ]
    @State private var inputText = ""

    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(messages) { msg in
                            HStack {
                                if msg.isMe { Spacer() }
                                Text(msg.text)
                                    .padding(10)
                                    .background(msg.isMe ? Theme.olive : Theme.card)
                                    .foregroundStyle(msg.isMe ? .white : Theme.text)
                                    .cornerRadius(12)
                                    .frame(maxWidth: 280, alignment: msg.isMe ? .trailing : .leading)
                                if !msg.isMe { Spacer() }
                            }
                        }
                    }
                    .padding()
                }
            }
            
            HStack {
                TextField("Message...", text: $inputText)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
                Button {
                    if !inputText.isEmpty {
                        messages.append(ChatMessage(text: inputText, isMe: true))
                        inputText = ""
                    }
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
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
    }
}
