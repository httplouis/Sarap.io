import Foundation

enum SampleData {
    static let recipes: [Recipe] = {
        var r1 = Recipe(title: "Garlic Butter Shrimp", minutes: 20, servings: 3, cuisine: "Seafood", region: "Lucena")
        r1.assetName = "shrimp" // <-- your asset
        r1.tags = ["Under 30m", "Quick", "One-Pan"]
        r1.ingredients = [
            Ingredient("Shrimp", qty: "500 g"),
            Ingredient("Garlic", qty: "5 cloves"),
            Ingredient("Butter", qty: "3 tbsp"),
            Ingredient("Olive oil", qty: "1 tbsp"),
            Ingredient("Lemon", qty: "1/2"),
            Ingredient("Parsley", qty: "1 tbsp"),
            Ingredient("Salt"), Ingredient("Black pepper")
        ]
        r1.steps = [
            StepItem(1, "Melt butter with oil; sauté garlic until fragrant."),
            StepItem(2, "Add shrimp; cook until pink."),
            StepItem(3, "Season, squeeze lemon, toss parsley; serve.")
        ]

        var r2 = Recipe(title: "Chicken Adobo (One-Pan)", minutes: 45, servings: 4, cuisine: "Filipino", region: "Quezon")
        r2.assetName = "chicken-adobo" // <-- your asset
        r2.tags = ["Dinner", "One-Pan"]
        r2.ingredients = [
            Ingredient("Chicken thighs", qty: "800 g"),
            Ingredient("Soy sauce", qty: "1/2 cup"),
            Ingredient("Vinegar", qty: "1/3 cup"),
            Ingredient("Water", qty: "1/2 cup"),
            Ingredient("Garlic", qty: "6 cloves"),
            Ingredient("Bay leaves", qty: "3 pcs"),
            Ingredient("Peppercorns", qty: "1 tsp"),
            Ingredient("Brown sugar", qty: "1 tbsp"),
            Ingredient("Onion", qty: "1 pc"),
            Ingredient("Oil", qty: "1 tbsp")
        ]
        r2.steps = [
            StepItem(1, "Sauté onion & garlic in oil."),
            StepItem(2, "Add chicken; sear both sides."),
            StepItem(3, "Pour soy, vinegar, water; add bay & peppercorns; simmer 25–30m."),
            StepItem(4, "Stir in sugar; reduce to glossy sauce."),
            StepItem(5, "Rest 5m; serve with rice.")
        ]

        var r3 = Recipe(title: "Veggie Stir-Fry", minutes: 25, servings: 2, cuisine: "Asian", region: "Lucena")
        r3.assetName = "veggie" // <-- your asset
        r3.tags = ["Under 30m", "Veggie", "One-Pan"]
        r3.ingredients = [
            Ingredient("Broccoli", qty: "1 head"),
            Ingredient("Carrot", qty: "1 pc"),
            Ingredient("Bell pepper", qty: "1 pc"),
            Ingredient("Mushrooms", qty: "150 g"),
            Ingredient("Garlic", qty: "3 cloves"),
            Ingredient("Soy sauce", qty: "2 tbsp"),
            Ingredient("Oyster sauce", qty: "1 tbsp"),
            Ingredient("Cornstarch", qty: "1 tsp (slurry)"),
            Ingredient("Oil", qty: "1 tbsp")
        ]
        r3.steps = [
            StepItem(1, "Stir-fry vegetables on high heat (5–6m)."),
            StepItem(2, "Add garlic; toss (30s)."),
            StepItem(3, "Add sauces + slurry; thicken (1–2m).")
        ]

        return [r1, r2, r3]
    }()
}
