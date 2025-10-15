import SwiftUI

struct SocialFeedView: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var auth: AuthManager

    @State private var posts: [SocialPost] = SocialSampleData.posts
    @Binding private var showComposer: Bool
    @State private var toastMessage: String?

    init(showComposer: Binding<Bool>? = nil) {
        self._showComposer = showComposer ?? .constant(false)
    }

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 22) {
                ForEach($posts) { $post in
                    SocialPostCard(
                        post: $post,
                        onCopy: copyRecipe,
                        onRate: updateRating,
                        onShare: showShareToast,
                        onComment: appendComment
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Feed")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showComposer = true
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.olive)
                        .padding(.trailing, 6)
                }
            }
        }
        .sheet(isPresented: $showComposer) {
            AddSocialPostView { post in
                posts.insert(post, at: 0)
            }
            .environmentObject(store)
        }
        .alert(toastMessage ?? "", isPresented: Binding(
            get: { toastMessage != nil },
            set: { if !$0 { toastMessage = nil } }
        )) {
            Button("OK", role: .cancel) { toastMessage = nil }
        }
    }

    private func copyRecipe(_ recipe: Recipe) {
        store.copyFromFeed(recipe, ownerId: auth.currentUser?.id)
        auth.updateStats(recipesCount: store.recipes.filter { $0.ownerId == auth.currentUser?.id }.count)
        toastMessage = "Recipe saved to My Recipes"
    }

    private func updateRating(for post: SocialPost, rating: Int) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].rating = rating
        toastMessage = "Rated \(post.recipe.title) with \(rating)★"
    }

    private func showShareToast(for post: SocialPost) {
        toastMessage = "Share coming soon for \(post.recipe.title)!"
    }

    private func appendComment(for post: SocialPost, comment: String) {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].comments.insert(comment, at: 0)
    }
}

struct SocialPostCard: View {
    @Binding var post: SocialPost

    @State private var commentText = ""

    var onCopy: (Recipe) -> Void
    var onRate: (SocialPost, Int) -> Void
    var onShare: (SocialPost) -> Void
    var onComment: (SocialPost, String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            header
            recipeImage
            actions
            likesAndCaption
            commentsPreview
            commentComposer
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
    }

    private var header: some View {
        HStack(spacing: 10) {
            avatar
            VStack(alignment: .leading, spacing: 2) {
                Text("@\(post.user)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.text)
                Text("Posted 2h ago")
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
            Spacer()
            Button { } label: {
                Image(systemName: "ellipsis")
                    .font(.headline)
                    .foregroundStyle(.gray)
            }
        }
    }

    private var avatar: some View {
        Group {
            if let avatar = post.avatar, let uiImage = UIImage(named: avatar) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(Theme.olive)
                    .overlay(Image(systemName: "person.fill").foregroundStyle(.white))
            }
        }
        .frame(width: 36, height: 36)
        .clipShape(Circle())
    }

    @ViewBuilder
    private var recipeImage: some View {
        if let imgName = post.recipe.imageName {
            Image(imgName)
                .resizable()
                .scaledToFill()
                .frame(maxHeight: 280)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .clipped()
        } else if let data = post.recipe.imageData, let ui = UIImage(data: data) {
            Image(uiImage: ui)
                .resizable()
                .scaledToFill()
                .frame(maxHeight: 280)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .clipped()
        }
    }

    private var actions: some View {
        HStack(spacing: 20) {
            Button {
                post.isLiked.toggle()
                post.likes += post.isLiked ? 1 : -1
            } label: {
                Image(systemName: post.isLiked ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundStyle(post.isLiked ? .pink : Theme.subtext)
            }

            Button { } label: {
                Image(systemName: "bubble.right")
                    .font(.title3)
                    .foregroundStyle(Theme.subtext)
            }

            Button { onShare(post) } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.title3)
                    .foregroundStyle(Theme.subtext)
            }

            Spacer()

            Menu {
                ForEach(1...5, id: \.self) { star in
                    Button(action: {
                        post.rating = star
                        onRate(post, star)
                    }) {
                        Label("\(star) Star", systemImage: star <= post.rating ? "star.fill" : "star")
                    }
                }
            } label: {
                Label("Rate", systemImage: "star.fill")
                    .labelStyle(.titleAndIcon)
                    .foregroundStyle(Theme.olive)
            }

            Button { onCopy(post.recipe) } label: {
                Label("Copy", systemImage: "tray.and.arrow.down")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(Theme.olive)
            }
        }
    }

    private var likesAndCaption: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(post.likes) likes")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.text)
                .padding(.top, 4)

            Text(post.caption)
                .font(.body)
                .foregroundStyle(Theme.text)

            if post.rating > 0 {
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= post.rating ? "star.fill" : "star")
                            .foregroundStyle(star <= post.rating ? Theme.olive : Theme.subtext)
                    }
                    Text("\(post.rating)/5")
                        .font(.caption)
                        .foregroundStyle(Theme.subtext)
                }
            }
        }
    }

    private var commentsPreview: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !post.comments.isEmpty {
                ForEach(post.comments.prefix(3), id: \.self) { comment in
                    Text("💬 \(comment)")
                        .font(.footnote)
                        .foregroundStyle(Theme.subtext)
                }
            } else {
                Text("No comments yet. Be the first to react!")
                    .font(.footnote)
                    .foregroundStyle(Theme.subtext)
            }
        }
    }

    private var commentComposer: some View {
        HStack {
            TextField("Add a comment…", text: $commentText)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 14).fill(Theme.bg))

            Button {
                let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                onComment(post, trimmed)
                commentText = ""
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.title3)
                    .foregroundStyle(Theme.olive)
            }
        }
        .padding(.top, 6)
    }
}
