import Foundation

struct MealResponse: Codable {
    let meals: [Meal]?
}

struct MealDetailResponse: Codable {
    let meals: [MealDetail]?
}

struct Meal: Codable, Identifiable {
    let idMeal: String
    let strMeal: String
    let strCategory: String?
    let strInstructions: String?
    let strMealThumb: String?

    var id: String { idMeal }
}

// Full meal details with all ingredients
struct MealDetail: Codable, Identifiable {
    let idMeal: String
    let strMeal: String
    let strCategory: String?
    let strArea: String?
    let strInstructions: String?
    let strMealThumb: String?
    let strIngredient1: String?
    let strIngredient2: String?
    let strIngredient3: String?
    let strIngredient4: String?
    let strIngredient5: String?
    let strIngredient6: String?
    let strIngredient7: String?
    let strIngredient8: String?
    let strIngredient9: String?
    let strIngredient10: String?
    let strIngredient11: String?
    let strIngredient12: String?
    let strIngredient13: String?
    let strIngredient14: String?
    let strIngredient15: String?
    let strIngredient16: String?
    let strIngredient17: String?
    let strIngredient18: String?
    let strIngredient19: String?
    let strIngredient20: String?
    let strMeasure1: String?
    let strMeasure2: String?
    let strMeasure3: String?
    let strMeasure4: String?
    let strMeasure5: String?
    let strMeasure6: String?
    let strMeasure7: String?
    let strMeasure8: String?
    let strMeasure9: String?
    let strMeasure10: String?
    let strMeasure11: String?
    let strMeasure12: String?
    let strMeasure13: String?
    let strMeasure14: String?
    let strMeasure15: String?
    let strMeasure16: String?
    let strMeasure17: String?
    let strMeasure18: String?
    let strMeasure19: String?
    let strMeasure20: String?
    
    var id: String { idMeal }
    
    // Extract all ingredients as array
    var ingredients: [(name: String, measure: String)] {
        var result: [(name: String, measure: String)] = []
        let ingredients = [
            strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5,
            strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10,
            strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15,
            strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20
        ]
        let measures = [
            strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5,
            strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10,
            strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15,
            strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
        ]
        
        for (index, ingredient) in ingredients.enumerated() {
            if let ing = ingredient, !ing.trimmingCharacters(in: .whitespaces).isEmpty {
                let measure = measures[index]?.trimmingCharacters(in: .whitespaces) ?? ""
                result.append((name: ing, measure: measure))
            }
        }
        return result
    }
}

@MainActor
final class RecipeAPIService: ObservableObject {
    @Published var searchResults: [Meal] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Cache for meal details
    private var mealDetailsCache: [String: MealDetail] = [:]

    func searchRecipes(query: String) async {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?s=\(encoded)") else {
            isLoading = false
            errorMessage = "Invalid search query"
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                throw NSError(domain: "APIError", code: httpResponse.statusCode)
            }
            
            let decoded = try JSONDecoder().decode(MealResponse.self, from: data)
            self.searchResults = decoded.meals ?? []
            
            if searchResults.isEmpty {
                errorMessage = "No recipes found. Try a different search term."
            }
        } catch {
            print("❌ [RecipeAPIService] API fetch failed:", error.localizedDescription)
            errorMessage = "Failed to search recipes. Please check your connection."
            searchResults = []
        }
        
        isLoading = false
    }
    
    func fetchMealDetails(mealId: String) async throws -> MealDetail {
        // Check cache first
        if let cached = mealDetailsCache[mealId] {
            return cached
        }
        
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/lookup.php?i=\(mealId)") else {
            throw NSError(domain: "APIError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoded = try JSONDecoder().decode(MealDetailResponse.self, from: data)
        
        guard let meal = decoded.meals?.first else {
            throw NSError(domain: "APIError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Meal not found"])
        }
        
        mealDetailsCache[mealId] = meal
        return meal
    }
}
