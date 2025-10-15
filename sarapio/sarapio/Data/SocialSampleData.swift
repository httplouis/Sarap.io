import Foundation

enum SocialSampleData {
    static let posts: [SocialPost] = [
        SocialPost(
            id: UUID(),
            user: "moris123",
            avatar: "moris", // asset image in Assets.xcassets
            caption: "Easy and garlicky shrimp 🦐🔥 perfect for dinner!",
            recipe: SampleData.recipes[0], // Garlic Butter Shrimp
            likes: 32,
            comments: [
                "Sarap nito ah, pwede pang ulam bukas 👌",
                "Grabe, I tried this and super dali lang gawin 😋",
                "Mas masarap pag may kanin! 🍚"
            ],
            rating: 4,
            isLiked: false
        ),
        SocialPost(
            id: UUID(),
            user: "chef_ana",
            avatar: "ana", // asset image in Assets.xcassets
            caption: "Classic adobo recipe from Quezon 🇵🇭",
            recipe: SampleData.recipes[1], // Chicken Adobo
            likes: 50,
            comments: [
                "Solid! walang tatalo sa adobo 🔥",
                "Favorite ng pamilya ko ‘to, swear!",
                "Best with extra rice, agree? 😂"
            ],
            rating: 5,
            isLiked: false
        ),
        SocialPost(
            id: UUID(),
            user: "veggiequeen",
            avatar: "veggie", // asset image in Assets.xcassets
            caption: "Healthy stir-fry — quick lunch idea 🥦🥕",
            recipe: SampleData.recipes[2], // Veggie Stir-Fry
            likes: 18,
            comments: [
                "Pwede ko lagyan ng tofu para mas busog 😍",
                "Super colorful plate! ang ganda tignan 😮",
                "Masarap ‘to with konting sesame oil 👌"
            ],
            rating: 3,
            isLiked: false
        )
    ]
}
