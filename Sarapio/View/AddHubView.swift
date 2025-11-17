import SwiftUI

struct AddHubView: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @StateObject private var apiService = RecipeAPIService()
    
    @State private var showAddRecipe = false
    @State private var showAddPost = false
    @State private var showAPISearch = false
    @State private var searchQuery = ""
    @State private var isSearching = false

    var body: some View {
        mainContent
            .background(Theme.bg)
            .navigationTitle("Create")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(isPresented: $showAddRecipe) {
                addRecipeSheet
            }
            .sheet(isPresented: $showAddPost) {
                AddSocialPostViewWrapper()
            }
            .sheet(isPresented: $showAPISearch) {
                apiSearchSheet
            }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: 24) {
                heroCards
                apiSearchSection
                quickActionsSection
            }
            .padding(24)
            .safeAreaPadding(.top)
        }
    }
    
    private var addRecipeSheet: some View {
        NavigationStack { AddRecipeView() }
            .environmentObject(store)
            .environmentObject(session)
    }
    
    private var apiSearchSheet: some View {
        APISearchResultsView(apiService: apiService)
            .environmentObject(store)
            .environmentObject(session)
    }
    
    private var heroCards: some View {
        VStack(spacing: 24) {
            HeroCard(
                title: "Add a Recipe",
                subtitle: "Share your kitchen masterpiece",
                icon: "fork.knife",
                gradient: [Theme.olive, Theme.oliveDark]
            ) {
                HapticManager.shared.medium()
                showAddRecipe = true
            }

            HeroCard(
                title: "Create a Post",
                subtitle: "Tell the community what you're cooking",
                icon: "sparkles",
                gradient: [Color.purple, Color.pink]
            ) {
                HapticManager.shared.medium()
                showAddPost = true
            }
        }
    }
    
    private var apiSearchSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Theme.oliveSoft.opacity(0.4))
                        .frame(width: 40, height: 40)
                    Image(systemName: "magnifyingglass")
                        .font(.title3)
                        .foregroundStyle(Theme.olive)
                }
                Text("Discover Recipes")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)
            }
            
            HStack(spacing: 12) {
                TextField("Search TheMealDB...", text: $searchQuery)
                    .textInputAutocapitalization(.never)
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Theme.card)
                            .shadow(color: .black.opacity(0.04), radius: 8, y: 4)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(
                                searchQuery.isEmpty ? Theme.border : Theme.olive.opacity(0.3),
                                lineWidth: searchQuery.isEmpty ? 1 : 2
                            )
                    )
                
                searchButton
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Theme.card)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Theme.border, Theme.border.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
    
    private var searchButton: some View {
        Button {
            HapticManager.shared.medium()
            Task {
                isSearching = true
                await apiService.searchRecipes(query: searchQuery)
                isSearching = false
                if !apiService.searchResults.isEmpty {
                    showAPISearch = true
                }
            }
        } label: {
            if isSearching {
                ProgressView()
                    .tint(.white)
            } else {
                Image(systemName: "magnifyingglass")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 56, height: 56)
        .background(
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Theme.olive, Theme.oliveDark],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Theme.olive.opacity(0.3), radius: 8, y: 4)
        )
        .disabled(searchQuery.isEmpty || isSearching)
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Theme.oliveSoft.opacity(0.4))
                        .frame(width: 40, height: 40)
                    Image(systemName: "sparkles")
                        .font(.title3)
                        .foregroundStyle(Theme.olive)
                }
                Text("Quick Actions")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)
            }
            Text("Share your favorite recipes with the community or discover new ones from TheMealDB. All your data is synced to the cloud!")
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Theme.subtext)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Theme.card)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Theme.border, Theme.border.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Hero Card
private struct HeroCard: View {
    var title: String
    var subtitle: String
    var icon: String
    var gradient: [Color] = [Theme.olive, Theme.oliveDark]
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                ZStack {
                    let gradientColors = gradient.map { $0.opacity(0.2) }
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: gradient[0].opacity(0.3), radius: 12, y: 6)
                    Image(systemName: icon)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.text)
                    Text(subtitle)
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Theme.subtext)
                }

                Spacer()
                
                ZStack {
                    Circle()
                        .fill(Theme.oliveSoft.opacity(0.3))
                        .frame(width: 40, height: 40)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Theme.olive)
                }
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(Theme.card)
                    .shadow(color: .black.opacity(0.1), radius: 16, y: 8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        LinearGradient(
                            colors: [Theme.border, Theme.border.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Add Post Wrapper
private struct AddSocialPostViewWrapper: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var feedStore: SocialFeedStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AddSocialPostView { post in
            Task {
                var updatedPost = post
                updatedPost.recipe.assignAuthor(email: session.currentUser?.email, name: session.currentUser?.name)
                updatedPost.recipe.user_id = session.currentUser?.id
                await feedStore.append(updatedPost)
            }
        } onDismiss: {
            dismiss()
        }
        .environmentObject(store)
        .environmentObject(session)
        .environmentObject(feedStore)
    }
}
