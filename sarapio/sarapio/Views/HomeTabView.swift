import SwiftUI

struct HomeTabView: View {
    @State private var selectedTab: Tab = .recipes
    @StateObject private var bottomBarState = BottomBarState()

    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var feedStore: SocialFeedStore
    @EnvironmentObject private var notificationStore: NotificationStore

    enum Tab: Int, CaseIterable {
        case recipes
        case feed
        case add
        case ai
        case notifications
        case profile
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationStack { RecipesView() }
                    .tag(Tab.recipes)

                NavigationStack { SocialFeedView() }
                    .tag(Tab.feed)

                NavigationStack { AddHubView() }
                    .tag(Tab.add)

                NavigationStack { AIChatView() }
                    .tag(Tab.ai)

                NavigationStack { NotificationsView() }
                    .tag(Tab.notifications)

                NavigationStack { ProfileView() }
                    .tag(Tab.profile)
            }
            .environmentObject(bottomBarState)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .tint(Theme.olive)

            BottomNavigationBar(
                selectedTab: $selectedTab,
                isHidden: bottomBarState.isHidden,
                unreadCount: notificationStore.unreadCount
            )
            .padding(.horizontal, 20)
            .padding(.bottom, 4)
        }
        .onChange(of: selectedTab) { _, _ in
            bottomBarState.show()
            bottomBarState.reset()
        }
        .background(Theme.bg.ignoresSafeArea())
    }
}

private struct BottomNavigationBar: View {
    @Binding var selectedTab: HomeTabView.Tab
    var isHidden: Bool
    var unreadCount: Int

    var body: some View {
        HStack(spacing: 0) {
            // Left side tabs (3 tabs)
            HStack(spacing: 0) {
                TabButton(icon: "book.fill", title: "Recipes", tab: .recipes, selectedTab: $selectedTab)
                TabButton(icon: "sparkles.rectangle.stack", title: "Feed", tab: .feed, selectedTab: $selectedTab)
                TabButton(icon: "sparkles", title: "AI", tab: .ai, selectedTab: $selectedTab)
            }
            .frame(maxWidth: .infinity)
            
            // Center add button
            AddTabButton(tab: .add, selectedTab: $selectedTab)
                .frame(width: 56, height: 56)
            
            // Right side tabs (2 tabs)
            HStack(spacing: 0) {
                TabButtonWithBadge(
                    icon: selectedTab == .notifications ? "bell.fill" : "bell",
                    title: "Notifications",
                    tab: .notifications,
                    selectedTab: $selectedTab,
                    badgeCount: unreadCount
                )
                TabButton(icon: "person.crop.circle.fill", title: "Profile", tab: .profile, selectedTab: $selectedTab)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.1), radius: 12, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        )
        .offset(y: isHidden ? 120 : 0)
        .padding(.bottom, 4) // Lower the nav bar
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isHidden)
    }
}

private struct TabButton: View {
    var icon: String
    var title: String
    var tab: HomeTabView.Tab
    @Binding var selectedTab: HomeTabView.Tab

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { 
                selectedTab = tab 
            }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 22, weight: selectedTab == tab ? .semibold : .medium))
                .foregroundStyle(selectedTab == tab ? Theme.olive : Theme.subtext)
                .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct TabButtonWithBadge: View {
    var icon: String
    var title: String
    var tab: HomeTabView.Tab
    @Binding var selectedTab: HomeTabView.Tab
    var badgeCount: Int

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { 
                selectedTab = tab 
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: selectedTab == tab ? .semibold : .medium))
                    .foregroundStyle(selectedTab == tab ? Theme.olive : Theme.subtext)
                    .scaleEffect(selectedTab == tab ? 1.1 : 1.0)
                
                if badgeCount > 0 {
                    Text(badgeCount > 99 ? "99+" : "\(badgeCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(minWidth: 18, minHeight: 18)
                        .padding(.horizontal, badgeCount > 9 ? 4 : 0)
                        .background(
                            Capsule()
                                .fill(Color.red)
                                .shadow(color: .red.opacity(0.5), radius: 2, y: 1)
                        )
                        .overlay(
                            Capsule()
                                .stroke(.white, lineWidth: 1.5)
                        )
                        .offset(x: 10, y: -8)
                }
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct AddTabButton: View {
    var tab: HomeTabView.Tab
    @Binding var selectedTab: HomeTabView.Tab
    @State private var isPressed = false
    
    private var isSelected: Bool {
        selectedTab == tab
    }
    
    private var rotationAngle: Double {
        isSelected ? 45 : 0
    }

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { 
                selectedTab = tab 
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Theme.olive)
                    .frame(width: 56, height: 56)
                    .shadow(color: Theme.olive.opacity(0.4), radius: 8, y: 4)
                    .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .rotationEffect(.degrees(rotationAngle))
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
