import SwiftUI

struct RecipeDetailView: View {
    @EnvironmentObject private var store: RecipeStore
    @State private var showImageFull = false
    @State private var showDeleteConfirm = false
    @State private var showEdit = false

    let recipe: Recipe

    var body: some View {
        List {
            headerImage

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
                        Text(ing.display) // ✅ now uses computed display
                        Spacer()
                    }
                }
            }

            Section("STEPS") {
                let sortedSteps = recipe.steps.sorted { $0.order < $1.order } // ✅ break into variable
                ForEach(sortedSteps) { st in
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(st.order).")
                            .monospacedDigit()
                            .foregroundStyle(Theme.subtext)
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
                Button { showEdit = true } label: {
                    Image(systemName: "square.and.pencil")
                }
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

    @ViewBuilder
    private var headerImage: some View {
        if let imgName = recipe.imageName {
            Image(imgName)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                .onTapGesture { showImageFull = true }
        } else {
            EmptyView()
        }
    }
}
