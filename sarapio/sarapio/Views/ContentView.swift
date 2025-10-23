import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var auth: AuthManager

    var body: some View {
        Group {
            if auth.currentUser != nil {
                MainTabView()
            } else {
                AuthenticationView()
            }
        }
        .animation(.easeInOut, value: auth.currentUser != nil)
    }
}

// MARK: - Main Tabs Enum
enum MainTab: Int, CaseIterable {
    case recipes, feed, notifications, messages, profile
}

// MARK: - Main TabView
struct MainTabView: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var auth: AuthManager

    @State private var selectedTab: MainTab = .recipes
    @State private var showAddRecipe = false
    @State private var showAddPost = false

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                RecipesView()
                    .embedInNav("My Recipes")
                    .tag(MainTab.recipes)

                SocialFeedView(showComposer: $showAddPost)
                    .embedInNav("Feed")
                    .tag(MainTab.feed)

                NotificationsView()
                    .embedInNav("Notifications")
                    .tag(MainTab.notifications)

                MessagesView()
                    .embedInNav("Messages")
                    .tag(MainTab.messages)

                ProfileView()
                    .embedInNav("Profile")
                    .tag(MainTab.profile)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack {
                Spacer()
                BottomBar(selectedTab: $selectedTab) {
                    showAddRecipe = true
                }
                .padding(.bottom, 8)
            }
        }
        .sheet(isPresented: $showAddRecipe) {
            NavigationStack { AddRecipeView() }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Logout") { auth.logout() }
            }
        }
        .background(Theme.bg.ignoresSafeArea())
    }
}

// MARK: - Bottom Bar
struct BottomBar: View {
    @Binding var selectedTab: MainTab
    var addRecipeAction: () -> Void

    private let tabs: [MainTab] = MainTab.allCases

    var body: some View {
        ZStack {
            HStack {
                ForEach(tabs, id: \.self) { tab in
                    Spacer()
                    Button {
                        withAnimation(.easeInOut) { selectedTab = tab }
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: icon(for: tab))
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(selectedTab == tab ? Theme.olive : Theme.subtext)
                            Text(label(for: tab))
                                .font(.caption2)
                                .foregroundStyle(selectedTab == tab ? Theme.olive : Theme.subtext)
                        }
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 18)
            .frame(height: 64)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 22)
            .shadow(color: .black.opacity(0.08), radius: 6, y: 3)

            Button(action: addRecipeAction) {
                ZStack {
                    Circle()
                        .fill(Theme.olive)
                        .frame(width: 64, height: 64)
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
                    Image(systemName: "plus")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .offset(y: -36)
        }
    }

    private func icon(for tab: MainTab) -> String {
        switch tab {
        case .recipes: return "book.fill"
        case .feed: return "leaf.fill"
        case .notifications: return "bell.badge.fill"
        case .messages: return "bubble.left.and.bubble.right.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }

    private func label(for tab: MainTab) -> String {
        switch tab {
        case .recipes: return "Recipes"
        case .feed: return "Feed"
        case .notifications: return "Alerts"
        case .messages: return "Messages"
        case .profile: return "Profile"
        }
    }
}

// MARK: - Navigation Helper
extension View {
    func embedInNav(_ title: String) -> some View {
        NavigationStack {
            self
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
