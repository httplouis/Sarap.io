import SwiftUI

struct AddSocialPostView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var user: String = "@you"
    @State private var caption: String = ""
    @State private var selectedRecipe: Recipe? = nil

    var onSave: (SocialPost) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section("User") {
                    TextField("Username", text: $user)
                }

                Section("Caption") {
                    TextField("Write something...", text: $caption, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }

                Section("Attach Recipe") {
                    Picker("Select a recipe", selection: $selectedRecipe) {
                        Text("None").tag(nil as Recipe?)
                        ForEach(SampleData.recipes, id: \.id) { r in
                            Text(r.title).tag(r as Recipe?)
                        }
                    }
                }
            }
            .navigationTitle("New Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        let newPost = SocialPost(
                            id: UUID(),
                            user: user,
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
                    .disabled(caption.isEmpty)
                }
            }
        }
    }
}
