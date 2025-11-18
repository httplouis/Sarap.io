import Foundation

@MainActor
final class RecipeStore: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseService.shared
    private let recipesKey = "sarapio.savedRecipes" // Fallback cache
    
    init() {
        Task {
            await loadRecipes()
        }
    }
    
    func loadRecipes(userId: UUID? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetched = try await supabase.fetchRecipes(userId: userId)
            recipes = fetched
            
            // Cache to UserDefaults as backup
            if let encoded = try? JSONEncoder().encode(recipes) {
                UserDefaults.standard.set(encoded, forKey: recipesKey)
            }
        } catch {
            errorMessage = error.localizedDescription
            // Fallback to cached recipes
            loadCachedRecipes()
        }
        
        isLoading = false
    }
    
    private func loadCachedRecipes() {
        guard let data = UserDefaults.standard.data(forKey: recipesKey),
              let decoded = try? JSONDecoder().decode([Recipe].self, from: data) else {
            // If no cache, use sample data
            recipes = SampleData.recipes
            return
        }
        recipes = decoded
    }

    func add(_ recipe: Recipe, regenerateIdentity: Bool = false, userId: UUID? = nil) async {
        var draft = recipe
        if regenerateIdentity { draft.regenerateIdentity() }
        draft.updatedAt = Date()
        
        do {
            try await supabase.saveRecipe(draft, userId: userId)
            recipes.insert(draft, at: 0)
            saveCache()
        } catch {
            errorMessage = "Failed to save recipe: \(error.localizedDescription)"
            // Still add locally for offline support
            recipes.insert(draft, at: 0)
            saveCache()
        }
    }

    func delete(_ recipe: Recipe) async {
        do {
            try await supabase.deleteRecipe(recipe)
            recipes.removeAll { $0.id == recipe.id }
            saveCache()
        } catch {
            errorMessage = "Failed to delete recipe: \(error.localizedDescription)"
            // Still delete locally
            recipes.removeAll { $0.id == recipe.id }
            saveCache()
        }
    }

    func toggleFavorite(_ recipe: Recipe, userId: UUID? = nil) async {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        recipes[index].isFavorite.toggle()
        recipes[index].updatedAt = Date()
        
        do {
            try await supabase.saveRecipe(recipes[index], userId: userId)
            saveCache()
        } catch {
            // Revert on error
            recipes[index].isFavorite.toggle()
            errorMessage = "Failed to update favorite: \(error.localizedDescription)"
        }
    }

    func update(_ recipe: Recipe, with updated: Recipe, userId: UUID? = nil) async {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        var updatedRecipe = updated
        updatedRecipe.updatedAt = Date()
        
        do {
            try await supabase.saveRecipe(updatedRecipe, userId: userId)
            recipes[index] = updatedRecipe
            saveCache()
        } catch {
            errorMessage = "Failed to update recipe: \(error.localizedDescription)"
        }
    }
    
    func incrementViewCount(for recipe: Recipe, userId: UUID? = nil) {
        guard let index = recipes.firstIndex(where: { $0.id == recipe.id }) else { return }
        recipes[index].incrementViewCount()
        saveCache()
        
        // Update in database asynchronously
        Task {
            try? await supabase.saveRecipe(recipes[index], userId: userId)
        }
    }

    func recipes(for user: AppUser?) -> [Recipe] {
        guard let user else { return recipes }
        return recipes.filter { $0.authorEmail == user.email }
    }
    
    func search(query: String) -> [Recipe] {
        guard !query.isEmpty else { return recipes }
        let lowerQuery = query.lowercased()
        return recipes.filter { recipe in
            recipe.title.localizedCaseInsensitiveContains(lowerQuery) ||
            (recipe.cuisine ?? "").localizedCaseInsensitiveContains(lowerQuery) ||
            (recipe.region ?? "").localizedCaseInsensitiveContains(lowerQuery) ||
            recipe.description.localizedCaseInsensitiveContains(lowerQuery) ||
            recipe.tags.contains { $0.localizedCaseInsensitiveContains(lowerQuery) } ||
            recipe.ingredients.contains { $0.name.localizedCaseInsensitiveContains(lowerQuery) }
        }
    }
    
    func filter(by difficulty: Recipe.Difficulty?) -> [Recipe] {
        guard let difficulty else { return recipes }
        return recipes.filter { $0.difficulty == difficulty }
    }
    
    func filter(by cuisine: String?) -> [Recipe] {
        guard let cuisine else { return recipes }
        return recipes.filter { ($0.cuisine ?? "").localizedCaseInsensitiveContains(cuisine) }
    }
    
    func filter(by tag: String) -> [Recipe] {
        return recipes.filter { $0.tags.contains { $0.localizedCaseInsensitiveContains(tag) } }
    }
    
    func getFavorites() -> [Recipe] {
        return recipes.filter { $0.isFavorite }
    }
    
    func getRecent(limit: Int = 10) -> [Recipe] {
        return Array(recipes.sorted { $0.updatedAt > $1.updatedAt }.prefix(limit))
    }
    
    func getPopular(limit: Int = 10) -> [Recipe] {
        return Array(recipes.sorted { $0.viewCount > $1.viewCount }.prefix(limit))
    }
    
    func getByCollection(_ collection: RecipeCollection) -> [Recipe] {
        switch collection {
        case .all:
            return recipes
        case .favorites:
            return getFavorites()
        case .recent:
            return getRecent(limit: 20)
        case .popular:
            return getPopular(limit: 20)
        case .cuisine(let name):
            return filter(by: name)
        case .difficulty(let level):
            return filter(by: level)
        case .tag(let tagName):
            return filter(by: tagName)
        }
    }
    
    func getAllCuisines() -> [String] {
        let cuisines = Set(recipes.compactMap { $0.cuisine })
        return Array(cuisines).sorted()
    }
    
    func getAllTags() -> [String] {
        let tags = Set(recipes.flatMap { $0.tags })
        return Array(tags).sorted()
    }
    
    private func saveCache() {
        if let encoded = try? JSONEncoder().encode(recipes) {
            UserDefaults.standard.set(encoded, forKey: recipesKey)
        }
    }
}
