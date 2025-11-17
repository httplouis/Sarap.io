import SwiftUI

struct APISearchResultsView: View {
    @ObservedObject var apiService: RecipeAPIService
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if apiService.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Theme.olive)
                        Text("Searching recipes...")
                            .font(.headline)
                            .foregroundStyle(Theme.subtext)
                    }
                    .padding(.vertical, 60)
                } else if let errorMessage = apiService.errorMessage, !errorMessage.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.olive)
                        Text("Search Error")
                            .font(.headline)
                            .foregroundStyle(Theme.text)
                        Text(errorMessage)
                            .font(.subheadline)
                            .foregroundStyle(Theme.subtext)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .padding(.vertical, 60)
                } else if apiService.searchResults.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundStyle(Theme.subtext)
                        Text("No recipes found")
                            .font(.headline)
                            .foregroundStyle(Theme.subtext)
                        Text("Try a different search term")
                            .font(.footnote)
                            .foregroundStyle(Theme.subtext)
                    }
                    .padding(.vertical, 60)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(apiService.searchResults) { meal in
                            APIMealCard(
                                meal: meal,
                                isAdding: addingRecipeId == meal.idMeal,
                                onAdd: {
                                    convertAndAdd(meal: meal)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
            .background(Theme.bg)
            .navigationTitle("Search Results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .alert("Recipe Added!", isPresented: $showSuccessAlert) {
                Button("OK") { }
            } message: {
                Text("The recipe has been successfully added to your collection.")
            }
            .alert("Error", isPresented: $showErrorAlert) {
                Button("OK") { }
            } message: {
                Text(errorAlertMessage)
            }
        }
    }
    
    @State private var isAddingRecipe = false
    @State private var addingRecipeId: String?
    @State private var showSuccessAlert = false
    @State private var showErrorAlert = false
    @State private var errorAlertMessage = ""
    
    private func convertAndAdd(meal: Meal) {
        guard !isAddingRecipe else { return }
        
        isAddingRecipe = true
        addingRecipeId = meal.idMeal
        
        Task {
            do {
                // Fetch full meal details to get ingredients
                let mealDetail = try await apiService.fetchMealDetails(mealId: meal.idMeal)
                
                // Convert ingredients
                var ingredients: [Ingredient] = []
                for (name, measure) in mealDetail.ingredients {
                    // Parse measure to extract amount and unit
                    let trimmedMeasure = measure.trimmingCharacters(in: .whitespaces)
                    let (amount, unit) = parseMeasure(trimmedMeasure)
                    
                    ingredients.append(Ingredient(
                        name,
                        amount: amount,
                        unit: unit
                    ))
                }
                
                // Parse instructions into steps
                var steps: [StepItem] = []
                if let instructions = mealDetail.strInstructions {
                    // Try to split by numbered steps or newlines
                    let stepTexts = instructions
                        .components(separatedBy: "\n")
                        .map { $0.trimmingCharacters(in: .whitespaces) }
                        .filter { !$0.isEmpty }
                    
                    // If no clear steps, try to split by periods or numbered format
                    if stepTexts.count == 1 {
                        // Try to split by numbered format (1., 2., etc.) or periods
                        let singleStep = stepTexts[0]
                        
                        // Try regex pattern for numbered steps
                        if let regex = try? NSRegularExpression(pattern: #"\d+[\.\)]\s*"#, options: []),
                           regex.numberOfMatches(in: singleStep, options: [], range: NSRange(singleStep.startIndex..., in: singleStep)) > 1 {
                            // Split by numbered pattern
                            let parts = regex.stringByReplacingMatches(
                                in: singleStep,
                                options: [],
                                range: NSRange(singleStep.startIndex..., in: singleStep),
                                withTemplate: "|||"
                            )
                            let numberedSteps = parts.components(separatedBy: "|||")
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                                .filter { !$0.isEmpty }
                            
                            if numberedSteps.count > 1 {
                                steps = numberedSteps.enumerated().map { StepItem($0.offset + 1, $0.element) }
                            } else {
                                // Split by periods
                                let periodSteps = singleStep.components(separatedBy: ". ")
                                    .map { $0.trimmingCharacters(in: .whitespaces) }
                                    .filter { !$0.isEmpty }
                                steps = periodSteps.enumerated().map { StepItem($0.offset + 1, $0.element) }
                            }
                        } else {
                            // Split by periods
                            let periodSteps = singleStep.components(separatedBy: ". ")
                                .map { $0.trimmingCharacters(in: .whitespaces) }
                                .filter { !$0.isEmpty }
                            steps = periodSteps.enumerated().map { StepItem($0.offset + 1, $0.element) }
                        }
                    } else {
                        steps = stepTexts.enumerated().map { StepItem($0.offset + 1, $0.element) }
                    }
                }
                
                // Estimate cooking time (rough estimate: 30 min base + 5 min per step)
                let estimatedMinutes = max(30, 30 + (steps.count * 5))
                
                // Create recipe
                var recipe = Recipe(
                    title: mealDetail.strMeal ?? "Untitled",
                    minutes: estimatedMinutes,
                    servings: 4, // Default
                    cuisine: mealDetail.strCategory,
                    region: mealDetail.strArea,
                    tags: [],
                    ingredients: ingredients,
                    steps: steps,
                    isFavorite: false,
                    user_id: nil,
                    authorEmail: nil,
                    authorName: nil,
                    photo_url: mealDetail.strMealThumb,
                    imageData: nil,
                    assetName: nil,
                    imageName: nil,
                    created_at: nil
                )
                
                recipe.assignAuthor(email: session.currentUser?.email, name: session.currentUser?.name)
                recipe.user_id = session.currentUser?.id
                
                // Add to database
                await store.add(recipe, regenerateIdentity: true)
                
                await MainActor.run {
                    isAddingRecipe = false
                    addingRecipeId = nil
                    showSuccessAlert = true
                    HapticManager.shared.success()
                }
                
                // Auto-dismiss after 1 second
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                await MainActor.run {
                    dismiss()
                }
            } catch {
                print("❌ [APISearchResultsView] Failed to add recipe:", error)
                await MainActor.run {
                    isAddingRecipe = false
                    addingRecipeId = nil
                    errorAlertMessage = "Failed to import recipe: \(error.localizedDescription)"
                    showErrorAlert = true
                    HapticManager.shared.error()
                }
            }
        }
    }
    
    // Helper to parse measure string (e.g., "1 cup", "2 tbsp", "500g")
    private func parseMeasure(_ measure: String) -> (amount: String, unit: String) {
        let trimmed = measure.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            return ("", "")
        }
        
        // Try to extract number and unit
        let pattern = #"^([\d/\.\s]+)\s*(.*)$"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: trimmed, options: [], range: NSRange(trimmed.startIndex..., in: trimmed)) {
            let amountRange = Range(match.range(at: 1), in: trimmed)!
            let unitRange = Range(match.range(at: 2), in: trimmed)!
            let amount = String(trimmed[amountRange]).trimmingCharacters(in: .whitespaces)
            let unit = String(trimmed[unitRange]).trimmingCharacters(in: .whitespaces)
            return (amount, unit)
        }
        
        // If no clear pattern, return as amount
        return (trimmed, "")
    }
}

private struct APIMealCard: View {
    let meal: Meal
    let isAdding: Bool
    let onAdd: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Image
            AsyncImage(url: URL(string: meal.strMealThumb ?? "")) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Theme.card
                        ProgressView()
                            .tint(Theme.olive)
                    }
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    ZStack {
                        Theme.card
                        Image(systemName: "photo")
                            .foregroundStyle(Theme.subtext)
                    }
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            VStack(alignment: .leading, spacing: 8) {
                Text(meal.strMeal ?? "Untitled")
                    .font(.headline)
                    .foregroundStyle(Theme.text)
                    .lineLimit(2)
                
                if let category = meal.strCategory {
                    HStack(spacing: 4) {
                        Image(systemName: "tag.fill")
                            .font(.caption2)
                            .foregroundStyle(Theme.olive)
                        Text(category)
                            .font(.caption)
                            .foregroundStyle(Theme.subtext)
                    }
                }
                
                Button {
                    HapticManager.shared.medium()
                    onAdd()
                } label: {
                    HStack(spacing: 6) {
                        if isAdding {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                            Text("Adding...")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        } else {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Recipe")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                isAdding
                                    ? AnyShapeStyle(Theme.olive.opacity(0.6))
                                    : AnyShapeStyle(
                                        LinearGradient(
                                            colors: [Theme.olive, Theme.oliveDark],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                    )
                }
                .disabled(isAdding)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.card)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    isAdding
                        ? Theme.olive.opacity(0.5)
                        : Theme.border,
                    lineWidth: isAdding ? 2 : 1
                )
        )
        .opacity(isAdding ? 0.7 : 1.0)
    }
}

