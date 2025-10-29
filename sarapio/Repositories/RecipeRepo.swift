import Foundation
import Supabase

@MainActor
final class RecipeRepo: ObservableObject {
    private let client = SupabaseClientManager.shared
    @Published var recipes: [Recipe] = []

    func fetchAll() async {
        do {
            let response = try await client
                .database
                .from("recipes")
                .select()
                .order("created_at", ascending: false)
                .execute()

            if let fetched = response.value as? [Recipe] {
                await MainActor.run { self.recipes = fetched }
            } else {
                print("⚠️ Could not decode [Recipe]")
            }
        } catch {
            print("❌ Fetch failed:", error.localizedDescription)
        }
    }

    func add(_ recipe: Recipe) async {
        do {
            _ = try await client
                .database
                .from("recipes")
                .insert([recipe])
                .execute()
            await fetchAll()
        } catch {
            print("❌ Insert failed:", error.localizedDescription)
        }
    }

    func delete(_ id: UUID) async {
        do {
            _ = try await client
                .database
                .from("recipes")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
            await MainActor.run {
                self.recipes.removeAll { $0.id == id }
            }
        } catch {
            print("❌ Delete failed:", error.localizedDescription)
        }
    }

    func toggleFavorite(_ recipe: Recipe) async {
        do {
            _ = try await client
                .database
                .from("recipes")
                .update(["is_favorite": !recipe.isFavorite])
                .eq("id", value: recipe.id.uuidString)
                .execute()
            await fetchAll()
        } catch {
            print("❌ Toggle failed:", error.localizedDescription)
        }
    }
}
