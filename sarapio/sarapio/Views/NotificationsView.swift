import SwiftUI

struct NotificationsView: View {
    @EnvironmentObject private var bottomBar: BottomBarState
    @EnvironmentObject private var notificationStore: NotificationStore
    @State private var selectedFilter: AppNotification.NotificationType? = nil
    @State private var showUnreadOnly = false

    private var filteredNotifications: [AppNotification] {
        var filtered = notificationStore.notifications
        
        if showUnreadOnly {
            filtered = filtered.filter { !$0.isRead }
        }
        
        if let type = selectedFilter {
            filtered = filtered.filter { $0.type == type }
        }
        
        return filtered
    }

    var body: some View {
        VStack(spacing: 0) {
            // Filter bar
            filterBar
            
            ScrollView {
                GeometryReader { proxy in
                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .global).minY)
                }
                .frame(height: 0)

                if filteredNotifications.isEmpty {
                    emptyStateView
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(filteredNotifications) { notification in
                            NotificationRow(notification: notification, store: notificationStore)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 100) // Add bottom padding for nav bar
                }
            }
        }
        .background(Theme.bg.ignoresSafeArea())
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { bottomBar.handleScroll(offset: $0) }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                NavigationLink {
                    MessagesView()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.olive)
                }
                
                if notificationStore.unreadCount > 0 {
                    Menu {
                        Button {
                            notificationStore.markAllAsRead()
                        } label: {
                            Label("Mark All as Read", systemImage: "checkmark.circle")
                        }
                        Button(role: .destructive) {
                            notificationStore.clearAll()
                        } label: {
                            Label("Clear All", systemImage: "trash")
                        }
                    } label: {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "ellipsis.circle")
                            if notificationStore.unreadCount > 0 {
                                Text("\(notificationStore.unreadCount)")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(4)
                                    .background(Circle().fill(.red))
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
            }
        }
        .onAppear { bottomBar.reset() }
    }
    
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: selectedFilter == nil && !showUnreadOnly,
                    count: notificationStore.notifications.count
                ) {
                    selectedFilter = nil
                    showUnreadOnly = false
                }
                
                FilterChip(
                    title: "Unread",
                    isSelected: showUnreadOnly,
                    count: notificationStore.unreadCount,
                    icon: "circle.fill"
                ) {
                    showUnreadOnly = true
                    selectedFilter = nil
                }
                
                ForEach(AppNotification.NotificationType.allCases, id: \.self) { type in
                    let count = notificationStore.filter(by: type).count
                    if count > 0 {
                        FilterChip(
                            title: type.rawValue.capitalized,
                            isSelected: selectedFilter == type,
                            count: count,
                            icon: type.icon
                        ) {
                            selectedFilter = type
                            showUnreadOnly = false
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Theme.card)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 64))
                .foregroundStyle(Theme.subtext.opacity(0.5))
            Text("No notifications")
                .font(.headline)
                .foregroundStyle(Theme.text)
            Text(showUnreadOnly ? "You're all caught up!" : "When you get notifications, they'll appear here")
                .font(.footnote)
                .foregroundStyle(Theme.subtext)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

private struct NotificationRow: View {
    let notification: AppNotification
    @ObservedObject var store: NotificationStore
    
    var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(notification.type.color.opacity(0.15))
                    .frame(width: 48, height: 48)
                Image(systemName: notification.type.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(notification.type.color)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundStyle(Theme.text)
                    if !notification.isRead {
                        Circle()
                            .fill(Theme.olive)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundStyle(Theme.subtext)
                    .lineLimit(2)
                
                Text(notification.formattedTime)
                    .font(.caption2)
                    .foregroundStyle(Theme.subtext.opacity(0.7))
            }
            
            Spacer()
            
            // Actions
            Menu {
                if !notification.isRead {
                    Button {
                        store.markAsRead(notification)
                    } label: {
                        Label("Mark as Read", systemImage: "checkmark.circle")
                    }
                }
                Button(role: .destructive) {
                    store.delete(notification)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.caption)
                    .foregroundStyle(Theme.subtext)
                    .padding(8)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(notification.isRead ? Theme.card : Theme.oliveSoft.opacity(0.3))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Theme.border, lineWidth: notification.isRead ? 1 : 0)
        )
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            if !notification.isRead {
                store.markAsRead(notification)
            }
        }
    }
}

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let count: Int
    var icon: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption2)
                }
                Text(title)
                    .font(.system(size: 13, weight: isSelected ? .semibold : .medium))
                if count > 0 {
                    Text("(\(count))")
                        .font(.system(size: 11, weight: .medium))
                        .opacity(0.7)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Theme.olive : Theme.oliveSoft.opacity(0.5))
            )
            .foregroundStyle(isSelected ? .white : Theme.olive)
        }
    }
}


