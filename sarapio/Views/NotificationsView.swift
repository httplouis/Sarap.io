import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var bottomBar: BottomBarState

    private let notifications = [
        ("Ana", "Ana liked your recipe.", "2h", "heart.fill"),
        ("Miko", "Miko commented: “Grabe ang sarap nito!”", "5h", "text.bubble.fill"),
        ("Veena", "Veena saved your Garlic Butter Shrimp.", "1d", "bookmark.fill"),
        ("System", "We’re prepping live sync for Finals.", "2d", "bolt.horizontal.fill"),
        ("Lara", "Lara started following you.", "3d", "person.crop.circle.badge.plus")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                GeometryReader { proxy in
                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .global).minY)
                }
                .frame(height: 0)

                LazyVStack(spacing: 16) {
                    ForEach(Array(notifications.enumerated()), id: \.offset) { _, notification in
                        NotificationRow(notification: notification)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(Theme.bg)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { bottomBar.handleScroll(offset: $0) }
            .onAppear { bottomBar.reset() }
        }
        .safeAreaInset(edge: .top) { Color.clear.frame(height: 0) }
    }
}

private struct NotificationRow: View {
    var notification: (String, String, String, String)
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(Theme.oliveSoft).frame(width: 52, height: 52)
                Image(systemName: notification.3).foregroundStyle(Theme.olive)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.0).font(.headline)
                Text(notification.1).font(.subheadline).foregroundStyle(Theme.text)
                Text(notification.2).font(.caption).foregroundStyle(Theme.subtext)
            }
            Spacer()
        }
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 22).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 4)
    }
}
