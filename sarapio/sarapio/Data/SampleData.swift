import Foundation

enum SampleData {
    static let recipes: [Recipe] = {
        var r1 = Recipe(title: "Garlic Butter Shrimp", minutes: 20, servings: 3, cuisine: "Seafood", region: "Lucena")
        r1.imageUrl = "https://images.unsplash.com/photo-1559847844-5315695dadae?w=800&q=80"
        r1.imageName = "shrimp"
        r1.difficulty = .easy
        r1.description = "Quick and flavorful shrimp dish perfect for weeknight dinners. The garlic butter sauce is absolutely irresistible!"
        r1.prepTime = 5
        r1.cookTime = 15
        r1.calories = 280
        r1.protein = 28.5
        r1.carbs = 3.2
        r1.fat = 18.0
        r1.tags = ["Under 30m", "Quick", "One-Pan", "Seafood"]
        r1.tips = [
            "Don't overcook the shrimp - they're done when they turn pink and curl",
            "Use fresh garlic for the best flavor",
            "Serve immediately while hot for the best texture"
        ]
        r1.ingredients = [
            Ingredient("Shrimp", amount: "500", unit: "g", category: .meat),
            Ingredient("Garlic", amount: "5", unit: "cloves", category: .produce),
            Ingredient("Butter", amount: "3", unit: "tbsp", category: .dairy),
            Ingredient("Olive oil", amount: "1", unit: "tbsp", category: .pantry),
            Ingredient("Lemon", amount: "1/2", unit: "", category: .produce),
            Ingredient("Parsley", amount: "1", unit: "tbsp", category: .spices),
            Ingredient("Salt", category: .spices),
            Ingredient("Black pepper", category: .spices)
        ]
        r1.steps = [
            StepItem(1, "Melt butter with oil; sauté garlic until fragrant.", tip: "Medium heat to avoid burning garlic"),
            StepItem(2, "Add shrimp; cook until pink.", timerMinutes: 3, tip: "Cook 2-3 minutes per side"),
            StepItem(3, "Season, squeeze lemon, toss parsley; serve.", tip: "Remove from heat immediately when done")
        ]
        r1.authorEmail = "community@sarap.io"
        r1.authorName = "Community"
        r1.createdAt = Date().addingTimeInterval(-86400 * 5) // 5 days ago

        var r2 = Recipe(title: "Chicken Adobo (One-Pan)", minutes: 45, servings: 4, cuisine: "Filipino", region: "Quezon")
        r2.imageUrl = "https://www.seriouseats.com/thmb/uc8nb040OwgXekR9obuhEqm8WoI=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/__opt__aboutcom__coeus__resources__content_migration__serious_eats__seriouseats.com__2019__10__20191023-chicken-adobo-vicky-wasik-19-12ce105a2e1a44dfb1e2673775118064.jpg"
        r2.imageName = "chicken-adobo" // Fallback
        r2.difficulty = .medium
        r2.description = "Classic Filipino adobo - tangy, savory, and absolutely delicious. This one-pan version makes it easy!"
        r2.prepTime = 10
        r2.cookTime = 35
        r2.calories = 420
        r2.protein = 35.0
        r2.carbs = 8.5
        r2.fat = 22.0
        r2.tags = ["Dinner", "One-Pan", "Filipino", "Comfort Food"]
        r2.tips = [
            "Don't stir the vinegar until it's fully cooked to avoid sour taste",
            "Let it rest before serving for better flavor",
            "Best served with steamed rice"
        ]
        r2.ingredients = [
            Ingredient("Chicken thighs", amount: "800", unit: "g", category: .meat),
            Ingredient("Soy sauce", amount: "1/2", unit: "cup", category: .pantry),
            Ingredient("Vinegar", amount: "1/3", unit: "cup", category: .pantry),
            Ingredient("Water", amount: "1/2", unit: "cup", category: .pantry),
            Ingredient("Garlic", amount: "6", unit: "cloves", category: .produce),
            Ingredient("Bay leaves", amount: "3", unit: "pcs", category: .spices),
            Ingredient("Peppercorns", amount: "1", unit: "tsp", category: .spices),
            Ingredient("Brown sugar", amount: "1", unit: "tbsp", category: .pantry),
            Ingredient("Onion", amount: "1", unit: "pc", category: .produce),
            Ingredient("Oil", amount: "1", unit: "tbsp", category: .pantry)
        ]
        r2.steps = [
            StepItem(1, "Sauté onion & garlic in oil.", tip: "Until fragrant and translucent"),
            StepItem(2, "Add chicken; sear both sides.", timerMinutes: 5, tip: "Sear until golden brown"),
            StepItem(3, "Pour soy, vinegar, water; add bay & peppercorns; simmer 25–30m.", timerMinutes: 30, tip: "Don't stir until vinegar is cooked"),
            StepItem(4, "Stir in sugar; reduce to glossy sauce.", tip: "Cook until sauce thickens"),
            StepItem(5, "Rest 5m; serve with rice.", tip: "Let flavors meld together")
        ]
        r2.authorEmail = "community@sarap.io"
        r2.authorName = "Community"
        r2.createdAt = Date().addingTimeInterval(-86400 * 3) // 3 days ago

        var r3 = Recipe(title: "Veggie Stir-Fry", minutes: 25, servings: 2, cuisine: "Asian", region: "Lucena")
        r3.imageUrl = "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80"
        r3.imageName = "veggie" // Fallback
        r3.difficulty = .easy
        r3.description = "Colorful and healthy vegetable stir-fry that's ready in minutes. Perfect for a quick lunch!"
        r3.prepTime = 10
        r3.cookTime = 15
        r3.calories = 180
        r3.protein = 6.5
        r3.carbs = 22.0
        r3.fat = 8.5
        r3.tags = ["Under 30m", "Veggie", "One-Pan", "Healthy"]
        r3.tips = [
            "Keep the heat high for that wok hei flavor",
            "Don't overcook vegetables - they should be crisp",
            "Add a splash of sesame oil at the end for extra flavor"
        ]
        r3.ingredients = [
            Ingredient("Broccoli", amount: "1", unit: "head", category: .produce),
            Ingredient("Carrot", amount: "1", unit: "pc", category: .produce),
            Ingredient("Bell pepper", amount: "1", unit: "pc", category: .produce),
            Ingredient("Mushrooms", amount: "150", unit: "g", category: .produce),
            Ingredient("Garlic", amount: "3", unit: "cloves", category: .produce),
            Ingredient("Soy sauce", amount: "2", unit: "tbsp", category: .pantry),
            Ingredient("Oyster sauce", amount: "1", unit: "tbsp", category: .pantry),
            Ingredient("Cornstarch", amount: "1", unit: "tsp (slurry)", category: .pantry),
            Ingredient("Oil", amount: "1", unit: "tbsp", category: .pantry)
        ]
        r3.steps = [
            StepItem(1, "Stir-fry vegetables on high heat (5–6m).", timerMinutes: 6, tip: "Keep them moving constantly"),
            StepItem(2, "Add garlic; toss (30s).", tip: "Just until fragrant"),
            StepItem(3, "Add sauces + slurry; thicken (1–2m).", tip: "Stir until sauce coats vegetables")
        ]
        r3.authorEmail = "community@sarap.io"
        r3.authorName = "Community"
        r3.createdAt = Date().addingTimeInterval(-86400) // 1 day ago

        var r4 = Recipe(title: "Sinigang na Baboy", minutes: 60, servings: 6, cuisine: "Filipino", region: "Quezon")
        r4.imageUrl = "https://cdn.apartmenttherapy.info/image/upload/f_auto,q_auto:eco,c_fill,g_auto,w_1456,h_1092/k%2FPhoto%2FRecipes%2F2024-09-sinigang%2Fsinigang-372"
        r4.imageName = "sinigang" // Fallback
        r4.difficulty = .medium
        r4.description = "Classic Filipino sour soup with pork and vegetables. Perfect comfort food!"
        r4.prepTime = 15
        r4.cookTime = 45
        r4.calories = 320
        r4.protein = 28.0
        r4.carbs = 15.0
        r4.fat = 18.0
        r4.tags = ["Soup", "Filipino", "Comfort Food", "Dinner"]
        r4.tips = ["Use fresh tamarind for authentic sour taste", "Don't overcook the vegetables", "Best served hot with rice"]
        r4.ingredients = [
            Ingredient("Pork ribs", amount: "1", unit: "kg", category: .meat),
            Ingredient("Tamarind", amount: "1", unit: "pack", category: .produce),
            Ingredient("Tomato", amount: "2", unit: "pcs", category: .produce),
            Ingredient("Onion", amount: "1", unit: "pc", category: .produce),
            Ingredient("Radish", amount: "2", unit: "pcs", category: .produce),
            Ingredient("String beans", amount: "200", unit: "g", category: .produce),
            Ingredient("Eggplant", amount: "2", unit: "pcs", category: .produce),
            Ingredient("Okra", amount: "6", unit: "pcs", category: .produce),
            Ingredient("Kangkong", amount: "1", unit: "bunch", category: .produce),
            Ingredient("Fish sauce", amount: "2", unit: "tbsp", category: .pantry)
        ]
        r4.steps = [
            StepItem(1, "Boil pork ribs until tender (30-40m).", timerMinutes: 40, tip: "Skim off scum for clear broth"),
            StepItem(2, "Add tamarind, tomato, onion; simmer 10m.", timerMinutes: 10, tip: "Extract tamarind pulp"),
            StepItem(3, "Add vegetables; cook until tender (5-8m).", timerMinutes: 8, tip: "Add hard vegetables first"),
            StepItem(4, "Season with fish sauce; add kangkong last.", tip: "Kangkong cooks quickly, add at the end")
        ]
        r4.authorEmail = "demo@sarap.io"
        r4.authorName = "Chef Demo"
        r4.createdAt = Date().addingTimeInterval(-86400 * 7) // 7 days ago

        var r5 = Recipe(title: "Pancit Canton", minutes: 30, servings: 4, cuisine: "Filipino", region: "Quezon")
        // Note: Pancit Canton uses base64 data URI - keeping placeholder for now
        r5.imageUrl = "https://images.unsplash.com/photo-1569718212165-3a8278d5f624?w=800&q=80"
        r5.imageName = "pancit" // Fallback
        r5.difficulty = .medium
        r5.description = "Classic Filipino stir-fried noodles with vegetables and meat. A party favorite!"
        r5.prepTime = 15
        r5.cookTime = 15
        r5.calories = 380
        r5.protein = 18.0
        r5.carbs = 55.0
        r5.fat = 12.0
        r5.tags = ["Noodles", "Filipino", "Party", "Lunch"]
        r5.tips = ["Don't overcook the noodles", "Keep the heat high for best flavor", "Add calamansi before serving"]
        r5.ingredients = [
            Ingredient("Canton noodles", amount: "400", unit: "g", category: .pantry),
            Ingredient("Pork", amount: "200", unit: "g", category: .meat),
            Ingredient("Shrimp", amount: "150", unit: "g", category: .meat),
            Ingredient("Cabbage", amount: "1/4", unit: "head", category: .produce),
            Ingredient("Carrot", amount: "1", unit: "pc", category: .produce),
            Ingredient("Bean sprouts", amount: "100", unit: "g", category: .produce),
            Ingredient("Soy sauce", amount: "3", unit: "tbsp", category: .pantry),
            Ingredient("Oyster sauce", amount: "2", unit: "tbsp", category: .pantry),
            Ingredient("Garlic", amount: "4", unit: "cloves", category: .produce),
            Ingredient("Onion", amount: "1", unit: "pc", category: .produce)
        ]
        r5.steps = [
            StepItem(1, "Sauté garlic and onion until fragrant.", tip: "Medium heat to avoid burning"),
            StepItem(2, "Add pork and shrimp; cook until done.", timerMinutes: 5, tip: "Cook until pink/opaque"),
            StepItem(3, "Add vegetables; stir-fry 3-4 minutes.", timerMinutes: 4, tip: "Keep them crisp"),
            StepItem(4, "Add noodles and sauces; toss well.", tip: "Mix thoroughly to coat noodles")
        ]
        r5.authorEmail = "demo@sarap.io"
        r5.authorName = "Chef Demo"
        r5.createdAt = Date().addingTimeInterval(-86400 * 6) // 6 days ago

        var r6 = Recipe(title: "Lechon Kawali", minutes: 90, servings: 6, cuisine: "Filipino", region: "Quezon")
        r6.imageUrl = "https://www.seriouseats.com/thmb/VHJrPH45gZAhHM_XOKIVghsWHng=/750x0/filters:no_upscale():max_bytes(150000):strip_icc()/20210508-lechon-kawali-melissa-hom-2-inchChunks-seriouseats-1d53c12cee234305b921362e2106bf29.jpg"
        r6.imageName = "lechon" // Fallback
        r6.difficulty = .hard
        r6.description = "Crispy deep-fried pork belly. A Filipino favorite that's worth the effort!"
        r6.prepTime = 20
        r6.cookTime = 70
        r6.calories = 520
        r6.protein = 32.0
        r6.carbs = 2.0
        r6.fat = 42.0
        r6.tags = ["Pork", "Filipino", "Crispy", "Dinner"]
        r6.tips = ["Boil first to tenderize", "Dry completely before frying", "Fry in batches for even cooking"]
        r6.ingredients = [
            Ingredient("Pork belly", amount: "1.5", unit: "kg", category: .meat),
            Ingredient("Bay leaves", amount: "5", unit: "pcs", category: .spices),
            Ingredient("Peppercorns", amount: "1", unit: "tbsp", category: .spices),
            Ingredient("Salt", category: .spices),
            Ingredient("Garlic", amount: "6", unit: "cloves", category: .produce),
            Ingredient("Oil", amount: "enough for deep frying", unit: "", category: .pantry)
        ]
        r6.steps = [
            StepItem(1, "Boil pork belly with aromatics 45-60m until tender.", timerMinutes: 60, tip: "Skim scum regularly"),
            StepItem(2, "Drain and dry completely; score the skin.", tip: "Pat dry with paper towels"),
            StepItem(3, "Deep fry until golden and crispy (8-10m).", timerMinutes: 10, tip: "Be careful of splatter"),
            StepItem(4, "Rest 5m; slice and serve with sauce.", tip: "Let it rest before slicing")
        ]
        r6.authorEmail = "demo@sarap.io"
        r6.authorName = "Chef Demo"
        r6.createdAt = Date().addingTimeInterval(-86400 * 4) // 4 days ago

        var r7 = Recipe(title: "Kare-Kare", minutes: 90, servings: 6, cuisine: "Filipino", region: "Quezon")
        r7.imageUrl = "https://panlasangpinoy.com/wp-content/uploads/2020/12/Pata-Kare-Kare.jpg"
        r7.imageName = "kare-kare" // Fallback
        r7.difficulty = .hard
        r7.description = "Rich oxtail stew with peanut sauce. A Filipino classic that's perfect for special occasions!"
        r7.prepTime = 30
        r7.cookTime = 60
        r7.calories = 450
        r7.protein = 35.0
        r7.carbs = 18.0
        r7.fat = 28.0
        r7.tags = ["Stew", "Filipino", "Special", "Dinner"]
        r7.tips = ["Cook oxtail until very tender", "Toast peanuts for better flavor", "Serve with bagoong"]
        r7.ingredients = [
            Ingredient("Oxtail", amount: "1.5", unit: "kg", category: .meat),
            Ingredient("Peanut butter", amount: "1/2", unit: "cup", category: .pantry),
            Ingredient("Annatto seeds", amount: "2", unit: "tbsp", category: .spices),
            Ingredient("Eggplant", amount: "2", unit: "pcs", category: .produce),
            Ingredient("String beans", amount: "200", unit: "g", category: .produce),
            Ingredient("Bok choy", amount: "2", unit: "heads", category: .produce),
            Ingredient("Garlic", amount: "6", unit: "cloves", category: .produce),
            Ingredient("Onion", amount: "1", unit: "pc", category: .produce),
            Ingredient("Rice flour", amount: "2", unit: "tbsp", category: .pantry),
            Ingredient("Bagoong", amount: "1", unit: "jar", category: .pantry)
        ]
        r7.steps = [
            StepItem(1, "Boil oxtail until very tender (45-60m).", timerMinutes: 60, tip: "Reserve the broth"),
            StepItem(2, "Sauté garlic and onion; add annatto oil.", tip: "Extract color from annatto"),
            StepItem(3, "Add oxtail, broth, peanut butter; simmer 20m.", timerMinutes: 20, tip: "Stir until smooth"),
            StepItem(4, "Add vegetables; thicken with rice flour.", tip: "Add vegetables at the end"),
            StepItem(5, "Serve with bagoong on the side.", tip: "Traditional pairing")
        ]
        r7.authorEmail = "demo@sarap.io"
        r7.authorName = "Chef Demo"
        r7.createdAt = Date().addingTimeInterval(-86400 * 2) // 2 days ago

        var r8 = Recipe(title: "Lumpia Shanghai", minutes: 45, servings: 8, cuisine: "Filipino", region: "Quezon")
        r8.imageUrl = "https://thefoodietakesflight.com/wp-content/uploads/2020/10/Lumpiang-Shanghai.jpg"
        r8.imageName = "lumpia" // Fallback
        r8.difficulty = .medium
        r8.description = "Crispy Filipino spring rolls. Perfect as appetizer or snack!"
        r8.prepTime = 25
        r8.cookTime = 20
        r8.calories = 180
        r8.protein = 12.0
        r8.carbs = 15.0
        r8.fat = 8.0
        r8.tags = ["Appetizer", "Filipino", "Crispy", "Snack"]
        r8.tips = ["Roll tightly to prevent breaking", "Don't overfill", "Fry until golden brown"]
        r8.ingredients = [
            Ingredient("Ground pork", amount: "500", unit: "g", category: .meat),
            Ingredient("Lumpia wrapper", amount: "20", unit: "pcs", category: .pantry),
            Ingredient("Carrot", amount: "1", unit: "pc", category: .produce),
            Ingredient("Onion", amount: "1", unit: "pc", category: .produce),
            Ingredient("Garlic", amount: "3", unit: "cloves", category: .produce),
            Ingredient("Egg", amount: "1", unit: "pc", category: .dairy),
            Ingredient("Soy sauce", amount: "1", unit: "tbsp", category: .pantry),
            Ingredient("Salt", category: .spices),
            Ingredient("Pepper", category: .spices),
            Ingredient("Oil", amount: "for frying", unit: "", category: .pantry)
        ]
        r8.steps = [
            StepItem(1, "Mix ground pork with vegetables and seasonings.", tip: "Mix well until combined"),
            StepItem(2, "Wrap in lumpia wrapper; seal with egg.", tip: "Roll tightly"),
            StepItem(3, "Fry until golden and crispy (5-7m).", timerMinutes: 7, tip: "Turn occasionally"),
            StepItem(4, "Drain on paper towels; serve hot.", tip: "Best served immediately")
        ]
        r8.authorEmail = "demo@sarap.io"
        r8.authorName = "Chef Demo"
        r8.createdAt = Date().addingTimeInterval(-86400 * 8) // 8 days ago

        var r9 = Recipe(title: "Beef Caldereta", minutes: 75, servings: 6, cuisine: "Filipino", region: "Quezon")
        r9.imageUrl = "https://cdn.sanity.io/images/f3knbc2s/production/f74d8aed0419d87b41895136fede06b671ed0482-2500x1500.jpg?auto=format"
        r9.imageName = "caldereta" // Fallback
        r9.difficulty = .hard
        r9.description = "Rich and hearty beef stew with tomato sauce and vegetables. A Filipino comfort food classic!"
        r9.prepTime = 20
        r9.cookTime = 55
        r9.calories = 420
        r9.protein = 38.0
        r9.carbs = 22.0
        r9.fat = 20.0
        r9.tags = ["Stew", "Filipino", "Comfort Food", "Dinner"]
        r9.tips = ["Use beef with some fat for flavor", "Cook until very tender", "Add liver spread for richness"]
        r9.ingredients = [
            Ingredient("Beef", amount: "1", unit: "kg", category: .meat),
            Ingredient("Tomato sauce", amount: "1", unit: "can", category: .pantry),
            Ingredient("Liver spread", amount: "1/2", unit: "can", category: .pantry),
            Ingredient("Potato", amount: "3", unit: "pcs", category: .produce),
            Ingredient("Carrot", amount: "2", unit: "pcs", category: .produce),
            Ingredient("Bell pepper", amount: "2", unit: "pcs", category: .produce),
            Ingredient("Green olives", amount: "1/2", unit: "cup", category: .pantry),
            Ingredient("Garlic", amount: "6", unit: "cloves", category: .produce),
            Ingredient("Onion", amount: "1", unit: "pc", category: .produce),
            Ingredient("Bay leaves", amount: "3", unit: "pcs", category: .spices)
        ]
        r9.steps = [
            StepItem(1, "Sauté garlic and onion; add beef; sear.", timerMinutes: 5, tip: "Sear until brown"),
            StepItem(2, "Add tomato sauce and water; simmer 40m.", timerMinutes: 40, tip: "Until beef is tender"),
            StepItem(3, "Add vegetables and liver spread; cook 10m.", timerMinutes: 10, tip: "Until vegetables are done"),
            StepItem(4, "Add olives; season; serve hot.", tip: "Best with rice")
        ]
        r9.authorEmail = "demo@sarap.io"
        r9.authorName = "Chef Demo"
        r9.createdAt = Date().addingTimeInterval(-86400 * 9) // 9 days ago

        var r10 = Recipe(title: "Tinolang Manok", minutes: 40, servings: 4, cuisine: "Filipino", region: "Quezon")
        r10.imageUrl = "https://images.yummy.ph/yummy/uploads/2023/03/tinolang-manok-640.jpg"
        r10.imageName = "tinola" // Fallback
        r10.difficulty = .easy
        r10.description = "Light and comforting chicken soup with ginger and vegetables. Perfect for rainy days!"
        r10.prepTime = 10
        r10.cookTime = 30
        r10.calories = 280
        r10.protein = 32.0
        r10.carbs = 12.0
        r10.fat = 12.0
        r10.tags = ["Soup", "Filipino", "Comfort Food", "Dinner"]
        r10.tips = ["Use fresh ginger for best flavor", "Don't overcook the vegetables", "Serve with fish sauce"]
        r10.ingredients = [
            Ingredient("Chicken", amount: "1", unit: "kg", category: .meat),
            Ingredient("Ginger", amount: "2", unit: "thumbs", category: .produce),
            Ingredient("Chayote", amount: "2", unit: "pcs", category: .produce),
            Ingredient("Papaya", amount: "1", unit: "pc", category: .produce),
            Ingredient("Malunggay leaves", amount: "1", unit: "bunch", category: .produce),
            Ingredient("Garlic", amount: "4", unit: "cloves", category: .produce),
            Ingredient("Onion", amount: "1", unit: "pc", category: .produce),
            Ingredient("Fish sauce", amount: "2", unit: "tbsp", category: .pantry),
            Ingredient("Pepper", category: .spices)
        ]
        r10.steps = [
            StepItem(1, "Sauté ginger, garlic, onion until fragrant.", tip: "Medium heat"),
            StepItem(2, "Add chicken; cook until slightly brown.", timerMinutes: 5, tip: "Sear both sides"),
            StepItem(3, "Add water; bring to boil; simmer 20m.", timerMinutes: 20, tip: "Until chicken is tender"),
            StepItem(4, "Add vegetables; cook 5m; season.", timerMinutes: 5, tip: "Add malunggay last")
        ]
        r10.authorEmail = "demo@sarap.io"
        r10.authorName = "Chef Demo"
        r10.createdAt = Date().addingTimeInterval(-86400 * 10) // 10 days ago

        return [r1, r2, r3, r4, r5, r6, r7, r8, r9, r10]
    }()
}
