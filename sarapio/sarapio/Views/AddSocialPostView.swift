import SwiftUI

struct AddSocialPostView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: RecipeStore
    
    // simulate current logged-in user (replace with real auth later)
    let currentUser = "moris123"

    @State private var caption: String = ""
    @State private var selectedRecipe: Recipe? = nil

    var onSave: (SocialPost) -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Profile header row
                HStack(spacing: 12) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .foregroundStyle(Theme.olive)
                    VStack(alignment: .leading) {
                        Text("@\(currentUser)")
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
                            user: currentUser,
                            avatar: "person.circle.fill",
                            caption: caption,
                            recipe: selectedRecipe ?? SampleData.recipes[0],
                            likes: 0,
                            comments: [],
                            rating: 0
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
