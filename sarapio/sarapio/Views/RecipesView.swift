// RecipesView.swift
import SwiftUI

struct RecipesView: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var bottomBar: BottomBarState
    @StateObject private var searchHistory = SearchHistoryStore()
    
    @State private var searchText = ""
    @State private var selectedCollection: RecipeCollection = .all
    @State private var filterUnder30 = false
    @State private var filterVeggie = false
    @State private var filterFavorites = false
    @State private var filterLucena = false
    @State private var filterFilipino = false
    @State private var showFilters = true
    @State private var showSearchSuggestions = false
    @State private var isRefreshing = false
    @State private var isLoading = false

    private var filtered: [Recipe] {
        var recipes = store.getByCollection(selectedCollection)
        
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !q.isEmpty {
            recipes = recipes.filter { r in
                r.title.localizedCaseInsensitiveContains(q) ||
                (r.cuisine ?? "").localizedCaseInsensitiveContains(q) ||
                (r.region ?? "").localizedCaseInsensitiveContains(q) ||
                r.description.localizedCaseInsensitiveContains(q) ||
                r.tags.contains { $0.localizedCaseInsensitiveContains(q) } ||
                r.ingredients.contains { $0.name.localizedCaseInsensitiveContains(q) }
            }
        }
        
        let meats = ["beef","pork","chicken","shrimp","fish","tuna","salmon","lamb"]
        let isVeggie = { (r: Recipe) in
            !r.ingredients.map { $0.name.lowercased() }
                .contains { s in meats.contains { s.contains($0) } }
        }

        return recipes.filter { r in
            let hitsUnder = !filterUnder30 || r.totalTime <= 30
            let hitsVeg   = !filterVeggie || isVeggie(r)
            let hitsFav   = !filterFavorites || r.isFavorite
            let hitsLuc   = !filterLucena || (r.region?.localizedCaseInsensitiveContains("Lucena") ?? false)
            let hitsFil   = !filterFilipino || (r.cuisine?.localizedCaseInsensitiveContains("Filipino") ?? false)

            return hitsUnder && hitsVeg && hitsFav && hitsLuc && hitsFil
        }
    }
    
    private var searchSuggestions: [String] {
        if searchText.isEmpty {
            return searchHistory.recentSearches
        }
        return searchHistory.getSuggestions(for: searchText)
    }

    var body: some View {
        ScrollView {
            scrollOffsetTracker
            
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                collectionsBar
                searchSection
                filterSection
                recipeListSection
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
        .background(Theme.bg)
        .refreshable {
            await refreshRecipes()
        }
        .task {
            await store.loadRecipes(userId: nil)
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { bottomBar.handleScroll(offset: $0) }
        .onAppear { 
            bottomBar.reset()
            showSearchSuggestions = false
        }
        .onTapGesture {
            if showSearchSuggestions {
                showSearchSuggestions = false
            }
        }
        .navigationTitle("Recipes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    MessagesView()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.olive)
                }
            }
        }
    }
    
    private var scrollOffsetTracker: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .global).minY)
        }
        .frame(height: 0)
    }
    
    private var headerSection: some View {
        HStack(alignment: .center) {
            Spacer()
            NavigationLink { AddRecipeView() } label: {
                HStack(spacing: 6) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Add")
                        .font(.system(size: 15, weight: .semibold))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 14).fill(Theme.olive))
                .foregroundStyle(.white)
                .shadow(color: Theme.olive.opacity(0.3), radius: 8, y: 4)
            }
        }
        .padding(.top, 4)
    }
    
    private var searchSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Theme.subtext)
                TextField("Search recipes or ingredients", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .font(.system(size: 16))
                    .onChange(of: searchText) { _, newValue in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showSearchSuggestions = !newValue.isEmpty || !searchHistory.recentSearches.isEmpty
                        }
                    }
                    .onSubmit {
                        if !searchText.isEmpty {
                            searchHistory.addSearch(searchText)
                            showSearchSuggestions = false
                        }
                    }
                
                if !searchText.isEmpty {
                    Button {
                        withAnimation {
                            searchText = ""
                            showSearchSuggestions = false
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Theme.subtext.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border.opacity(0.5), lineWidth: 1))
            .shadow(color: .black.opacity(0.03), radius: 4, y: 2)
            
            if showSearchSuggestions && !searchSuggestions.isEmpty {
                searchSuggestionsView
            }
        }
    }
    
    private var searchSuggestionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !searchText.isEmpty {
                Text("Suggestions")
                    .font(.caption)
                    .foregroundStyle(Theme.subtext)
                    .padding(.horizontal, 4)
            } else {
                HStack {
                    Text("Recent Searches")
                        .font(.caption)
                        .foregroundStyle(Theme.subtext)
                    Spacer()
                    Button("Clear") {
                        searchHistory.clearHistory()
                    }
                    .font(.caption2)
                    .foregroundStyle(Theme.olive)
                }
                .padding(.horizontal, 4)
            }
            
            ForEach(searchSuggestions.prefix(5), id: \.self) { suggestion in
                Button {
                    searchText = suggestion
                    searchHistory.addSearch(suggestion)
                    showSearchSuggestions = false
                } label: {
                    HStack {
                        Image(systemName: searchText.isEmpty ? "clock.fill" : "magnifyingglass")
                            .font(.caption)
                            .foregroundStyle(Theme.subtext)
                        Text(suggestion)
                            .font(.subheadline)
                            .foregroundStyle(Theme.text)
                        Spacer()
                        if !searchText.isEmpty {
                            Button {
                                searchHistory.removeSearch(suggestion)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Theme.subtext.opacity(0.5))
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Theme.card))
                }
            }
        }
        .padding(.top, 8)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            HStack {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        showFilters.toggle()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: showFilters ? "chevron.down" : "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Filters")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Theme.olive)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Theme.oliveSoft.opacity(0.3)))
                }

                Spacer()

                if filterUnder30 || filterVeggie || filterFavorites || filterLucena || filterFilipino {
                    Button {
                        withAnimation {
                            filterUnder30 = false
                            filterVeggie = false
                            filterFavorites = false
                            filterLucena = false
                            filterFilipino = false
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 12))
                            Text("Clear")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(Theme.olive)
                    }
                }
            }

            if showFilters {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterChip(title: "Under 30m", isOn: $filterUnder30, icon: "clock.fill")
                        FilterChip(title: "Veggie", isOn: $filterVeggie, icon: "leaf.fill")
                        FilterChip(title: "Favorites", isOn: $filterFavorites, icon: "heart.fill")
                        FilterChip(title: "Lucena", isOn: $filterLucena, icon: "mappin.circle.fill")
                        FilterChip(title: "Filipino", isOn: $filterFilipino, icon: "flag.fill")
                    }
                    .padding(.vertical, 4)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    @ViewBuilder
    private var recipeListSection: some View {
        if isLoading {
            VStack(spacing: 14) {
                ForEach(0..<3, id: \.self) { _ in
                    RecipeRowSkeleton()
                }
            }
            .padding(.bottom, 24)
        } else if filtered.isEmpty {
            emptyStateView
        } else {
            LazyVStack(spacing: 16) {
                ForEach(filtered) { r in
                    NavigationLink { RecipeDetailView(recipe: r) } label: {
                        RecipeRow(recipe: r).contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(role: .destructive) { 
                            Task {
                                await store.delete(r)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        Button { 
                            Task {
                                await store.toggleFavorite(r, userId: session.currentUser?.id)
                            }
                        } label: {
                            Label(r.isFavorite ? "Unfavorite" : "Favorite",
                                  systemImage: r.isFavorite ? "heart.slash" : "heart")
                        }
                    }
                }
            }
            .padding(.bottom, 24)
        }
    }
    
    private var collectionsBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                CollectionChip(
                    collection: .all,
                    isSelected: selectedCollection.id == RecipeCollection.all.id,
                    count: store.recipes.count
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedCollection = .all
                    }
                }
                
                CollectionChip(
                    collection: .favorites,
                    isSelected: selectedCollection.id == RecipeCollection.favorites.id,
                    count: store.getFavorites().count
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedCollection = .favorites
                    }
                }
                
                CollectionChip(
                    collection: .recent,
                    isSelected: selectedCollection.id == RecipeCollection.recent.id,
                    count: store.getRecent().count
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedCollection = .recent
                    }
                }
                
                CollectionChip(
                    collection: .popular,
                    isSelected: selectedCollection.id == RecipeCollection.popular.id,
                    count: store.getPopular().count
                ) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedCollection = .popular
                    }
                }
                
                ForEach(store.getAllCuisines().prefix(3), id: \.self) { cuisine in
                    CollectionChip(
                        collection: .cuisine(cuisine),
                        isSelected: selectedCollection.id == RecipeCollection.cuisine(cuisine).id,
                        count: store.filter(by: cuisine).count
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedCollection = .cuisine(cuisine)
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 64))
                .foregroundStyle(Theme.subtext.opacity(0.5))
            Text("No recipes found")
                .font(.headline)
                .foregroundStyle(Theme.text)
            Text("Try adjusting your filters or search terms")
                .font(.footnote)
                .foregroundStyle(Theme.subtext)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                searchText = ""
                filterUnder30 = false
                filterVeggie = false
                filterFavorites = false
                filterLucena = false
                filterFilipino = false
                selectedCollection = .all
            } label: {
                Text("Clear All Filters")
                    .font(.subheadline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Theme.olive))
                    .foregroundStyle(.white)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private func refreshRecipes() async {
        await store.loadRecipes(userId: nil)
        isRefreshing = true
        try? await Task.sleep(nanoseconds: 500_000_000) // Simulate refresh
        isRefreshing = false
    }
}

private struct CollectionChip: View {
    let collection: RecipeCollection
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: collection.icon)
                    .font(.system(size: 12, weight: .medium))
                Text(collection.title)
                    .font(.system(size: 14, weight: isSelected ? .semibold : .medium))
                if count > 0 {
                    Text("(\(count))")
                        .font(.system(size: 12, weight: .medium))
                        .opacity(0.8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(isSelected ? Theme.olive : Theme.oliveSoft.opacity(0.4))
            )
            .foregroundStyle(isSelected ? .white : Theme.olive)
            .shadow(color: isSelected ? Theme.olive.opacity(0.3) : .clear, radius: 4, y: 2)
        }
    }
}

private struct FilterChip: View {
    let title: String
    @Binding var isOn: Bool
    let icon: String
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isOn.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .medium))
                Text(title)
                    .font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(
                Capsule()
                    .fill(isOn ? Theme.olive : Theme.oliveSoft.opacity(0.3))
            )
            .foregroundStyle(isOn ? .white : Theme.olive)
            .overlay(
                Capsule()
                    .stroke(isOn ? Color.clear : Theme.olive.opacity(0.3), lineWidth: 1)
            )
        }
    }
}
