import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var bottomBar: BottomBarState
    @EnvironmentObject private var session: SessionManager
    @StateObject private var repo = NotificationsRepo()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                GeometryReader { proxy in
                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .global).minY)
                }
                .frame(height: 0)

                if repo.isLoading && repo.notifications.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading notifications...")
                            .font(.footnote)
                            .foregroundStyle(Theme.subtext)
                        Spacer()
                    }
                    .frame(height: 400)
                } else if repo.notifications.isEmpty {
                    EmptyNotificationsView()
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(repo.notifications) { notification in
                            NotificationRow(notification: notification)
                                .padding(.horizontal, 20)
                                .onTapGesture {
                                    HapticManager.shared.light()
                                    Task {
                                        await repo.markAsRead(notification.id)
                                    }
                                }
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 100) // Extra padding for bottom bar
                }
            }
            .background(Theme.bg)
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { bottomBar.handleScroll(offset: $0) }
            .onAppear {
                bottomBar.reset()
                if let userId = session.currentUser?.id {
                    Task {
                        await repo.fetchAll(for: userId)
                    }
                }
            }
            .refreshable {
                if let userId = session.currentUser?.id {
                    await repo.fetchAll(for: userId)
                }
            }
        }
        .safeAreaInset(edge: .top) { Color.clear.frame(height: 0) }
    }
}

private struct NotificationRow: View {
    let notification: Notification
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.oliveSoft.opacity(0.6))
                    .frame(width: 52, height: 52)
                Image(systemName: notification.icon)
                    .font(.title3)
                    .foregroundStyle(Theme.olive)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.message)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Theme.text)
                    .lineLimit(2)
                
                Text(notification.timeAgo)
                    .font(.caption)
                    .foregroundStyle(Theme.subtext)
            }
            
            Spacer()
            
            if !notification.is_read {
                Circle()
                    .fill(Theme.olive)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(notification.is_read ? Theme.card : Theme.oliveSoft.opacity(0.2))
        )
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 4)
    }
}

private struct EmptyNotificationsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "bell.slash")
                .font(.system(size: 64))
                .foregroundStyle(Theme.subtext.opacity(0.5))
            
            Text("No Notifications")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.text)
            
            Text("When people interact with your recipes, you'll see notifications here.")
                .font(.subheadline)
                .foregroundStyle(Theme.subtext)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(height: 400)
    }
}
