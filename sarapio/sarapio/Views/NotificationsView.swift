import SwiftUI

struct NotificationsView: View {
    @State private var notifications: [AppNotification] = NotificationSampleData.notifications

    var body: some View {
        List {
            Section("Activity") {
                ForEach($notifications) { $notification in
                    NotificationRow(notification: $notification)
                        .listRowBackground(Theme.card)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(notification.isRead ? "Unread" : "Mark Read") {
                                notification.isRead.toggle()
                            }
                            .tint(notification.isRead ? .orange : Theme.olive)
                        }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Notifications")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Clear") { notifications.removeAll() }
                    .disabled(notifications.isEmpty)
            }
        }
    }
}

private struct NotificationRow: View {
    @Binding var notification: AppNotification

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(notification.isRead ? Theme.oliveSoft : Theme.olive)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: notification.isRead ? "bell" : "bell.badge.fill")
                        .foregroundStyle(notification.isRead ? Theme.olive : .white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                    .foregroundStyle(Theme.text)
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundStyle(Theme.subtext)
                Text(notification.relativeDate)
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}
