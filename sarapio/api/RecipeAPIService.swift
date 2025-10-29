import Foundation

struct MealResponse: Codable {
    let meals: [Meal]?
}

struct Meal: Codable, Identifiable {
    let idMeal: String
    let strMeal: String
    let strCategory: String?
    let strInstructions: String?
    let strMealThumb: String?

    var id: String { idMeal }
}

@MainActor
final class RecipeAPIService: ObservableObject {
    @Published var searchResults: [Meal] = []

    func searchRecipes(query: String) async {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.themealdb.com/api/json/v1/1/search.php?s=\(encoded)") else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(MealResponse.self, from: data)
            self.searchResults = decoded.meals ?? []
        } catch {
            print("❌ API fetch failed:", error.localizedDescription)
        }
    }
}
