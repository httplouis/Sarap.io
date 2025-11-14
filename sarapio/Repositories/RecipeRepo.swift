import Foundation
import Supabase

@MainActor
final class RecipeRepo: ObservableObject {
    private let client = SupabaseClientManager.shared
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchAll() async {
        isLoading = true
        errorMessage = nil
        do {
            let response: [RecipeRecord] = try await client
                .database
                .from("recipes")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value

            // Convert RecipeRecord to Recipe
            var decodedRecipes: [Recipe] = []
            for record in response {
                if let recipe = try? convertRecordToRecipe(record) {
                    decodedRecipes.append(recipe)
                }
            }
            
            self.recipes = decodedRecipes
        } catch {
            print("❌ Fetch failed:", error.localizedDescription)
            errorMessage = error.localizedDescription
            // Fallback to empty array
            self.recipes = []
        }
        isLoading = false
    }
    
    private func convertRecordToRecipe(_ record: RecipeRecord) throws -> Recipe {
        // Convert ingredients from JSONB
        var ingredients: [Ingredient] = []
        if let ingredientsArray = record.ingredients {
            for ingDict in ingredientsArray {
                let name = ingDict["name"] ?? ""
                let quantity = ingDict["quantity"] ?? ""
                let parts = quantity.split(separator: " ", maxSplits: 1)
                if parts.count == 2 {
                    ingredients.append(Ingredient(name, amount: String(parts[0]), unit: String(parts[1])))
                } else if parts.count == 1, !parts[0].isEmpty {
                    ingredients.append(Ingredient(name, amount: String(parts[0]), unit: ""))
                } else {
                    ingredients.append(Ingredient(name))
                }
            }
        }
        
        // Convert steps from JSONB
        var steps: [StepItem] = []
        if let stepsArray = record.steps {
            for (index, stepDict) in stepsArray.enumerated() {
                let instruction = stepDict["instruction"] as? String ?? stepDict["text"] as? String ?? ""
                let order = stepDict["order_num"] as? Int ?? stepDict["order"] as? Int ?? (index + 1)
                steps.append(StepItem(order, instruction))
            }
        }
        
        return Recipe(
            id: record.id,
            title: record.title,
            minutes: record.minutes ?? 0,
            servings: record.servings ?? 1,
            cuisine: record.cuisine,
            region: record.region,
            ingredients: ingredients,
            steps: steps,
            isFavorite: record.is_favorite ?? false,
            user_id: record.user_id,
            photo_url: record.photo_url
        )
    }
    
    private func decodeRecipe(from json: [String: Any]) throws -> Recipe {
        let id = UUID(uuidString: json["id"] as? String ?? "") ?? UUID()
        let title = json["title"] as? String ?? "Untitled"
        let minutes = json["minutes"] as? Int ?? 0
        let servings = json["servings"] as? Int ?? 0
        let cuisine = json["cuisine"] as? String
        let region = json["region"] as? String
        let isFavorite = json["is_favorite"] as? Bool ?? false
        let photo_url = json["photo_url"] as? String
        let user_id = (json["user_id"] as? String).flatMap { UUID(uuidString: $0) }
        
        // Parse created_at
        var created_at: Date? = nil
        if let dateString = json["created_at"] as? String {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            created_at = formatter.date(from: dateString) ?? ISO8601DateFormatter().date(from: dateString)
        }
        
        // Decode ingredients from JSONB
        var ingredients: [Ingredient] = []
        if let ingredientsArray = json["ingredients"] as? [[String: Any]] {
            for ingDict in ingredientsArray {
                let name = ingDict["name"] as? String ?? ""
                let quantity = ingDict["quantity"] as? String ?? ""
                // Try to parse quantity into amount and unit
                let parts = quantity.split(separator: " ", maxSplits: 1)
                if parts.count == 2 {
                    ingredients.append(Ingredient(name, amount: String(parts[0]), unit: String(parts[1])))
                } else if parts.count == 1, !parts[0].isEmpty {
                    ingredients.append(Ingredient(name, amount: String(parts[0]), unit: ""))
                } else {
                    ingredients.append(Ingredient(name))
                }
            }
        } else if let ingredientsData = json["ingredients"] as? Data,
                  let ingredientsArray = try? JSONDecoder().decode([Ingredient].self, from: ingredientsData) {
            ingredients = ingredientsArray
        }
        
        // Decode steps from JSONB
        var steps: [StepItem] = []
        if let stepsArray = json["steps"] as? [[String: Any]] {
            for (index, stepDict) in stepsArray.enumerated() {
                let instruction = stepDict["instruction"] as? String ?? stepDict["text"] as? String ?? ""
                let order = stepDict["order_num"] as? Int ?? stepDict["order"] as? Int ?? (index + 1)
                steps.append(StepItem(order, instruction))
            }
        } else if let stepsData = json["steps"] as? Data,
                  let stepsArray = try? JSONDecoder().decode([StepItem].self, from: stepsData) {
            steps = stepsArray
        }
        
        return Recipe(
            id: id,
            title: title,
            minutes: minutes,
            servings: servings,
            cuisine: cuisine,
            region: region,
            ingredients: ingredients,
            steps: steps,
            isFavorite: isFavorite,
            user_id: user_id,
            photo_url: photo_url,
            created_at: created_at
        )
    }

    func add(_ recipe: Recipe) async throws -> Recipe {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            // Prepare recipe dict for Supabase
            var recipeDict: [String: Any] = [
                "title": recipe.title,
                "minutes": recipe.minutes,
                "servings": recipe.servings,
                "is_favorite": recipe.isFavorite
            ]
            
            if let cuisine = recipe.cuisine {
                recipeDict["cuisine"] = cuisine
            }
            if let region = recipe.region {
                recipeDict["region"] = region
            }
            if let user_id = recipe.user_id {
                recipeDict["user_id"] = user_id.uuidString
            }
            if let photo_url = recipe.photo_url {
                recipeDict["photo_url"] = photo_url
            }
            
            // Encode ingredients as JSONB array
            let ingredientsArray = recipe.ingredients.map { ing -> [String: String] in
                var dict: [String: String] = ["name": ing.name]
                if !ing.amount.isEmpty {
                    dict["quantity"] = ing.unit.isEmpty ? ing.amount : "\(ing.amount) \(ing.unit)"
                }
                return dict
            }
            recipeDict["ingredients"] = ingredientsArray
            
            // Encode steps as JSONB array
            let stepsArray = recipe.steps.map { step -> [String: Any] in
                ["order_num": step.order, "instruction": step.text]
            }
            recipeDict["steps"] = stepsArray
            
            let response: RecipeRecord = try await client
                .database
                .from("recipes")
                .insert([recipeDict])
                .select()
                .single()
                .execute()
                .value
            
            let createdRecipe = try convertRecordToRecipe(response)
            await fetchAll()
            return createdRecipe
        } catch {
            print("❌ Insert failed:", error.localizedDescription)
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    func update(_ recipe: Recipe) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            var recipeDict: [String: Any] = [
                "title": recipe.title,
                "minutes": recipe.minutes,
                "servings": recipe.servings,
                "is_favorite": recipe.isFavorite
            ]
            
            if let cuisine = recipe.cuisine {
                recipeDict["cuisine"] = cuisine
            }
            if let region = recipe.region {
                recipeDict["region"] = region
            }
            if let photo_url = recipe.photo_url {
                recipeDict["photo_url"] = photo_url
            }
            
            // Encode ingredients and steps
            let ingredientsArray = recipe.ingredients.map { ing -> [String: Any] in
                var dict: [String: Any] = ["name": ing.name]
                if !ing.amount.isEmpty {
                    dict["quantity"] = ing.unit.isEmpty ? ing.amount : "\(ing.amount) \(ing.unit)"
                }
                return dict
            }
            recipeDict["ingredients"] = ingredientsArray
            
            let stepsArray = recipe.steps.map { step -> [String: Any] in
                ["order_num": step.order, "instruction": step.text]
            }
            recipeDict["steps"] = stepsArray
            
            _ = try await client
                .database
                .from("recipes")
                .update(recipeDict)
                .eq("id", value: recipe.id.uuidString)
                .execute()
            
            await fetchAll()
        } catch {
            print("❌ Update failed:", error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ id: UUID) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
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
            errorMessage = error.localizedDescription
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
    
    // MARK: - Image Upload
    
    func uploadImage(_ imageData: Data, recipeId: UUID) async throws -> String {
        let fileName = "\(recipeId.uuidString).jpg"
        let file = File(name: fileName, data: imageData, fileName: fileName, contentType: "image/jpeg")
        
        let response = try await client.storage
            .from("recipe-photos")
            .upload(path: fileName, file: file, options: FileOptions(cacheControl: "3600"))
        
        // Get public URL
        let url = try client.storage
            .from("recipe-photos")
            .getPublicURL(path: fileName)
        
        return url.absoluteString
    }
}
