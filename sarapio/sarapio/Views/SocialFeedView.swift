import SwiftUI

struct SocialFeedView: View {
    @EnvironmentObject private var store: RecipeStore
    @State private var posts: [SocialPost] = SocialSampleData.posts
    @State private var showAddPost = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach($posts) { $post in
                        SocialPostCard(post: $post)
                    }
                }
                .padding()
            }
            .background(Theme.bg)
            .navigationTitle("Feed")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddPost = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddPost) {
                AddSocialPostView { newPost in
                    posts.insert(newPost, at: 0) // add sa taas ng feed
                }
            }
        }
    }
}

struct SocialPostCard: View {
    @Binding var post: SocialPost
    @EnvironmentObject private var store: RecipeStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Profile row
            HStack(spacing: 10) {
                if let avatar = post.avatar,
                   let uiImage = UIImage(named: avatar) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 36, height: 36)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 36, height: 36)
                        .foregroundStyle(Theme.olive)
                }
                Text("@\(post.user)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.text)
                Spacer()
            }

            // Recipe image
            if let imgName = post.recipe.imageName {
                Image(imgName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else if let data = post.recipe.imageData,
                      let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            // Caption
            Text(post.caption)
                .font(.body)
                .foregroundStyle(Theme.text)

            // Stats row
            HStack(spacing: 12) {
                Label("\(post.likes)", systemImage: "heart.fill")
                    .foregroundStyle(.pink)
                Label("\(post.rating)/5", systemImage: "star.fill")
                    .foregroundStyle(.yellow)
            }
            .font(.footnote)

            // Action row
            HStack(spacing: 20) {
                Button { post.likes += 1 } label: {
                    Label("Like", systemImage: "heart")
                }
                Button { } label: {
                    Label("Comment", systemImage: "bubble.right")
                }
                Button { } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                Button { } label: {
                    Label("Message", systemImage: "paperplane")
                }
            }
            .font(.footnote)
            .foregroundStyle(Theme.subtext)

            Divider()

            // Comments preview
            VStack(alignment: .leading, spacing: 6) {
                ForEach(post.comments.prefix(2), id: \.self) { c in
                    Text("💬 \(c)")
                        .font(.footnote)
                        .foregroundStyle(Theme.subtext)
                }
            }

            // Extra actions
            HStack {
                Button {
                    store.add(post.recipe) // copy to personal recipes
                } label: {
                    Label("Copy to My Recipes", systemImage: "tray.and.arrow.down")
                }

                Spacer()

                Button { } label: {
                    Label("Rate", systemImage: "star")
                }
            }
            .font(.footnote)
            .foregroundStyle(Theme.olive)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
    }
}
