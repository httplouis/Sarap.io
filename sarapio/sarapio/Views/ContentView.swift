import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @State private var showAdd = false

    var body: some View {
        ZStack {
            // Main Tabs
            TabView(selection: $selectedTab) {

                // 1. Feed
                NavigationStack {
                    SocialFeedView()
                }
                .tag(0)

                // 2. Add (center button)
                NavigationStack {
                    AddRecipeView()
                }
                .tag(1)

                // 3. My Recipes
                NavigationStack {
                    RecipesView()
                        .navigationTitle("My Recipes")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tag(2)

                // 4. Notifications
                NavigationStack {
                    NotificationsView()
                        .navigationTitle("Notifications")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tag(3)

                // 5. Profile
                NavigationStack {
                    ProfileView()
                        .navigationTitle("Profile")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tag(4)
            }
            .tint(Theme.olive)
            .tabViewStyle(.page(indexDisplayMode: .never))

            // --- Bottom Nav Bar ---
            VStack {
                Spacer()

                ZStack {
                    HStack {
                        TabIcon(icon: "house.fill", index: 0, selectedTab: $selectedTab)
                        Spacer()
                        TabIcon(icon: "book.fill", index: 2, selectedTab: $selectedTab)
                        Spacer()
                        TabIcon(icon: "bell.fill", index: 3, selectedTab: $selectedTab)
                        Spacer()
                        TabIcon(icon: "person.crop.circle.fill", index: 4, selectedTab: $selectedTab)
                    }
                    .padding(.horizontal, 40)
                    .frame(height: 58) // shorter height
                    .background(.ultraThinMaterial)
                    .cornerRadius(22)
                    .padding(.horizontal, 22)
                    .shadow(color: .black.opacity(0.08), radius: 4, y: 2)

                    // Floating + Button (centered)
                    Button {
                        showAdd = true
                    } label: {
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
                    .offset(y: -28) // overlaps nicely in the middle
                    .sheet(isPresented: $showAdd) {
                        NavigationStack { AddRecipeView() }
                    }
                }
                .padding(.bottom, 8)
            }
        }
        .background(Theme.bg.ignoresSafeArea())
    }
}

// --- Tab Icons ---
struct TabIcon: View {
    var icon: String
    var index: Int
    @Binding var selectedTab: Int

    var body: some View {
        Button {
            withAnimation(.easeInOut) { selectedTab = index }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(selectedTab == index ? Theme.olive : Theme.subtext)
        }
    }
}
