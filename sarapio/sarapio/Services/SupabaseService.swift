import Foundation

final class SupabaseService {
    static let shared = SupabaseService()
    
    private let baseURL: String
    private let anonKey: String
    
    private init() {
        // Supabase configuration
        self.baseURL = "https://tmrdvhhvcfimjvjkzytv.supabase.co"
        self.anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtcmR2aGh2Y2ZpbWp2amt6eXR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2NDQ2NDYsImV4cCI6MjA3NzIyMDY0Nn0.Lw_4oN4XlXlN4ZiV5n-T11J0julBccCdJPHm533b2yo"
    }
    
    // MARK: - Users
    
    func fetchUser(email: String) async throws -> AppUser? {
        guard let url = URL(string: "\(baseURL)/rest/v1/users?email=eq.\(email)&select=*") else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let users = try JSONDecoder().decode([SupabaseUser].self, from: data)
        return users.first?.toAppUser()
    }
    
    func saveUser(_ user: AppUser) async throws {
        let supabaseUser = SupabaseUser(from: user)
        let jsonData = try JSONEncoder().encode(supabaseUser)
        
        var urlString = "\(baseURL)/rest/v1/users"
        var method = "POST"
        
        // Check if user exists
        if let existing = try? await fetchUser(email: user.email) {
            urlString += "?id=eq.\(existing.id.uuidString)"
            method = "PATCH"
        }
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = jsonData
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("prefer", forHTTPHeaderField: "return=representation")
        
        _ = try await URLSession.shared.data(for: request)
    }
    
    // MARK: - Recipes
    
    func fetchRecipes(userId: UUID? = nil) async throws -> [Recipe] {
        // First, fetch all recipes
        var urlString = "\(baseURL)/rest/v1/recipes?select=*"
        if let userId = userId {
            urlString += "&user_id=eq.\(userId.uuidString)"
        }
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        var recipes = try JSONDecoder().decode([SupabaseRecipe].self, from: data)
        
        // Fetch ingredients and steps for each recipe
        for i in 0..<recipes.count {
            guard let recipeId = recipes[i].id else { continue }
            
            // Fetch ingredients
            if let ingredients = try? await fetchIngredients(for: recipeId) {
                recipes[i].ingredientsFromTable = ingredients
            }
            
            // Fetch steps
            if let steps = try? await fetchSteps(for: recipeId) {
                recipes[i].stepsFromTable = steps
            }
        }
        
        return recipes.map { $0.toRecipe() }
    }
    
    private func fetchIngredients(for recipeId: UUID) async throws -> [SupabaseIngredient] {
        guard let url = URL(string: "\(baseURL)/rest/v1/ingredients?recipe_id=eq.\(recipeId.uuidString)&select=*&order=name") else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([SupabaseIngredient].self, from: data)
    }
    
    private func fetchSteps(for recipeId: UUID) async throws -> [SupabaseStep] {
        guard let url = URL(string: "\(baseURL)/rest/v1/steps?recipe_id=eq.\(recipeId.uuidString)&select=*&order=order_num") else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode([SupabaseStep].self, from: data)
    }
    
    func saveRecipe(_ recipe: Recipe, userId: UUID?) async throws {
        let supabaseRecipe = SupabaseRecipe(from: recipe, userId: userId)
        let jsonData = try JSONEncoder().encode(supabaseRecipe)
        
        var urlString = "\(baseURL)/rest/v1/recipes"
        var method = "POST"
        var recipeId: UUID = recipe.id
        
        // If recipe has ID, update instead of insert
        if let existingId = try? await getRecipeId(recipeId: recipe.id) {
            urlString += "?id=eq.\(existingId)"
            method = "PATCH"
            recipeId = existingId
        }
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = jsonData
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("prefer", forHTTPHeaderField: "return=representation")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let savedRecipes = try JSONDecoder().decode([SupabaseRecipe].self, from: data)
        guard let savedRecipe = savedRecipes.first, let savedId = savedRecipe.id else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to save recipe"])
        }
        
        // Save ingredients to ingredients table
        try await saveIngredients(recipe.ingredients, for: savedId)
        
        // Save steps to steps table
        try await saveSteps(recipe.steps, for: savedId)
    }
    
    private func saveIngredients(_ ingredients: [Ingredient], for recipeId: UUID) async throws {
        // Delete existing ingredients for this recipe
        guard let deleteUrl = URL(string: "\(baseURL)/rest/v1/ingredients?recipe_id=eq.\(recipeId.uuidString)") else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var deleteRequest = URLRequest(url: deleteUrl)
        deleteRequest.httpMethod = "DELETE"
        deleteRequest.setValue(anonKey, forHTTPHeaderField: "apikey")
        deleteRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        _ = try? await URLSession.shared.data(for: deleteRequest)
        
        // Insert new ingredients
        guard let insertUrl = URL(string: "\(baseURL)/rest/v1/ingredients") else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let supabaseIngredients = ingredients.map { SupabaseIngredient(from: $0, recipeId: recipeId) }
        let jsonData = try JSONEncoder().encode(supabaseIngredients)
        
        var insertRequest = URLRequest(url: insertUrl)
        insertRequest.httpMethod = "POST"
        insertRequest.httpBody = jsonData
        insertRequest.setValue(anonKey, forHTTPHeaderField: "apikey")
        insertRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        insertRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        insertRequest.setValue("prefer", forHTTPHeaderField: "return=representation")
        
        _ = try await URLSession.shared.data(for: insertRequest)
    }
    
    private func saveSteps(_ steps: [StepItem], for recipeId: UUID) async throws {
        // Delete existing steps for this recipe
        guard let deleteUrl = URL(string: "\(baseURL)/rest/v1/steps?recipe_id=eq.\(recipeId.uuidString)") else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var deleteRequest = URLRequest(url: deleteUrl)
        deleteRequest.httpMethod = "DELETE"
        deleteRequest.setValue(anonKey, forHTTPHeaderField: "apikey")
        deleteRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        _ = try? await URLSession.shared.data(for: deleteRequest)
        
        // Insert new steps
        guard let insertUrl = URL(string: "\(baseURL)/rest/v1/steps") else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        let supabaseSteps = steps.map { SupabaseStep(from: $0, recipeId: recipeId) }
        let jsonData = try JSONEncoder().encode(supabaseSteps)
        
        var insertRequest = URLRequest(url: insertUrl)
        insertRequest.httpMethod = "POST"
        insertRequest.httpBody = jsonData
        insertRequest.setValue(anonKey, forHTTPHeaderField: "apikey")
        insertRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        insertRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        insertRequest.setValue("prefer", forHTTPHeaderField: "return=representation")
        
        _ = try await URLSession.shared.data(for: insertRequest)
    }
    
    func deleteRecipe(_ recipe: Recipe) async throws {
        // Delete ingredients first (should cascade, but being explicit)
        if let ingredientsUrl = URL(string: "\(baseURL)/rest/v1/ingredients?recipe_id=eq.\(recipe.id.uuidString)") {
            var ingredientsRequest = URLRequest(url: ingredientsUrl)
            ingredientsRequest.httpMethod = "DELETE"
            ingredientsRequest.setValue(anonKey, forHTTPHeaderField: "apikey")
            ingredientsRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            _ = try? await URLSession.shared.data(for: ingredientsRequest)
        }
        
        // Delete steps first (should cascade, but being explicit)
        if let stepsUrl = URL(string: "\(baseURL)/rest/v1/steps?recipe_id=eq.\(recipe.id.uuidString)") {
            var stepsRequest = URLRequest(url: stepsUrl)
            stepsRequest.httpMethod = "DELETE"
            stepsRequest.setValue(anonKey, forHTTPHeaderField: "apikey")
            stepsRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            _ = try? await URLSession.shared.data(for: stepsRequest)
        }
        
        // Delete recipe
        guard let url = URL(string: "\(baseURL)/rest/v1/recipes?id=eq.\(recipe.id.uuidString)") else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        _ = try await URLSession.shared.data(for: request)
    }
    
    private func getRecipeId(recipeId: UUID) async throws -> UUID? {
        guard let url = URL(string: "\(baseURL)/rest/v1/recipes?id=eq.\(recipeId.uuidString)&select=id") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue(anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let results = try JSONDecoder().decode([[String: String]].self, from: data)
        return results.first?["id"].flatMap { UUID(uuidString: $0) }
    }
}

// MARK: - Supabase Models

private struct SupabaseRecipe: Codable {
    let id: UUID?
    let userId: UUID?
    let title: String
    let minutes: Int?
    let servings: Int?
    let cuisine: String?
    let region: String?
    let ingredients: [[String: String]]? // Legacy JSONB field (for backward compatibility)
    let steps: [[String: AnyCodable]]? // Legacy JSONB field (for backward compatibility)
    let isFavorite: Bool?
    let photoUrl: String?
    let createdAt: String?
    
    // New fields for separate tables
    var ingredientsFromTable: [SupabaseIngredient]?
    var stepsFromTable: [SupabaseStep]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case minutes
        case servings
        case cuisine
        case region
        case ingredients
        case steps
        case isFavorite = "is_favorite"
        case photoUrl = "photo_url"
        case createdAt = "created_at"
    }
    
    init(from recipe: Recipe, userId: UUID?) {
        self.id = recipe.id
        self.userId = userId
        self.title = recipe.title
        self.minutes = recipe.minutes
        self.servings = recipe.servings
        self.cuisine = recipe.cuisine
        self.region = recipe.region
        self.ingredients = recipe.ingredients.map { [
            "name": $0.name,
            "amount": $0.amount ?? "",
            "unit": $0.unit ?? "",
            "category": $0.category.rawValue
        ] }
        self.steps = recipe.steps.map { step in
            var dict: [String: AnyCodable] = [
                "order": AnyCodable(step.order),
                "text": AnyCodable(step.text)
            ]
            if let timer = step.timerMinutes {
                dict["timerMinutes"] = AnyCodable(timer)
            }
            if let tip = step.tip {
                dict["tip"] = AnyCodable(tip)
            }
            return dict
        }
        self.isFavorite = recipe.isFavorite
        self.photoUrl = recipe.imageUrl ?? recipe.imageName
        self.createdAt = nil
    }
    
    func toRecipe() -> Recipe {
        var recipe = Recipe(
            title: title,
            minutes: minutes ?? 0,
            servings: servings ?? 1,
            cuisine: cuisine,
            region: region
        )
        
        if let id = id {
            recipe.id = id
        }
        
        recipe.isFavorite = isFavorite ?? false
        recipe.imageUrl = photoUrl
        recipe.imageName = photoUrl // Keep for backward compatibility
        
        // Parse ingredients - prioritize separate table, fallback to JSONB
        if let ingredientsFromTable = ingredientsFromTable, !ingredientsFromTable.isEmpty {
            recipe.ingredients = ingredientsFromTable.map { $0.toIngredient() }
        } else if let ingredientsData = ingredients {
            // Legacy JSONB parsing
            recipe.ingredients = ingredientsData.compactMap { dict -> Ingredient? in
                guard let name = dict["name"] else { return nil }
                let amountStr = dict["amount"] ?? ""
                let unitStr = dict["unit"] ?? ""
                let categoryStr = dict["category"] ?? "produce"
                let category = Ingredient.IngredientCategory(rawValue: categoryStr) ?? .produce
                return Ingredient(name, amount: amountStr, unit: unitStr, category: category)
            }
        }
        
        // Parse steps - prioritize separate table, fallback to JSONB
        if let stepsFromTable = stepsFromTable, !stepsFromTable.isEmpty {
            recipe.steps = stepsFromTable.sorted { $0.orderNum < $1.orderNum }.map { $0.toStepItem() }
        } else if let stepsData = steps {
            // Legacy JSONB parsing
            recipe.steps = stepsData.compactMap { dict -> StepItem? in
                guard let order = dict["order"]?.intValue,
                      let text = dict["text"]?.stringValue else { return nil }
                let timerMinutes = dict["timerMinutes"]?.intValue
                let tip = dict["tip"]?.stringValue
                return StepItem(order, text, timerMinutes: timerMinutes, tip: tip?.isEmpty == false ? tip : nil)
            }
        }
        
        if let createdAtStr = createdAt {
            let formatter = ISO8601DateFormatter()
            recipe.createdAt = formatter.date(from: createdAtStr) ?? Date()
        }
        
        return recipe
    }
}

private struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            value = int
        } else if let string = try? container.decode(String.self) {
            value = string
        } else {
            value = ""
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let int = value as? Int {
            try container.encode(int)
        } else if let string = value as? String {
            try container.encode(string)
        }
    }
    
    var intValue: Int? {
        value as? Int
    }
    
    var stringValue: String? {
        value as? String
    }
}

// MARK: - Supabase User Model

private struct SupabaseUser: Codable {
    let id: UUID?
    let email: String
    let name: String?
    let avatarSeed: String?
    let avatarUrl: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case avatarSeed = "avatar_seed"
        case avatarUrl = "avatar_url"
        case createdAt = "created_at"
    }
    
    init(from user: AppUser) {
        self.id = user.id
        self.email = user.email
        self.name = user.name
        self.avatarSeed = user.avatarSeed
        self.avatarUrl = user.avatarUrl
        self.createdAt = nil
    }
    
    func toAppUser() -> AppUser {
        var user = AppUser(
            id: id ?? UUID(),
            name: name ?? "User",
            email: email,
            avatarSeed: avatarSeed ?? "person.fill",
            avatarUrl: avatarUrl,
            followers: 0,
            following: 0
        )
        return user
    }
}

// MARK: - Supabase Ingredient Model

private struct SupabaseIngredient: Codable {
    let id: UUID?
    let recipeId: UUID
    let name: String
    let quantity: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case name
        case quantity
    }
    
    init(from ingredient: Ingredient, recipeId: UUID) {
        self.id = nil // Will be generated by database
        self.recipeId = recipeId
        self.name = ingredient.name
        // Combine amount and unit into quantity
        if !ingredient.amount.isEmpty && !ingredient.unit.isEmpty {
            self.quantity = "\(ingredient.amount) \(ingredient.unit)"
        } else if !ingredient.amount.isEmpty {
            self.quantity = ingredient.amount
        } else {
            self.quantity = ""
        }
    }
    
    func toIngredient() -> Ingredient {
        // Parse quantity back to amount and unit
        let parts = quantity.split(separator: " ", maxSplits: 1)
        let amount = parts.first.map(String.init) ?? ""
        let unit = parts.count > 1 ? String(parts[1]) : ""
        return Ingredient(name, amount: amount, unit: unit)
    }
}

// MARK: - Supabase Step Model

private struct SupabaseStep: Codable {
    let id: UUID?
    let recipeId: UUID
    let orderNum: Int
    let instruction: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case orderNum = "order_num"
        case instruction
    }
    
    init(from step: StepItem, recipeId: UUID) {
        self.id = nil // Will be generated by database
        self.recipeId = recipeId
        self.orderNum = step.order
        self.instruction = step.text
    }
    
    func toStepItem() -> StepItem {
        return StepItem(orderNum, instruction)
    }
}

