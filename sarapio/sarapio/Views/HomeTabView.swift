import SwiftUI

struct HomeTabView: View {
    @State private var selectedTab: Tab = .recipes
    @StateObject private var bottomBarState = BottomBarState()

    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var feedStore: SocialFeedStore

    enum Tab: Int, CaseIterable {
        case recipes
        case feed
        case add
        case notifications
        case messages
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

                NavigationStack { NotificationsView() }
                    .tag(Tab.notifications)

                NavigationStack { MessagesView() }
                    .tag(Tab.messages)

                NavigationStack { ProfileView() }
                    .tag(Tab.profile)
            }
            .environmentObject(bottomBarState)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .tint(Theme.olive)

            BottomNavigationBar(selectedTab: $selectedTab, isHidden: bottomBarState.isHidden)
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        }
        .onChange(of: selectedTab) { _ in
            bottomBarState.show()
            bottomBarState.reset()
        }
        .background(Theme.bg.ignoresSafeArea())
    }
}

private struct BottomNavigationBar: View {
    @Binding var selectedTab: HomeTabView.Tab
    var isHidden: Bool

    var body: some View {
        HStack(spacing: 0) {
            TabButton(icon: "book.fill", title: "Recipes", tab: .recipes, selectedTab: $selectedTab)
            Spacer(minLength: 12)
            TabButton(icon: "sparkles.rectangle.stack", title: "Feed", tab: .feed, selectedTab: $selectedTab)
            Spacer(minLength: 12)
            AddTabButton(tab: .add, selectedTab: $selectedTab)
            Spacer(minLength: 12)
            TabButton(icon: "bell.badge.fill", title: "Alerts", tab: .notifications, selectedTab: $selectedTab)
            Spacer(minLength: 12)
            TabButton(icon: "bubble.left.and.bubble.right.fill", title: "Messages", tab: .messages, selectedTab: $selectedTab)
            Spacer(minLength: 12)
            TabButton(icon: "person.crop.circle.fill", title: "Profile", tab: .profile, selectedTab: $selectedTab)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 6)
        .offset(y: isHidden ? 120 : 0)
        .animation(.easeInOut(duration: 0.25), value: isHidden)
    }
}

private struct TabButton: View {
    var icon: String
    var title: String
    var tab: HomeTabView.Tab
    @Binding var selectedTab: HomeTabView.Tab

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selectedTab = tab }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(selectedTab == tab ? Theme.olive : Theme.subtext)
                Text(title)
                    .font(.caption2)
                    .foregroundStyle(selectedTab == tab ? Theme.olive : Theme.subtext)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

private struct AddTabButton: View {
    var tab: HomeTabView.Tab
    @Binding var selectedTab: HomeTabView.Tab

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { selectedTab = tab }
        } label: {
            ZStack {
                Circle()
                    .fill(Theme.olive)
                    .frame(width: 64, height: 64)
                    .shadow(color: .black.opacity(0.16), radius: 10, y: 8)
                Image(systemName: "plus")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.white)
            }
        }
        .offset(y: -18)
        .buttonStyle(.plain)
    }
}
