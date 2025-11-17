import Foundation

@MainActor
final class SocialFeedStore: ObservableObject {
    @Published var posts: [SocialPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repo = PostsRepo()
    
    init() {
        // Load from database only - no local storage
        Task {
            await loadPosts()
        }
    }
    
    // MARK: - Database Integration
    
    func loadPosts() async {
        isLoading = true
        await repo.fetchAll()
        if !repo.posts.isEmpty {
            posts = repo.posts
        }
        isLoading = false
    }

    func toggleLike(for post: SocialPost) async {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        let newLikes = max(0, posts[index].likes + (posts[index].isLiked ? -1 : 1))
        posts[index].isLiked.toggle()
        posts[index].likes = newLikes
        
        // Sync to database
        await repo.updateLikes(post.id, likes: newLikes)
    }

    func toggleSave(for post: SocialPost) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].isSaved.toggle()
    }

    func setRating(_ rating: Int, for post: SocialPost) async {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].userRating = rating
        
        // Sync to database
        await repo.updateRating(post.id, rating: rating)
    }

    func append(_ post: SocialPost) async {
        posts.insert(post, at: 0)
        await repo.add(post)
        await loadPosts()
    }

    func addComment(_ comment: String, to post: SocialPost) async {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].comments.append(comment)
        
        // Sync to database
        await repo.addComment(post.id, comment: comment)
    }
}
