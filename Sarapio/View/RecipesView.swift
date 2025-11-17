import SwiftUI

struct RecipesView: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var bottomBar: BottomBarState

    @State private var searchText = ""
    @State private var filterUnder30 = false
    @State private var filterVeggie = false
    @State private var filterFavorites = false
    @State private var filterLucena = false
    @State private var filterFilipino = false
    @State private var showFilters = true
    @State private var showError = false
    @State private var errorMessage = ""

    private var filtered: [Recipe] {
        store.recipes.filter { r in
            let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            let hitsText = q.isEmpty ||
                r.title.localizedCaseInsensitiveContains(q) ||
                (r.cuisine ?? "").localizedCaseInsensitiveContains(q) ||
                (r.region ?? "").localizedCaseInsensitiveContains(q) ||
                r.ingredients.contains { $0.name.localizedCaseInsensitiveContains(q) }

            let meats = ["beef", "pork", "chicken", "shrimp", "fish", "tuna", "salmon", "lamb"]
            let isVeggie = !r.ingredients.map { $0.name.lowercased() }
                .contains { s in meats.contains { s.contains($0) } }

            let hitsUnder = !filterUnder30 || r.minutes <= 30
            let hitsVeg   = !filterVeggie || isVeggie
            let hitsFav   = !filterFavorites || r.isFavorite
            let hitsLuc   = !filterLucena || (r.region?.localizedCaseInsensitiveContains("Lucena") ?? false)
            let hitsFil   = !filterFilipino || (r.cuisine?.localizedCaseInsensitiveContains("Filipino") ?? false)

            return hitsText && hitsUnder && hitsVeg && hitsFav && hitsLuc && hitsFil
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: proxy.frame(in: .global).minY
                        )
                }
                .frame(height: 0)

                VStack(alignment: .leading, spacing: 16) {
                    header
                    searchBar
                    filterSection
                    
                    if store.isLoading && store.recipes.isEmpty {
                        LoadingSkeleton()
                    } else if let error = store.errorMessage, store.recipes.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Theme.olive)
                            Text("Connection Error")
                                .font(.headline)
                                .foregroundStyle(Theme.text)
                            Text(error)
                                .font(.subheadline)
                                .foregroundStyle(Theme.subtext)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            Button {
                                Task {
                                    await store.loadRecipes()
                                }
                            } label: {
                                Text("Retry")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Theme.olive)
                                    .cornerRadius(12)
                            }
                            .padding(.top, 8)
                        }
                        .padding(.vertical, 60)
                    } else {
                        recipeList
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 100) // Extra padding for bottom bar
                .safeAreaPadding(.top) // ✅ ensures spacing under nav bar
            }
            .background(Theme.bg)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { bottomBar.handleScroll(offset: $0) }
            .onAppear {
                bottomBar.reset()
                Task {
                    await store.loadRecipes()
                }
            }
            .refreshable {
                await store.loadRecipes()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .onChange(of: store.errorMessage) { oldValue, newValue in
                if let error = newValue {
                    HapticManager.shared.error()
                    errorMessage = error
                    showError = true
                }
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Discover Recipes")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.text)
                    Text("\(store.recipes.count) recipes available")
                        .font(.subheadline)
                        .foregroundStyle(Theme.subtext)
                }
                Spacer()
            }
            
            NavigationLink {
                AddRecipeView()
                    .environmentObject(store)
                    .environmentObject(session)
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("Add Recipe")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Theme.olive, Theme.oliveDark],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Theme.olive.opacity(0.4), radius: 12, y: 6)
                )
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Theme.oliveSoft.opacity(0.3))
                    .frame(width: 36, height: 36)
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.olive)
            }
            
            TextField("Search recipes, ingredients, or cuisine...", text: $searchText)
                .textInputAutocapitalization(.never)
                .font(.system(size: 16, weight: .regular, design: .rounded))
                .onChange(of: searchText) { oldValue, newValue in
                    if !newValue.isEmpty {
                        HapticManager.shared.light()
                    }
                }
            
            if !searchText.isEmpty {
                Button {
                    HapticManager.shared.light()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        searchText = ""
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.subtext)
                }
            }
        }
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
                    searchText.isEmpty ? Theme.border : Theme.olive.opacity(0.3),
                    lineWidth: searchText.isEmpty ? 1 : 2
                )
        )
    }

    // MARK: - Filters
    private var filterSection: some View {
        VStack(spacing: 14) {
            HStack {
                Button {
                    HapticManager.shared.light()
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showFilters.toggle()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 14, weight: .semibold))
                        Text(showFilters ? "Hide Filters" : "Show Filters")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(showFilters ? Theme.olive : Theme.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(showFilters ? Theme.oliveSoft : Theme.card)
                            .overlay(
                                Capsule()
                                    .stroke(showFilters ? Theme.olive.opacity(0.3) : Theme.border, lineWidth: 1.5)
                            )
                    )
                }

                Spacer()

                if filterUnder30 || filterVeggie || filterFavorites || filterLucena || filterFilipino {
                    Button {
                        HapticManager.shared.light()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            filterUnder30 = false
                            filterVeggie = false
                            filterFavorites = false
                            filterLucena = false
                            filterFilipino = false
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                            Text("Clear All")
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                        .foregroundStyle(Theme.olive)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Theme.oliveSoft.opacity(0.3))
                        )
                    }
                }
            }

            if showFilters {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterChip("Under 30m", isOn: $filterUnder30)
                        FilterChip("Veggie", isOn: $filterVeggie)
                        FilterChip("Favorites", isOn: $filterFavorites)
                        FilterChip("Lucena", isOn: $filterLucena)
                        FilterChip("Filipino", isOn: $filterFilipino)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 4)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Recipe List
    private var recipeList: some View {
        VStack(spacing: 14) {
            if filtered.isEmpty {
                if store.recipes.isEmpty {
                    EmptyStateView(
                        icon: "book.closed",
                        "No Recipes Yet",
                        message: "Start your culinary journey by adding your first recipe!",
                        actionTitle: "Add Recipe",
                        action: {
                            // Action handled by NavigationLink in header
                        }
                    )
                } else {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        "No Results",
                        message: "Try adjusting your filters or search terms to find recipes.",
                        actionTitle: "Clear Filters",
                        action: {
                            filterUnder30 = false
                            filterVeggie = false
                            filterFavorites = false
                            filterLucena = false
                            filterFilipino = false
                            searchText = ""
                            HapticManager.shared.light()
                        }
                    )
                }
            } else {
                ForEach(filtered) { r in
                    NavigationLink {
                        RecipeDetailView(recipe: r)
                            .environmentObject(store)
                            .environmentObject(session)
                    } label: {
                        RecipeRow(recipe: r)
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .contextMenu {
                        Button(role: .destructive) {
                            HapticManager.shared.medium()
                            Task { await store.delete(r) }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button {
                            HapticManager.shared.selection()
                            Task { await store.toggleFavorite(r) }
                        } label: {
                            Label(r.isFavorite ? "Unfavorite" : "Favorite", systemImage: r.isFavorite ? "heart.slash" : "heart")
                        }
                    }
                }
            }
        }
    }
}
