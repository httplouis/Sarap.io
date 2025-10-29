import SwiftUI

struct AddSocialPostView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager

    @State private var caption: String = ""
    @State private var selectedRecipe: Recipe?

    var onSave: (SocialPost) -> Void
    var onDismiss: (() -> Void)? = nil

    private var currentUserHandle: String {
        if let email = session.currentUser?.email,
           let handle = email.split(separator: "@").first {
            return "@" + handle.lowercased()
        }
        return "@guest"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Theme.oliveSoft)
                            .frame(width: 54, height: 54)
                            .overlay(Image(systemName: "person.fill").foregroundStyle(Theme.olive))
                        VStack(alignment: .leading) {
                            Text(session.currentUser?.name ?? "Guest Cook")
                                .font(.headline)
                            Text(currentUserHandle)
                                .font(.subheadline)
                                .foregroundStyle(Theme.subtext)
                        }
                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Caption")
                            .font(.subheadline)
                            .foregroundStyle(Theme.subtext)
                        TextEditor(text: $caption)
                            .frame(minHeight: 140)
                            .padding(12)
                            .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Attach a Recipe")
                            .font(.subheadline)
                            .foregroundStyle(Theme.subtext)
                        Menu {
                            Button("No recipe") { selectedRecipe = nil }
                            ForEach(store.recipes(for: session.currentUser)) { recipe in
                                Button(recipe.title) { selectedRecipe = recipe }
                            }
                        } label: {
                            HStack {
                                Text(selectedRecipe?.title ?? "Choose from your recipes")
                                    .foregroundStyle(Theme.text)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(Theme.subtext)
                            }
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                        }
                    }

                    Text("Comments and shares will be available after Finals once the realtime database is wired up.")
                        .font(.footnote)
                        .foregroundStyle(Theme.subtext)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.bg))
                }
                .padding(24)
            }
            .background(Theme.bg.ignoresSafeArea())
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                        onDismiss?()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Share") {
                        let recipe = selectedRecipe ?? SampleData.recipes.randomElement() ?? Recipe(title: "Untitled", minutes: 0, servings: 0, cuisine: nil, region: nil)
                        var authoredRecipe = recipe
                        authoredRecipe.assignAuthor(email: session.currentUser?.email, name: session.currentUser?.name)
                        let handle = session.currentUser?.email.split(separator: "@").first.map(String.init) ?? "guest"
                        var post = SocialPost(
                            id: UUID(),
                            user: handle,
                            avatar: nil,
                            caption: caption,
                            recipe: authoredRecipe,
                            likes: Int.random(in: 2...20),
                            comments: ["🔥 Can't wait to try this!"],
                            rating: 0
                        )
                        post.userRating = 0
                        onSave(post)
                        dismiss()
                        onDismiss?()
                    }
                    .disabled(caption.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
