import Foundation

enum SampleData {
    static let recipes: [Recipe] = {
        var r1 = Recipe(title: "Garlic Butter Shrimp", minutes: 20, servings: 3, cuisine: "Seafood", region: "Lucena")
        r1.imageName = "shrimp"
        r1.tags = ["Under 30m", "Quick", "One-Pan"]
        r1.ingredients = [
            Ingredient("Shrimp", amount: "500", unit: "g"),
            Ingredient("Garlic", amount: "5", unit: "cloves"),
            Ingredient("Butter", amount: "3", unit: "tbsp"),
            Ingredient("Olive oil", amount: "1", unit: "tbsp"),
            Ingredient("Lemon", amount: "1/2", unit: ""),
            Ingredient("Parsley", amount: "1", unit: "tbsp"),
            Ingredient("Salt"),
            Ingredient("Black pepper")
        ]
        r1.steps = [
            StepItem(1, "Melt butter with oil; sauté garlic until fragrant."),
            StepItem(2, "Add shrimp; cook until pink."),
            StepItem(3, "Season, squeeze lemon, toss parsley; serve.")
        ]

        var r2 = Recipe(title: "Chicken Adobo (One-Pan)", minutes: 45, servings: 4, cuisine: "Filipino", region: "Quezon")
        r2.imageName = "chicken-adobo"
        r2.tags = ["Dinner", "One-Pan"]
        r2.ingredients = [
            Ingredient("Chicken thighs", amount: "800", unit: "g"),
            Ingredient("Soy sauce", amount: "1/2", unit: "cup"),
            Ingredient("Vinegar", amount: "1/3", unit: "cup"),
            Ingredient("Water", amount: "1/2", unit: "cup"),
            Ingredient("Garlic", amount: "6", unit: "cloves"),
            Ingredient("Bay leaves", amount: "3", unit: "pcs"),
            Ingredient("Peppercorns", amount: "1", unit: "tsp"),
            Ingredient("Brown sugar", amount: "1", unit: "tbsp"),
            Ingredient("Onion", amount: "1", unit: "pc"),
            Ingredient("Oil", amount: "1", unit: "tbsp")
        ]
        r2.steps = [
            StepItem(1, "Sauté onion & garlic in oil."),
            StepItem(2, "Add chicken; sear both sides."),
            StepItem(3, "Pour soy, vinegar, water; add bay & peppercorns; simmer 25–30m."),
            StepItem(4, "Stir in sugar; reduce to glossy sauce."),
            StepItem(5, "Rest 5m; serve with rice.")
        ]

        var r3 = Recipe(title: "Veggie Stir-Fry", minutes: 25, servings: 2, cuisine: "Asian", region: "Lucena")
        r3.imageName = "veggie"
        r3.tags = ["Under 30m", "Veggie", "One-Pan"]
        r3.ingredients = [
            Ingredient("Broccoli", amount: "1", unit: "head"),
            Ingredient("Carrot", amount: "1", unit: "pc"),
            Ingredient("Bell pepper", amount: "1", unit: "pc"),
            Ingredient("Mushrooms", amount: "150", unit: "g"),
            Ingredient("Garlic", amount: "3", unit: "cloves"),
            Ingredient("Soy sauce", amount: "2", unit: "tbsp"),
            Ingredient("Oyster sauce", amount: "1", unit: "tbsp"),
            Ingredient("Cornstarch", amount: "1", unit: "tsp (slurry)"),
            Ingredient("Oil", amount: "1", unit: "tbsp")
        ]
        r3.steps = [
            StepItem(1, "Stir-fry vegetables on high heat (5–6m)."),
            StepItem(2, "Add garlic; toss (30s)."),
            StepItem(3, "Add sauces + slurry; thicken (1–2m).")
        ]

        return [r1, r2, r3]
    }()
}
