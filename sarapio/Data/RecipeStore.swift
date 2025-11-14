// sarapio/Data/RecipeStore.swift
import Foundation

@MainActor
final class RecipeStore: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repo = RecipeRepo()
    
    init() {
        // Sync recipes from repo
        Task {
            await loadRecipes()
        }
    }
    
    // MARK: - Database Integration
    
    func loadRecipes() async {
        isLoading = true
        await repo.fetchAll()
        recipes = repo.recipes
        isLoading = false
    }

    // MARK: - Mutations (sync with database)

    func add(_ recipe: Recipe, regenerateIdentity: Bool = false) async {
        var draft = recipe
        if regenerateIdentity { draft.regenerateIdentity() }
        
        do {
            let created = try await repo.add(draft)
            await loadRecipes()
        } catch {
            errorMessage = error.localizedDescription
            print("❌ Failed to add recipe:", error)
        }
    }

    func delete(_ recipe: Recipe) async {
        await repo.delete(recipe.id)
        await loadRecipes()
    }

    func toggleFavorite(_ recipe: Recipe) async {
        await repo.toggleFavorite(recipe)
        await loadRecipes()
    }

    func update(_ recipe: Recipe, with updated: Recipe) async {
        var updatedRecipe = updated
        updatedRecipe.id = recipe.id
        await repo.update(updatedRecipe)
        await loadRecipes()
    }

    func recipes(for user: AppUser?) -> [Recipe] {
        guard let user else { return recipes }
        return recipes.filter { recipe in
            recipe.user_id == user.id || recipe.authorEmail == user.email
        }
    }
    
    // MARK: - Image Upload
    
    func uploadImage(_ imageData: Data, recipeId: UUID) async throws -> String {
        return try await repo.uploadImage(imageData, recipeId: recipeId)
    }
}
