import Foundation
import Supabase

@MainActor
final class PostsRepo: ObservableObject {
    private let client = SupabaseClientManager.shared
    @Published var posts: [SocialPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    func fetchAll() async {
        isLoading = true
        errorMessage = nil
        do {
            let response = try await client
                .database
                .from("posts")
                .select()
                .order("created_at", ascending: false)
                .execute()

            // Parse response
            if let data = response.data,
               let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                var decodedPosts: [SocialPost] = []
                
                for json in jsonArray {
                    if let post = try? decodePost(from: json) {
                        decodedPosts.append(post)
                    }
                }
                
                self.posts = decodedPosts
            }
        } catch {
            print("❌ Posts fetch failed:", error.localizedDescription)
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func add(_ post: SocialPost) async {
        isLoading = true
        errorMessage = nil
        do {
            let postDict = try encodePost(post)
            _ = try await client
                .database
                .from("posts")
                .insert([postDict])
                .execute()
            await fetchAll()
        } catch {
            print("❌ Post insert failed:", error.localizedDescription)
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func updateLikes(_ postId: UUID, likes: Int) async {
        do {
            _ = try await client
                .database
                .from("posts")
                .update(["likes": likes])
                .eq("id", value: postId.uuidString)
                .execute()
            await fetchAll()
        } catch {
            print("❌ Update likes failed:", error.localizedDescription)
        }
    }

    func addComment(_ postId: UUID, comment: String) async {
        do {
            // Fetch current post
            let response = try await client
                .database
                .from("posts")
                .select()
                .eq("id", value: postId.uuidString)
                .single()
                .execute()
            
            if let data = response.data,
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               var comments = json["comments"] as? [String] {
                comments.append(comment)
                _ = try await client
                    .database
                    .from("posts")
                    .update(["comments": comments])
                    .eq("id", value: postId.uuidString)
                    .execute()
                await fetchAll()
            }
        } catch {
            print("❌ Add comment failed:", error.localizedDescription)
        }
    }

    func updateRating(_ postId: UUID, rating: Int) async {
        do {
            _ = try await client
                .database
                .from("posts")
                .update(["rating": rating])
                .eq("id", value: postId.uuidString)
                .execute()
            await fetchAll()
        } catch {
            print("❌ Update rating failed:", error.localizedDescription)
        }
    }

    // MARK: - Helpers
    
    private func decodePost(from json: [String: Any]) throws -> SocialPost {
        let id = UUID(uuidString: json["id"] as? String ?? "") ?? UUID()
        let author = json["author"] as? String ?? "Unknown"
        let caption = json["caption"] as? String ?? ""
        let likes = json["likes"] as? Int ?? 0
        let rating = json["rating"] as? Int ?? 0
        let comments = json["comments"] as? [String] ?? []
        
        // Decode recipe
        var recipe = Recipe(
            title: "Untitled",
            minutes: 0,
            servings: 0
        )
        
        if let recipeIdString = json["recipe_id"] as? String,
           let recipeId = UUID(uuidString: recipeIdString) {
            // Fetch recipe from recipes table
            Task {
                do {
                    let recipeResponse = try await client
                        .database
                        .from("recipes")
                        .select()
                        .eq("id", value: recipeId.uuidString)
                        .single()
                        .execute()
                    
                    if let recipeData = recipeResponse.data,
                       let recipeJson = try? JSONSerialization.jsonObject(with: recipeData) as? [String: Any] {
                        recipe = try decodeRecipe(from: recipeJson)
                    }
                } catch {
                    print("⚠️ Could not fetch recipe for post")
                }
            }
        }
        
        return SocialPost(
            id: id,
            user: author,
            avatar: nil,
            caption: caption,
            recipe: recipe,
            likes: likes,
            comments: comments,
            rating: rating
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
        
        // Decode ingredients from JSONB
        var ingredients: [Ingredient] = []
        if let ingredientsData = json["ingredients"] as? [[String: Any]] {
            for ingDict in ingredientsData {
                let name = ingDict["name"] as? String ?? ""
                let quantity = ingDict["quantity"] as? String ?? ""
                // Parse quantity into amount and unit if needed
                let parts = quantity.split(separator: " ")
                if parts.count >= 2 {
                    ingredients.append(Ingredient(name, amount: String(parts[0]), unit: String(parts[1])))
                } else if parts.count == 1 {
                    ingredients.append(Ingredient(name, amount: String(parts[0]), unit: ""))
                } else {
                    ingredients.append(Ingredient(name))
                }
            }
        }
        
        // Decode steps from JSONB
        var steps: [StepItem] = []
        if let stepsData = json["steps"] as? [[String: Any]] {
            for (index, stepDict) in stepsData.enumerated() {
                let instruction = stepDict["instruction"] as? String ?? stepDict["text"] as? String ?? ""
                let order = stepDict["order_num"] as? Int ?? stepDict["order"] as? Int ?? (index + 1)
                steps.append(StepItem(order, instruction))
            }
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
            photo_url: photo_url
        )
    }
    
    private func encodePost(_ post: SocialPost) throws -> [String: Any] {
        var dict: [String: Any] = [
            "author": post.user,
            "caption": post.caption,
            "likes": post.likes,
            "rating": post.rating,
            "comments": post.comments
        ]
        
        // If recipe has an ID, use it; otherwise create recipe first
        if let recipeId = post.recipe.id as UUID? {
            dict["recipe_id"] = recipeId.uuidString
        }
        
        return dict
    }
}

