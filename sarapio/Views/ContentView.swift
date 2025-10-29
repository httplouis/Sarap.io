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

    @State private var selectedTab: BottomTab = .recipes
    @State private var showAddHub = false
    @State private var showMessages = false

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Tab Content
                Group {
                    switch selectedTab {
                    case .recipes:
                        RecipesView()
                            .environmentObject(store)
                            .environmentObject(bottomBar)
                    case .feed:
                        SocialFeedView()
                            .environmentObject(feedStore)
                            .environmentObject(session)
                            .environmentObject(bottomBar)
                    case .notifications:
                        NotificationsView()
                            .environmentObject(bottomBar)
                    case .profile:
                        ProfileView()
                            .environmentObject(session)
                            .environmentObject(bottomBar)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.bg.ignoresSafeArea())

                // MARK: - Bottom Bar + Half Floating Add Button
                VStack(spacing: 0) {
                    Spacer()
                    ZStack {
                        // Tab bar background
                        VStack(spacing: 0) {
                            Divider()
                            HStack {
                                TabButton(icon: "book.closed", title: "Recipes", tab: .recipes, selected: $selectedTab)
                                TabButton(icon: "sparkles", title: "Feed", tab: .feed, selected: $selectedTab)
                                Spacer(minLength: 60)
                                TabButton(icon: "bell", title: "Notifications", tab: .notifications, selected: $selectedTab)
                                TabButton(icon: "person.circle", title: "Profile", tab: .profile, selected: $selectedTab)
                            }
                            .padding(.top, 6)
                            .padding(.bottom, 12)
                            .background(Theme.card)
                        }

                        // Half-floating Add button
                        Button {
                            showAddHub = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 58, height: 58)
                                .background(Circle().fill(Theme.olive))
                                .shadow(color: .black.opacity(0.25), radius: 8, y: 4)
                        }
                        .offset(y: -28) // half-floating position
                    }
                }
            }
            .toolbar {
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
            .sheet(isPresented: $showMessages) {
                NavigationStack {
                    MessagesView()
                        .environmentObject(session)
                        .navigationBarHidden(true)
                }
            }
        }
    }
}

// MARK: - Tab Button
private struct TabButton: View {
    var icon: String
    var title: String
    var tab: BottomTab
    @Binding var selected: BottomTab

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { selected = tab }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(selected == tab ? Theme.olive : Theme.subtext)
                Text(title)
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .foregroundStyle(selected == tab ? Theme.olive : Theme.subtext)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}
