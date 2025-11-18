import SwiftUI
import UIKit

struct SocialFeedView: View {
    @EnvironmentObject private var feedStore: SocialFeedStore
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var bottomBar: BottomBarState

    @State private var commentDrafts: [UUID: String] = [:]
    @State private var showAddPost = false

    var body: some View {
        ScrollView {
            GeometryReader { proxy in
                Color.clear
                    .preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .global).minY)
            }
            .frame(height: 0)

            if feedStore.posts.isEmpty {
                emptyFeedView
            } else {
                LazyVStack(spacing: 24) {
                    ForEach(feedStore.posts) { post in
                        SocialPostCard(
                            post: post,
                            commentText: binding(for: post),
                            onLike: { 
                                feedStore.toggleLike(for: post)
                                hapticFeedback(.light)
                            },
                            onSave: { 
                                feedStore.toggleSave(for: post)
                                hapticFeedback(.light)
                            },
                            onCopy: { copyToMyRecipes(post.recipe) },
                            onRate: { feedStore.setRating($0, for: post) },
                            onComment: { text in
                                feedStore.addComment(text, to: post, by: session.currentUser?.name ?? "Guest")
                                commentDrafts[post.id] = ""
                                notificationHaptic(.success)
                            },
                            onShare: { 
                                feedStore.incrementShare(for: post)
                                shareRecipe(post.recipe)
                                notificationHaptic(.success)
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 100) // Add bottom padding for nav bar
            }
        }
        .refreshable {
            await refreshFeed()
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Feed")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { showAddPost = true } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundStyle(Theme.olive)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    MessagesView()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.olive)
                }
            }
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { bottomBar.handleScroll(offset: $0) }
        .sheet(isPresented: $showAddPost) {
            AddSocialPostView { post in
                var updated = post
                updated.recipe.assignAuthor(email: session.currentUser?.email, name: session.currentUser?.name)
                feedStore.append(updated)
            }
            .environmentObject(store)
            .environmentObject(session)
        }
        .onAppear { bottomBar.reset() }
    }

    private func binding(for post: SocialPost) -> Binding<String> {
        Binding {
            commentDrafts[post.id] ?? ""
        } set: { newValue in
            commentDrafts[post.id] = newValue
        }
    }

    private func copyToMyRecipes(_ recipe: Recipe) {
        Task {
            var duplicate = recipe
            duplicate.regenerateIdentity()
            duplicate.assignAuthor(email: session.currentUser?.email, name: session.currentUser?.name)
            await store.add(duplicate, regenerateIdentity: false, userId: session.currentUser?.id)
        }
    }
    
    private func shareRecipe(_ recipe: Recipe) {
        let text = "Check out this recipe: \(recipe.title) on Sarap.io!"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
    
    private var emptyFeedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 64))
                .foregroundStyle(Theme.subtext.opacity(0.5))
            Text("No posts yet")
                .font(.headline)
                .foregroundStyle(Theme.text)
            Text("Be the first to share a recipe with the community!")
                .font(.footnote)
                .foregroundStyle(Theme.subtext)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showAddPost = true
            } label: {
                Label("Create Post", systemImage: "plus.circle.fill")
                    .font(.subheadline)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Theme.olive))
                    .foregroundStyle(.white)
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
    
    private func refreshFeed() async {
        try? await Task.sleep(nanoseconds: 500_000_000) // Simulate refresh
    }
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
    
    private func notificationHaptic(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
}

private struct SocialPostCard: View {
    var post: SocialPost
    @Binding var commentText: String
    var onLike: () -> Void
    var onSave: () -> Void
    var onCopy: () -> Void
    var onRate: (Int) -> Void
    var onComment: (String) -> Void
    var onShare: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            media
            actions
            likesAndCaption
            commentsPreview
            rateAndCopy
            commentComposer
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 22).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 5)
    }

    private var header: some View {
        HStack(spacing: 12) {
            // User avatar - using placeholder for now since we don't have user avatar URLs in posts
            Circle()
                .fill(Theme.oliveSoft)
                .frame(width: 44, height: 44)
                .overlay(Text(String(post.user.prefix(1)).uppercased()).font(.headline))
            VStack(alignment: .leading, spacing: 2) {
                Text("@\(post.user)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(post.formattedDate)
                    .font(.caption2)
                    .foregroundStyle(Theme.subtext)
            }
            Spacer()
            Button { onShare() } label: {
                Image(systemName: "square.and.arrow.up")
                    .foregroundStyle(Theme.subtext)
            }
        }
    }

    @ViewBuilder
    private var media: some View {
        post.recipe.recipeImage()
            .scaledToFill()
            .frame(maxHeight: 260)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .clipped()
    }

    private var actions: some View {
        HStack(spacing: 24) {
            Button(action: onLike) {
                Image(systemName: post.isLiked ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundStyle(post.isLiked ? .red : Theme.subtext)
            }
            Button(action: { }) {
                Image(systemName: "bubble.right")
                    .font(.title3)
                    .foregroundStyle(Theme.subtext)
            }
            Button(action: onShare) {
                Image(systemName: "paperplane")
                    .font(.title3)
                    .foregroundStyle(Theme.subtext)
            }
            Spacer()
            Button(action: onSave) {
                Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                    .font(.title3)
                    .foregroundStyle(post.isSaved ? Theme.olive : Theme.subtext)
            }
        }
    }

    private var likesAndCaption: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(post.likes) likes")
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(post.caption)
                .font(.body)
        }
    }

    private var commentsPreview: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(post.comments.prefix(2)) { comment in
                HStack(alignment: .top, spacing: 6) {
                    Text("💬")
                    VStack(alignment: .leading, spacing: 2) {
                        Text("@\(comment.user)")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(Theme.olive)
                        Text(comment.text)
                            .font(.footnote)
                            .foregroundStyle(Theme.subtext)
                    }
                }
            }
            if post.comments.count > 2 {
                Text("View all \(post.comments.count) comments")
                    .font(.caption2)
                    .foregroundStyle(Theme.olive)
                    .padding(.top, 2)
            }
        }
    }

    private var rateAndCopy: some View {
        VStack(alignment: .leading, spacing: 12) {
            RatingControl(currentRating: post.rating, userRating: post.userRating, onSelect: onRate)
            HStack {
                Button(action: onCopy) {
                    Label("Copy to My Recipes", systemImage: "tray.and.arrow.down")
                }
                Spacer()
                Button(action: onShare) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .tint(Theme.olive)
            }
            .font(.footnote)
            .foregroundStyle(Theme.olive)
        }
    }

    private var commentComposer: some View {
        HStack(spacing: 12) {
            TextField("Add a comment…", text: $commentText)
                .textFieldStyle(.roundedBorder)
            Button {
                let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                onComment(trimmed)
            } label: {
                Text("Send")
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Theme.olive))
                    .foregroundStyle(.white)
            }
        }
    }
}

private struct RatingControl: View {
    var currentRating: Int
    var userRating: Int
    var onSelect: (Int) -> Void

    var body: some View {
        HStack(spacing: 6) {
            Text("Rate this recipe:")
                .font(.footnote)
                .foregroundStyle(Theme.subtext)
            ForEach(1...5, id: \.self) { star in
                let isFilled = star <= (userRating == 0 ? currentRating : userRating)
                Image(systemName: isFilled ? "star.fill" : "star")
                    .foregroundStyle(isFilled ? Theme.olive : Theme.subtext)
                    .onTapGesture { onSelect(star) }
            }
        }
    }
}
