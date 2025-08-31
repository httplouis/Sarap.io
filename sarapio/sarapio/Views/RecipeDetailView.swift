import SwiftUI

struct RecipeDetailView: View {
    @EnvironmentObject private var store: RecipeStore
    @State private var showImageFull = false
    @State private var showDeleteConfirm = false
    @State private var showEdit = false

    let recipe: Recipe

    var body: some View {
        List {
            headerImage // always returns a View; empty case handled inside

            Section {
                HStack(spacing: 8) {
                    Tag(text: "\(recipe.minutes)m")
                    Tag(text: "Serves \(recipe.servings)")
                    if let c = recipe.cuisine { Tag(text: c) }
                }
                if let region = recipe.region, !region.isEmpty {
                    Text("Region: \(region)")
                        .font(.footnote)
                        .foregroundStyle(Theme.subtext)
                }
            }

            Section("INGREDIENTS") {
                ForEach(recipe.ingredients) { ing in
                    HStack {
                        Text(ing.name)
                        Spacer()
                        if !ing.qty.isEmpty { Text(ing.qty).foregroundStyle(Theme.subtext) }
                    }
                }
            }

            Section("STEPS") {
                ForEach(recipe.steps.sorted(by: { $0.order < $1.order })) { st in
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(st.order).").monospacedDigit().foregroundStyle(Theme.subtext)
                        Text(st.text)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button { showEdit = true } label: { Image(systemName: "square.and.pencil") }
                Button(role: .destructive) { showDeleteConfirm = true } label: {
                    Image(systemName: "trash")
                }

                Button { store.toggleFavorite(recipe) } label: {
                    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                }
            }
        }
        .confirmationDialog("Delete this recipe?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                store.delete(recipe)
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showEdit) {
            NavigationStack { AddRecipeView(editing: recipe) }
                .presentationDetents([.large])
        }
        .fullScreenCover(isPresented: $showImageFull) {
            // full screen photo supports both user photo and asset
            if let img = recipe.resolvedImage() {
                ZStack {
                    Color.black.ignoresSafeArea()
                    img.resizable()
                        .scaledToFit()
                        .onTapGesture { showImageFull = false }
                }
            }
        }
    }

    // MARK: - Header Image (handles both user image and asset)
    @ViewBuilder
    private var headerImage: some View {
        if let img = recipe.resolvedImage() {
            img.resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 4, trailing: 16))
                .onTapGesture { showImageFull = true }
        } else {
            EmptyView()
                .listRowInsets(EdgeInsets()) // keep spacing tidy when no image
        }
    }
}
