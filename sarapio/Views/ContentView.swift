import SwiftUI

enum BottomTab: Hashable {
    case recipes
    case feed
    case notifications
    case profile
}

struct ContentView: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var feedStore: SocialFeedStore
    @StateObject private var bottomBar = BottomBarState()

    @State private var showAddHub = false
    @State private var showMessages = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Main TabView
                TabView(selection: $bottomBar.selected) {
                    // 🍳 Recipes Tab
                    RecipesView()
                        .environmentObject(store)
                        .environmentObject(bottomBar)
                        .tabItem {
                            Label("Recipes", systemImage: "book.closed")
                        }
                        .tag(BottomTab.recipes)

                    // ✨ Feed Tab (with spacing)
                    SocialFeedView()
                        .environmentObject(feedStore)
                        .environmentObject(session)
                        .environmentObject(bottomBar)
                        .tabItem {
                            Label("Feed", systemImage: "sparkles")
                                .padding(.trailing, 28) // add spacing to right of Feed
                        }
                        .tag(BottomTab.feed)

                    // 🔔 Notifications Tab (with spacing)
                    NotificationsView()
                        .environmentObject(bottomBar)
                        .tabItem {
                            Label("Notifications", systemImage: "bell")
                                .padding(.leading, 28) // add spacing to left of Notifs
                        }
                        .tag(BottomTab.notifications)

                    // 👤 Profile Tab — added missing environmentObject(bottomBar)
                    ProfileView()
                        .environmentObject(session)
                        .environmentObject(store)
                        .environmentObject(bottomBar)
                        .tabItem {
                            Label("Profile", systemImage: "person.circle")
                        }
                        .tag(BottomTab.profile)
                }
                .tint(Theme.olive)
                .accentColor(Theme.olive)
                .toolbarBackground(Theme.bg, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    // ✈️ Message icon (top-right corner)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showMessages = true
                        } label: {
                            Image(systemName: "paperplane.fill")
                                .font(.title3)
                                .foregroundColor(Theme.olive)
                        }
                    }
                }
                .sheet(isPresented: $showMessages) {
                    NavigationStack {
                        MessagesView()
                            .environmentObject(session)
                            .navigationBarHidden(true)
                    }
                }

                // ➕ Floating Add Button (center)
                Button {
                    showAddHub = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .padding(22)
                        .background(Circle().fill(Theme.olive))
                        .shadow(radius: 8, y: 4)
                }
                .offset(y: -12)
                .sheet(isPresented: $showAddHub) {
                    NavigationStack {
                        AddHubView()
                            .environmentObject(store)
                            .environmentObject(session)
                            .environmentObject(feedStore)
                            .navigationTitle("Create")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                }
            }
            .background(Theme.bg.ignoresSafeArea())
        }
    }
}
 
