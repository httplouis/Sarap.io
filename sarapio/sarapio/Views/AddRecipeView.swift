import SwiftUI
import PhotosUI
import UIKit

struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: RecipeStore

    var editing: Recipe?

    @State private var title: String = ""
    @State private var minutes: String = ""
    @State private var servings: String = ""
    @State private var cuisine: String = ""
    @State private var region: String = ""

    @State private var ingredients: [Ingredient] = []
    @State private var steps: [StepItem] = []

    @State private var pickerItem: PhotosPickerItem?
    @State private var pickedImageData: Data?
    @State private var pickedUIImage: UIImage?

    private var existingImageData: Data? { editing?.imageData }

    init(editing: Recipe? = nil) {
        self.editing = editing
    }

    var body: some View {
        Form {
            PhotoSection(
                pickerItem: $pickerItem,
                previewImage: { AnyView(previewImage) }   // closure returning AnyView
            )


            BasicInfoSection(
                title: $title,
                minutes: $minutes,
                servings: $servings,
                cuisine: $cuisine,
                region: $region
            )

            IngredientsSection(ingredients: $ingredients)

            StepsSection(
                steps: $steps,
                reindexSteps: reindexSteps
            )

            SaveSection(
                editing: editing,
                saveAction: save
            )
        }
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
        .tint(Theme.olive)
        .navigationTitle(editing == nil ? "Add Recipe" : "Edit Recipe")
        .toolbar { EditButton() }
        .onAppear(perform: loadEditingIfAny)
        .onChange(of: pickerItem) {
            Task { await loadPickedImage(from: pickerItem) }
        }
    }

    // MARK: - Preview image
    @ViewBuilder
    private var previewImage: some View {
        if let ui = pickedUIImage {
            Image(uiImage: ui).resizable().scaledToFill()
        } else if let data = existingImageData, let ui = UIImage(data: data) {
            Image(uiImage: ui).resizable().scaledToFill()
        } else {
            ZStack {
                Theme.card
                Image(systemName: "leaf")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(Theme.olive)
            }
        }
    }

    // MARK: - PhotosPicker loader
    private func loadPickedImage(from item: PhotosPickerItem?) async {
        guard let item else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self) {
                self.pickedImageData = data
                self.pickedUIImage = UIImage(data: data)
            }
        } catch {
            print("PhotosPicker load failed:", error.localizedDescription)
            self.pickedImageData = nil
            self.pickedUIImage = nil
        }
    }

    // MARK: - Helpers
    private func reindexSteps() {
        for i in 0..<steps.count { steps[i].order = i + 1 }
    }

    private func loadEditingIfAny() {
        guard let r = editing else { return }
        title = r.title
        minutes = String(r.minutes)
        servings = String(r.servings)
        cuisine = r.cuisine ?? ""
        region = r.region ?? ""
        ingredients = r.ingredients
        steps = r.steps
    }

    private func save() {
        let mins = Int(minutes) ?? 0
        let serv = Int(servings) ?? 1

        var newRecipe = Recipe(
            title: title.isEmpty ? "Untitled" : title,
            minutes: mins,
            servings: serv,
            cuisine: cuisine.isEmpty ? nil : cuisine,
            region: region.isEmpty ? nil : region,
            tags: [],
            ingredients: ingredients,
            steps: steps,
            isFavorite: editing?.isFavorite ?? false,
            imageData: pickedImageData ?? editing?.imageData,
            imageName: nil
        )

        if let old = editing {
            store.update(old, with: newRecipe)
        } else {
            store.add(newRecipe)
        }
        dismiss()
    }
}
