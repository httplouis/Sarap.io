import Foundation

final class SocialFeedStore: ObservableObject {
    @Published var posts: [SocialPost] = [] {
        didSet {
            savePosts()
        }
    }
    
    private let postsKey = "sarapio.savedPosts"
    
    init() {
        loadPosts()
        if posts.isEmpty {
            posts = SocialSampleData.posts
        }
    }

    func toggleLike(for post: SocialPost) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].isLiked.toggle()
        posts[index].likes = max(0, posts[index].likes + (posts[index].isLiked ? 1 : -1))
    }

    func toggleSave(for post: SocialPost) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].isSaved.toggle()
    }

    func setRating(_ rating: Int, for post: SocialPost) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].userRating = rating
    }

    func append(_ post: SocialPost) {
        var newPost = post
        newPost.createdAt = Date()
        posts.insert(newPost, at: 0)
    }

    func addComment(_ comment: String, to post: SocialPost, by user: String) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        let newComment = SocialPost.Comment(user: user, text: comment)
        posts[index].comments.append(newComment)
    }
    
    func getSavedPosts() -> [SocialPost] {
        return posts.filter { $0.isSaved }
    }
    
    func getLikedPosts() -> [SocialPost] {
        return posts.filter { $0.isLiked }
    }
    
    func incrementShare(for post: SocialPost) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].shares += 1
    }
    
    private func savePosts() {
        if let encoded = try? JSONEncoder().encode(posts) {
            UserDefaults.standard.set(encoded, forKey: postsKey)
        }
    }
    
    private func loadPosts() {
        guard let data = UserDefaults.standard.data(forKey: postsKey),
              let decoded = try? JSONDecoder().decode([SocialPost].self, from: data) else {
            return
        }
        posts = decoded
    }
}
