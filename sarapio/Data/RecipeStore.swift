// sarapio/Data/RecipeStore.swift
import Foundation

@MainActor
final class RecipeStore: ObservableObject {
    @Published var recipes: [Recipe] = SampleData.recipes

    init() {}

    // MARK: - Local mutations (UI calls these)

    func add(_ recipe: Recipe, regenerateIdentity: Bool = false) {
        var draft = recipe
        if regenerateIdentity { draft.regenerateIdentity() }
        recipes.insert(draft, at: 0)
    }

    func delete(_ recipe: Recipe) {
        recipes.removeAll { $0.id == recipe.id }
    }

    func toggleFavorite(_ recipe: Recipe) {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        recipes[index].isFavorite.toggle()
    }

    func update(_ recipe: Recipe, with updated: Recipe) {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        recipes[index] = updated
    }

    func recipes(for user: AppUser?) -> [Recipe] {
        guard let user else { return recipes }
        return recipes.filter { $0.authorEmail == user.email }
    }
}
