// RecipesView.swift
import SwiftUI

struct RecipesView: View {
    @EnvironmentObject private var store: RecipeStore

    @State private var searchText = ""
    @State private var filterUnder30 = false
    @State private var filterVeggie = false
    @State private var filterFavorites = false
    @State private var filterLucena = false
    @State private var filterFilipino = false

    private var filtered: [Recipe] {
        store.recipes.filter { r in
            let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

            let hitsText = q.isEmpty ||
                r.title.localizedCaseInsensitiveContains(q) ||
                (r.cuisine ?? "").localizedCaseInsensitiveContains(q) ||
                (r.region ?? "").localizedCaseInsensitiveContains(q) ||
                r.ingredients.contains { $0.name.localizedCaseInsensitiveContains(q) }

            let meats = ["beef","pork","chicken","shrimp","fish","tuna","salmon","lamb"]
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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // Header
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
                .padding(.top, 8)

                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundStyle(Theme.subtext)
                    TextField("Search recipes or ingredients", text: $searchText)
                        .textInputAutocapitalization(.never)
                }
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))

                // Filters
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

                // Recipe cards
                VStack(spacing: 14) {
                    ForEach(filtered) { r in
                        NavigationLink { RecipeDetailView(recipe: r) } label: {
                            RecipeRow(recipe: r).contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button(role: .destructive) { store.delete(r) } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            Button { store.toggleFavorite(r) } label: {
                                Label(r.isFavorite ? "Unfavorite" : "Favorite",
                                      systemImage: r.isFavorite ? "heart.slash" : "heart")
                            }
                        }
                    }
                }
                .padding(.bottom, 24)
            }
            .padding(.horizontal, 20)
        }
        .background(Theme.bg)
    }
}
