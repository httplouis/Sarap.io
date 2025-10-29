import SwiftUI

struct RecipesView: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var bottomBar: BottomBarState

    @State private var searchText = ""
    @State private var filterUnder30 = false
    @State private var filterVeggie = false
    @State private var filterFavorites = false
    @State private var filterLucena = false
    @State private var filterFilipino = false
    @State private var showFilters = true

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
                    recipeList
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .safeAreaPadding(.top) // ✅ ensures spacing under nav bar
            }
            .background(Theme.bg)
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { bottomBar.handleScroll(offset: $0) }
            .onAppear { bottomBar.reset() }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    // MARK: - Header
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            Text("Sarap.io")
                .font(Theme.titleXL())
                .foregroundStyle(Theme.text)
            Spacer()
            NavigationLink { AddRecipeView() } label: {
                Text("Add a recipe")
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Theme.olive))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.1), radius: 6, y: 3)
            }
        }
        .padding(.top, 4)
    }

    // MARK: - Search Bar
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(Theme.subtext)
            TextField("Search recipes or ingredients", text: $searchText)
                .textInputAutocapitalization(.never)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
    }

    // MARK: - Filters
    private var filterSection: some View {
        VStack(spacing: 10) {
            HStack {
                Button {
                    withAnimation(.easeInOut) { showFilters.toggle() }
                } label: {
                    Label(showFilters ? "Hide Filters" : "Show Filters", systemImage: "slider.horizontal.3")
                        .font(.footnote)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Theme.oliveSoft.opacity(0.5)))
                }

                Spacer()

                Button {
                    filterUnder30 = false
                    filterVeggie = false
                    filterFavorites = false
                    filterLucena = false
                    filterFilipino = false
                } label: {
                    Text("Clear Filters")
                        .font(.footnote)
                        .foregroundStyle(Theme.olive)
                }
            }

            if showFilters {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        Chip("Under 30m", isOn: $filterUnder30)
                        Chip("Veggie", isOn: $filterVeggie)
                        Chip("Favorites", isOn: $filterFavorites)
                        Chip("Lucena", isOn: $filterLucena)
                        Chip("Filipino", isOn: $filterFilipino)
                    }
                    .padding(.vertical, 2)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    // MARK: - Recipe List
    private var recipeList: some View {
        VStack(spacing: 14) {
            ForEach(filtered) { r in
                NavigationLink { RecipeDetailView(recipe: r) } label: {
                    RecipeRow(recipe: r)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button(role: .destructive) { store.delete(r) } label: {
                        Label("Delete", systemImage: "trash")
                    }
                    Button { store.toggleFavorite(r) } label: {
                        Label(
                            r.isFavorite ? "Unfavorite" : "Favorite",
                            systemImage: r.isFavorite ? "heart.slash" : "heart"
                        )
                    }
                }
            }
        }
    }
}
