import Foundation

final class RecipeStore: ObservableObject {
    @Published var recipes: [Recipe] = SampleData.recipes

    func add(_ recipe: Recipe, ownerId: UUID? = nil) {
        var newRecipe = recipe
        if let ownerId { newRecipe.ownerId = ownerId }
        recipes.insert(newRecipe, at: 0)
    }

    func delete(_ recipe: Recipe) {
        recipes.removeAll { $0.id == recipe.id }
    }

    func toggleFavorite(_ recipe: Recipe) {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        recipes[index].isFavorite.toggle()
    }

    func update(_ recipe: Recipe, with updated: Recipe) {
        guard let idx = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        var revised = updated
        revised.id = recipe.id
        revised.ownerId = updated.ownerId ?? recipe.ownerId
        recipes[idx] = revised
    }

    func copyFromFeed(_ recipe: Recipe, ownerId: UUID?) {
        let duplicated = recipe.duplicated(for: ownerId)
        add(duplicated)
    }
}
