import Foundation

final class RecipeStore: ObservableObject {
    @Published var recipes: [Recipe] = SampleData.recipes

    func add(_ recipe: Recipe) {
        recipes.insert(recipe, at: 0)
    }
    func delete(_ recipe: Recipe) {
        recipes.removeAll { $0.id == recipe.id }
    }
    func toggleFavorite(_ recipe: Recipe) {
        guard let i = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        recipes[i].isFavorite.toggle()
    }
    func update(_ recipe: Recipe, with updated: Recipe) {
            guard let idx = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
            recipes[idx] = updated
        }

}
