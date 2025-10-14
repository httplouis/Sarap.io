import SwiftUI
import UIKit

struct AddSocialPostView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var auth: AuthManager

    @State private var caption: String = ""
    @State private var selectedRecipe: Recipe? = nil

    var onSave: (SocialPost) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Profile header row
                HStack(spacing: 12) {
                    avatarView
                        .frame(width: 44, height: 44)
                    VStack(alignment: .leading) {
                        Text("@\(auth.currentUser?.email.components(separatedBy: "@").first ?? "sarapio")")
                            .font(.headline)
                        Text("What's cooking today?")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                // Caption input
                TextEditor(text: $caption)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Theme.card))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
                    .padding(.horizontal)

                // Recipe selector
                VStack(alignment: .leading, spacing: 8) {
                    Text("Attach a Recipe (optional)")
                        .font(.subheadline)
                        .foregroundStyle(Theme.subtext)

                    Picker("Select a recipe", selection: $selectedRecipe) {
                        Text("None").tag(nil as Recipe?)
                        ForEach(store.recipes, id: \.id) { recipe in
                            Text(recipe.title).tag(recipe as Recipe?)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding(.horizontal)
                }

                Spacer()
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        let newPost = SocialPost(
                            id: UUID(),
                            user: auth.currentUser?.name ?? "sarapio",
                            avatar: auth.currentUser?.avatar?.imageName,
                            caption: caption,
                            recipe: selectedRecipe ?? SampleData.recipes[0],
                            likes: 0,
                            comments: [],
                            rating: 0,
                            isLiked: false
                        )
                        onSave(newPost)
                        dismiss()
                    }
                    .disabled(caption.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

private extension AddSocialPostView {
    var avatarView: some View {
        Group {
            if let avatar = auth.currentUser?.avatar,
               let imageName = avatar.imageName,
               let image = UIImage(named: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Theme.olive)
                    .overlay(Text(initials(from: auth.currentUser?.name ?? ""))
                        .foregroundStyle(.white))
            }
        }
    }

    func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        guard let first = parts.first else { return "SJ" }
        if parts.count > 1 {
            return String(first.prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(first.prefix(2)).uppercased()
    }
}
