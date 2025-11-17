import SwiftUI
import UIKit

struct SocialFeedView: View {
    @EnvironmentObject private var feedStore: SocialFeedStore
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var bottomBar: BottomBarState

    @State private var commentDrafts: [UUID: String] = [:]
    @State private var showMessages = false
    @State private var showAddPost = false

    var body: some View {
        NavigationStack {
            ScrollView {
                GeometryReader { proxy in
                    Color.clear
                        .preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .global).minY)
                }
                .frame(height: 0)

                if feedStore.isLoading && feedStore.posts.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(Theme.olive)
                        Text("Loading feed...")
                            .font(.footnote)
                            .foregroundStyle(Theme.subtext)
                            .padding(.top)
                        Spacer()
                    }
                } else if feedStore.posts.isEmpty {
                    EmptyStateView(
                        icon: "sparkles",
                        "No Posts Yet",
                        message: "Be the first to share a recipe! Your community is waiting.",
                        actionTitle: "Create Post",
                        action: {
                            showAddPost = true
                            HapticManager.shared.medium()
                        }
                    )
                    .padding(.top, 60)
                } else {
                    LazyVStack(spacing: 24) {
                        ForEach(feedStore.posts) { post in
                            SocialPostCard(
                                post: post,
                                commentText: binding(for: post),
                                onLike: {
                                    HapticManager.shared.selection()
                                    Task { await feedStore.toggleLike(for: post) }
                                },
                                onSave: { feedStore.toggleSave(for: post) },
                                onCopy: {
                                    HapticManager.shared.success()
                                    copyToMyRecipes(post.recipe)
                                },
                                onRate: { rating in
                                    Task { await feedStore.setRating(rating, for: post) }
                                },
                                onComment: { text in
                                    Task {
                                        await feedStore.addComment(text, to: post)
                                        await MainActor.run {
                                            commentDrafts[post.id] = ""
                                        }
                                    }
                                },
                                onShare: {
                                    HapticManager.shared.medium()
                                    sharePost(post)
                                }
                            )
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 100) // Extra padding for bottom bar
                }
            }
            .background(Theme.bg)
            .navigationTitle("Feed")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Theme.bg, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { showAddPost = true } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundStyle(Theme.olive)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showMessages = true } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                            .foregroundStyle(Theme.olive)
                    }
                }
            }
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { bottomBar.handleScroll(offset: $0) }
            .sheet(isPresented: $showMessages) { NavigationStack { MessagesView() } }
            .sheet(isPresented: $showAddPost) {
                AddSocialPostView { post in
                    Task {
                        var updated = post
                        updated.recipe.assignAuthor(email: session.currentUser?.email, name: session.currentUser?.name)
                        await feedStore.append(updated)
                    }
                }
                .environmentObject(store)
                .environmentObject(session)
            }
            .onAppear {
                bottomBar.reset()
                Task {
                    await feedStore.loadPosts()
                }
            }
            .refreshable {
                await feedStore.loadPosts()
            }
        }
        .safeAreaInset(edge: .top) { Color.clear.frame(height: 0) }
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
            duplicate.user_id = session.currentUser?.id
            await store.add(duplicate, regenerateIdentity: true)
            HapticManager.shared.success()
        }
    }
    
    private func sharePost(_ post: SocialPost) {
        let text = "Check out this recipe: \(post.recipe.title) by \(post.user)\n\(post.caption)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

// MARK: - Social Post Card
struct SocialPostCard: View {
    var post: SocialPost
    @Binding var commentText: String
    var onLike: () -> Void
    var onSave: () -> Void
    var onCopy: () -> Void
    var onRate: (Int) -> Void
    var onComment: (String) -> Void
    var onShare: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)
            
            media
            
            VStack(alignment: .leading, spacing: 18) {
                actions
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                
                likesAndCaption
                    .padding(.horizontal, 20)
                
                if !post.comments.isEmpty {
                    commentsPreview
                        .padding(.horizontal, 20)
                }
                
                rateAndCopy
                    .padding(.horizontal, 20)
                
                Divider()
                    .padding(.horizontal, 20)
                
                commentComposer
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Theme.card)
                .shadow(color: .black.opacity(0.1), radius: 16, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Theme.border, Theme.border.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }

    private var header: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.oliveSoft, Theme.oliveSoft.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                Text(String(post.user.prefix(1)).uppercased())
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.olive)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("@\(post.user)")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.text)
                Text("Posted 2h ago")
                    .font(.caption)
                    .foregroundStyle(Theme.subtext)
            }
            
            Spacer()
            
            Button {
                HapticManager.shared.light()
                onShare()
            } label: {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Theme.subtext)
                    .frame(width: 36, height: 36)
                    .background(
                        Circle()
                            .fill(Theme.oliveSoft.opacity(0.3))
                    )
            }
        }
    }

    @ViewBuilder
    private var media: some View {
        AsyncRecipeImage(recipe: post.recipe)
            .scaledToFill()
            .frame(height: 300)
            .clipped()
    }

    private var actions: some View {
        HStack(spacing: 20) {
            Button {
                HapticManager.shared.selection()
                onLike()
            } label: {
                Image(systemName: post.isLiked ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundStyle(post.isLiked ? .red : Theme.subtext)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(post.isLiked ? Color.red.opacity(0.1) : Theme.oliveSoft.opacity(0.2))
                    )
            }
            
            Button {
                HapticManager.shared.light()
            } label: {
                Image(systemName: "bubble.right")
                    .font(.title3)
                    .foregroundStyle(Theme.subtext)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Theme.oliveSoft.opacity(0.2))
                    )
            }
            
            Button {
                HapticManager.shared.light()
                onShare()
            } label: {
                Image(systemName: "paperplane")
                    .font(.title3)
                    .foregroundStyle(Theme.subtext)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Theme.oliveSoft.opacity(0.2))
                    )
            }
            
            Spacer()
            
            Button {
                HapticManager.shared.selection()
                onSave()
            } label: {
                Image(systemName: post.isSaved ? "bookmark.fill" : "bookmark")
                    .font(.title3)
                    .foregroundStyle(post.isSaved ? Theme.olive : Theme.subtext)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(post.isSaved ? Theme.oliveSoft.opacity(0.4) : Theme.oliveSoft.opacity(0.2))
                    )
            }
        }
    }

    private var likesAndCaption: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(post.likes) likes")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.text)
            Text(post.caption)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .foregroundStyle(Theme.text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var commentsPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(post.comments.prefix(2), id: \.self) { comment in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "bubble.left.fill")
                        .font(.caption)
                        .foregroundStyle(Theme.olive.opacity(0.6))
                    Text(comment)
                        .font(.subheadline)
                        .foregroundStyle(Theme.text)
                }
            }
        }
    }

    private var rateAndCopy: some View {
        VStack(alignment: .leading, spacing: 16) {
            RatingControl(currentRating: post.rating, userRating: post.userRating, onSelect: onRate)
            
            HStack(spacing: 12) {
                Button {
                    HapticManager.shared.success()
                    onCopy()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "tray.and.arrow.down")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Copy Recipe")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(Theme.olive)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Theme.oliveSoft.opacity(0.3))
                    )
                }
                
                Button {
                    HapticManager.shared.light()
                    onShare()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 14, weight: .semibold))
                        Text("Share")
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Theme.olive, Theme.oliveDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
            }
        }
    }

    private var commentComposer: some View {
        HStack(spacing: 12) {
            TextField("Add a comment…", text: $commentText)
                .textInputAutocapitalization(.sentences)
                .font(.system(size: 15, weight: .regular, design: .rounded))
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Theme.oliveSoft.opacity(0.2))
                )
            
            Button {
                let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }
                HapticManager.shared.success()
                onComment(trimmed)
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Theme.olive)
            }
            .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }
}

// MARK: - Rating Control
struct RatingControl: View {
    var currentRating: Int
    var userRating: Int
    var onSelect: (Int) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Rate this recipe")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.text)
            
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { star in
                    let isFilled = star <= (userRating == 0 ? currentRating : userRating)
                    Button {
                        HapticManager.shared.selection()
                        onSelect(star)
                    } label: {
                        Image(systemName: isFilled ? "star.fill" : "star")
                            .font(.title3)
                            .foregroundStyle(
                                isFilled ?
                                LinearGradient(
                                    colors: [Color.yellow, Color.orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) :
                                LinearGradient(
                                    colors: [Theme.subtext, Theme.subtext],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                
                Spacer()
                
                if currentRating > 0 {
                    Text("\(String(format: "%.1f", Double(currentRating)))")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.olive)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Theme.oliveSoft.opacity(0.4))
                        )
                }
            }
        }
    }
}
