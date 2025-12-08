import Foundation

enum SocialSampleData {
    static let posts: [SocialPost] = {
        let recipes = SampleData.recipes
        guard recipes.count >= 10 else { return [] }
        
        return [
            SocialPost(
                id: UUID(),
                user: "moris123",
                avatar: "moris",
                caption: "Easy and garlicky shrimp 🦐🔥 perfect for dinner!",
                recipe: recipes[0],
                likes: 32,
                comments: [
                    SocialPost.Comment(user: "foodie_lover", text: "Sarap nito ah, pwede pang ulam bukas 👌"),
                    SocialPost.Comment(user: "cooking_mom", text: "Grabe, I tried this and super dali lang gawin 😋"),
                    SocialPost.Comment(user: "rice_king", text: "Mas masarap pag may kanin! 🍚")
                ],
                rating: 4,
                createdAt: Date().addingTimeInterval(-7200) // 2 hours ago
            ),
            SocialPost(
                id: UUID(),
                user: "chef_ana",
                avatar: "ana",
                caption: "Classic adobo recipe from Quezon 🇵🇭",
                recipe: recipes[1],
                likes: 50,
                comments: [
                    SocialPost.Comment(user: "pinoy_chef", text: "Solid! walang tatalo sa adobo 🔥"),
                    SocialPost.Comment(user: "family_cook", text: "Favorite ng pamilya ko 'to, swear!"),
                    SocialPost.Comment(user: "rice_lover", text: "Best with extra rice, agree? 😂")
                ],
                rating: 5,
                createdAt: Date().addingTimeInterval(-14400) // 4 hours ago
            ),
            SocialPost(
                id: UUID(),
                user: "veggiequeen",
                avatar: "veggie",
                caption: "Healthy stir-fry — quick lunch idea 🥦🥕",
                recipe: recipes[2],
                likes: 18,
                comments: [
                    SocialPost.Comment(user: "healthy_eater", text: "Pwede ko lagyan ng tofu para mas busog 😍"),
                    SocialPost.Comment(user: "food_photog", text: "Super colorful plate! ang ganda tignan 😮"),
                    SocialPost.Comment(user: "asian_cuisine", text: "Masarap 'to with konting sesame oil 👌")
                ],
                rating: 3,
                createdAt: Date().addingTimeInterval(-86400) // 1 day ago
            ),
            SocialPost(
                id: UUID(),
                user: "chef_demo",
                avatar: "demo",
                caption: "Sinigang na baboy - perfect comfort food! 🍲",
                recipe: recipes[3],
                likes: 67,
                comments: [
                    SocialPost.Comment(user: "soup_lover", text: "Grabe ang sarap! Perfect sa malamig na panahon ❄️"),
                    SocialPost.Comment(user: "filipino_food", text: "Classic! Walang tatalo sa sinigang 🥰"),
                    SocialPost.Comment(user: "home_chef", text: "Tried this recipe, super easy to follow! 👏")
                ],
                rating: 5,
                createdAt: Date().addingTimeInterval(-10800) // 3 hours ago
            ),
            SocialPost(
                id: UUID(),
                user: "noodle_master",
                avatar: "noodle",
                caption: "Pancit Canton for the win! 🍜 Perfect for parties",
                recipe: recipes[4],
                likes: 45,
                comments: [
                    SocialPost.Comment(user: "party_planner", text: "Ginawa ko 'to sa birthday party, lahat nagustuhan! 🎉"),
                    SocialPost.Comment(user: "noodle_fan", text: "Ang sarap! Pwede ba recipe? 😋"),
                    SocialPost.Comment(user: "cooking_pro", text: "Pro tip: Add calamansi before serving! 🍋")
                ],
                rating: 4,
                createdAt: Date().addingTimeInterval(-18000) // 5 hours ago
            ),
            SocialPost(
                id: UUID(),
                user: "crispy_chef",
                avatar: "crispy",
                caption: "Lechon Kawali - crispy perfection! 🐷✨",
                recipe: recipes[5],
                likes: 89,
                comments: [
                    SocialPost.Comment(user: "pork_lover", text: "Grabe ang crispy! Paano mo ginawa? 🤤"),
                    SocialPost.Comment(user: "foodie_ph", text: "This is my favorite! Bookmarked! ⭐"),
                    SocialPost.Comment(user: "cooking_mom", text: "Perfect for special occasions! 🎊")
                ],
                rating: 5,
                createdAt: Date().addingTimeInterval(-21600) // 6 hours ago
            ),
            SocialPost(
                id: UUID(),
                user: "stew_king",
                avatar: "stew",
                caption: "Kare-Kare - rich and creamy! Perfect for celebrations 🎉",
                recipe: recipes[6],
                likes: 72,
                comments: [
                    SocialPost.Comment(user: "filipino_foodie", text: "Classic Filipino dish! Ang sarap! 😍"),
                    SocialPost.Comment(user: "special_occasions", text: "Ginawa ko 'to sa fiesta, super hit! 🎊"),
                    SocialPost.Comment(user: "peanut_lover", text: "Love the peanut sauce! Creamy and rich! 🥜")
                ],
                rating: 5,
                createdAt: Date().addingTimeInterval(-25200) // 7 hours ago
            ),
            SocialPost(
                id: UUID(),
                user: "appetizer_queen",
                avatar: "appetizer",
                caption: "Lumpia Shanghai - crispy and delicious! Perfect snack 🥟",
                recipe: recipes[7],
                likes: 56,
                comments: [
                    SocialPost.Comment(user: "snack_time", text: "Perfect merienda! Ang crispy! 🍴"),
                    SocialPost.Comment(user: "party_food", text: "Best appetizer ever! Everyone loved it! 👌"),
                    SocialPost.Comment(user: "crispy_fan", text: "How do you make it so crispy? Share tips! 💡")
                ],
                rating: 4,
                createdAt: Date().addingTimeInterval(-28800) // 8 hours ago
            ),
            SocialPost(
                id: UUID(),
                user: "beef_master",
                avatar: "beef",
                caption: "Beef Caldereta - hearty and comforting! Perfect for family dinner 👨‍👩‍👧‍👦",
                recipe: recipes[8],
                likes: 63,
                comments: [
                    SocialPost.Comment(user: "family_chef", text: "Favorite ng pamilya ko 'to! 🥰"),
                    SocialPost.Comment(user: "comfort_food", text: "Perfect comfort food! Ang sarap! 😋"),
                    SocialPost.Comment(user: "stew_lover", text: "Rich and flavorful! Bookmarked! ⭐")
                ],
                rating: 5,
                createdAt: Date().addingTimeInterval(-32400) // 9 hours ago
            ),
            SocialPost(
                id: UUID(),
                user: "soup_chef",
                avatar: "soup",
                caption: "Tinolang Manok - light and comforting! Perfect for rainy days ☔",
                recipe: recipes[9],
                likes: 41,
                comments: [
                    SocialPost.Comment(user: "rainy_day", text: "Perfect for today's weather! ☔"),
                    SocialPost.Comment(user: "soup_lover", text: "Light and healthy! Ang sarap! 🍲"),
                    SocialPost.Comment(user: "comfort_food", text: "This is my go-to comfort food! ❤️")
                ],
                rating: 4,
                createdAt: Date().addingTimeInterval(-36000) // 10 hours ago
            )
        ]
    }()
}
