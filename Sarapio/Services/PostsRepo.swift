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
            struct PostRecord: Codable {
                let id: UUID
                let author: String
                let caption: String
                let recipe_id: UUID?
                let likes: Int
                let comments: [String]
                let rating: Int
                let created_at: String?
            }
            
            let response: [PostRecord] = try await client
                .database
                .from("posts")
                .select()
                .order("created_at", ascending: false)
                .execute()
                .value

            var decodedPosts: [SocialPost] = []
            
            for record in response {
                // Fetch recipe if recipe_id exists
                var recipe = Recipe(title: "Untitled", minutes: 0, servings: 0)
                if let recipeId = record.recipe_id {
                    do {
                        let recipeResponse: RecipeRecord = try await client
                            .database
                            .from("recipes")
                            .select()
                            .eq("id", value: recipeId.uuidString)
                            .single()
                            .execute()
                            .value
                        
                        // Convert RecipeRecord to Recipe (simplified)
                        recipe = Recipe(
                            id: recipeResponse.id,
                            title: recipeResponse.title,
                            minutes: recipeResponse.minutes ?? 0,
                            servings: recipeResponse.servings ?? 1,
                            cuisine: recipeResponse.cuisine,
                            region: recipeResponse.region,
                            isFavorite: recipeResponse.is_favorite ?? false,
                            user_id: recipeResponse.user_id,
                            photo_url: recipeResponse.photo_url
                        )
                    } catch {
                        print("⚠️ Could not fetch recipe for post:", error)
                    }
                }
                
                let post = SocialPost(
                    id: record.id,
                    user: record.author,
                    avatar: nil,
                    caption: record.caption,
                    recipe: recipe,
                    likes: record.likes,
                    comments: record.comments,
                    rating: record.rating
                )
                decodedPosts.append(post)
            }
            
            self.posts = decodedPosts
        } catch {
            print("❌ Posts fetch failed:", error.localizedDescription)
            errorMessage = error.localizedDescription
            // Keep existing posts on error
        }
        isLoading = false
    }

    func add(_ post: SocialPost) async {
        isLoading = true
        errorMessage = nil
        do {
            struct PostInsert: Codable {
                let author: String
                let caption: String
                let likes: Int
                let rating: Int
                let comments: [String]
                let recipe_id: String?
            }
            
            let insert = PostInsert(
                author: post.user,
                caption: post.caption,
                likes: post.likes,
                rating: post.rating,
                comments: post.comments,
                recipe_id: post.recipe.id.uuidString
            )
            
            _ = try await client
                .database
                .from("posts")
                .insert(insert)
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
            struct PostRecord: Codable {
                let comments: [String]
            }
            
            // Fetch current post
            let response: PostRecord = try await client
                .database
                .from("posts")
                .select()
                .eq("id", value: postId.uuidString)
                .single()
                .execute()
                .value
            
            var comments = response.comments
            comments.append(comment)
            
            _ = try await client
                .database
                .from("posts")
                .update(["comments": comments])
                .eq("id", value: postId.uuidString)
                .execute()
            await fetchAll()
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

}

