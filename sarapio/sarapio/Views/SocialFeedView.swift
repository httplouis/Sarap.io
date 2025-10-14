import SwiftUI

struct SocialFeedView: View {
    @EnvironmentObject private var store: RecipeStore
    @State private var posts: [SocialPost] = SocialSampleData.posts
    @State private var showMessages = false

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 22) {
                    ForEach($posts) { $post in
                        SocialPostCard(post: $post)
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
                        showMessages = true
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                            .foregroundStyle(Theme.olive)
                            .padding(.trailing, 6) // ✅ added breathing space from screen edge
                    }
                }
            }
            .sheet(isPresented: $showMessages) {
                MessagesView()
            }
        }
    }
}

struct SocialPostCard: View {
    @Binding var post: SocialPost
    @EnvironmentObject private var store: RecipeStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // --- Profile Row ---
            HStack(spacing: 10) {
                if let avatar = post.avatar, let uiImage = UIImage(named: avatar) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Theme.olive)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundStyle(.white)
                        )
                }

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

            // --- Recipe Image ---
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

            // --- Action Buttons Row ---
            HStack(spacing: 20) {
                Button { post.likes += 1 } label: {
                    Image(systemName: "heart")
                        .font(.title3)
                        .foregroundStyle(Theme.subtext)
                }
                Button { } label: {
                    Image(systemName: "bubble.right")
                        .font(.title3)
                        .foregroundStyle(Theme.subtext)
                }
                Button { } label: {
                    Image(systemName: "paperplane")
                        .font(.title3)
                        .foregroundStyle(Theme.subtext)
                }

                Spacer()

                Button { } label: {
                    Image(systemName: "bookmark")
                        .font(.title3)
                        .foregroundStyle(Theme.subtext)
                }
            }

            // --- Likes Count & Caption ---
            Text("\(post.likes) likes")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.text)
                .padding(.top, 4)

            Text(post.caption)
                .font(.body)
                .foregroundStyle(Theme.text)
                .padding(.bottom, 4)

            // --- Comments Preview ---
            if !post.comments.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(post.comments.prefix(2), id: \.self) { c in
                        Text("💬 \(c)")
                            .font(.footnote)
                            .foregroundStyle(Theme.subtext)
                    }
                }
                .padding(.top, 2)
            }

            // --- Copy & Rate ---
            Divider().padding(.vertical, 4)
            HStack {
                Button {
                    store.add(post.recipe)
                } label: {
                    Label("Copy Recipe", systemImage: "tray.and.arrow.down")
                        .labelStyle(.titleAndIcon)
                }

                Spacer()

                Button { } label: {
                    Label("Rate", systemImage: "star")
                        .labelStyle(.titleAndIcon)
                }
            }
            .font(.footnote)
            .foregroundStyle(Theme.olive)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
        .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
    }
}
