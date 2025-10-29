import Foundation

final class SocialFeedStore: ObservableObject {
    @Published var posts: [SocialPost] = SocialSampleData.posts

    init() {}

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
        posts.insert(post, at: 0)
    }

    func addComment(_ comment: String, to post: SocialPost) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].comments.append(comment)
    }
}
