import SwiftUI

struct NotificationsView: View {
    private let dummy = [
        ("chef_ana", "liked your post 🍲", "2h"),
        ("veggiequeen", "commented: 'Ang sarap nito! 😋'", "5h"),
        ("foodieluke", "started following you", "1d")
    ]
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(dummy, id: \.0) { n in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Theme.olive)
                            .frame(width: 44, height: 44)
                            .overlay(Text(String(n.0.prefix(1)).uppercased())
                                     .font(.headline)
                                     .foregroundStyle(.white))
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("@\(n.0)")
                                .font(.headline)
                            Text(n.1)
                                .foregroundStyle(Theme.text)
                            Text(n.2)
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        Spacer()
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 3)
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .background(Theme.bg.ignoresSafeArea())
    }
}
