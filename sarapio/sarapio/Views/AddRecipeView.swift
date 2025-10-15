import SwiftUI
import PhotosUI
import UIKit

struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var auth: AuthManager

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

    @State private var validationError: String?

    private let unitOptions = ["g", "ml", "pcs", "tbsp", "tsp", "cup"]

    private var existingImageData: Data? { editing?.imageData }

    init(editing: Recipe? = nil) {
        self.editing = editing
    }

    var body: some View {
        Form {
            if let validationError {
                Section {
                    Text(validationError)
                        .foregroundStyle(.red)
                        .font(.footnote)
                }
                .listRowBackground(Theme.card)
            }

            PhotoSection(
                pickerItem: $pickerItem,
                previewImage: { AnyView(previewImage) }
            )

            BasicInfoSection(
                title: $title,
                minutes: $minutes,
                servings: $servings,
                cuisine: $cuisine,
                region: $region
            )

            IngredientsSection(ingredients: $ingredients, unitOptions: unitOptions)

            StepsSection(
                steps: $steps,
                reindexSteps: reindexSteps
            )

            SaveSection(
                editing: editing,
                isValid: canSave,
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
        .onChange(of: title) { _ in validationError = nil }
        .onChange(of: ingredients) { _ in validationError = nil }
        .onChange(of: steps) { _ in validationError = nil }
    }

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

    private func reindexSteps() {
        for index in steps.indices { steps[index].order = index + 1 }
    }

    private func loadEditingIfAny() {
        guard let recipe = editing else { return }
        title = recipe.title
        minutes = String(recipe.minutes)
        servings = String(recipe.servings)
        cuisine = recipe.cuisine ?? ""
        region = recipe.region ?? ""
        ingredients = recipe.ingredients
        steps = recipe.steps.sorted { $0.order < $1.order }
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var cleanedIngredients: [Ingredient] {
        ingredients
            .map { Ingredient($0.name.trimmingCharacters(in: .whitespacesAndNewlines), amount: $0.amount.trimmingCharacters(in: .whitespacesAndNewlines), unit: $0.unit.trimmingCharacters(in: .whitespacesAndNewlines)) }
            .filter { !$0.name.isEmpty }
    }

    private var cleanedSteps: [StepItem] {
        steps
            .map { StepItem($0.order, $0.text.trimmingCharacters(in: .whitespacesAndNewlines)) }
            .filter { !$0.text.isEmpty }
            .sorted { $0.order < $1.order }
    }

    private var canSave: Bool {
        !trimmedTitle.isEmpty && !cleanedIngredients.isEmpty && !cleanedSteps.isEmpty
    }

    private func save() {
        guard canSave else {
            validationError = "Please add a title, at least one ingredient, and a cooking step."
            return
        }

        let mins = Int(minutes) ?? 0
        let serv = Int(servings) ?? 1

        let trimmedCuisine = cuisine.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedRegion = region.trimmingCharacters(in: .whitespacesAndNewlines)

        var newRecipe = Recipe(
            title: trimmedTitle,
            minutes: mins,
            servings: serv,
            cuisine: trimmedCuisine.isEmpty ? nil : trimmedCuisine,
            region: trimmedRegion.isEmpty ? nil : trimmedRegion,
            tags: [],
            ingredients: cleanedIngredients,
            steps: cleanedSteps,
            isFavorite: editing?.isFavorite ?? false,
            ownerId: editing?.ownerId ?? auth.currentUser?.id,
            imageData: pickedImageData ?? editing?.imageData,
            imageName: editing?.imageName
        )

        if let existing = editing {
            store.update(existing, with: newRecipe)
        } else {
            store.add(newRecipe, ownerId: auth.currentUser?.id)
        }
        auth.updateStats(recipesCount: store.recipes.filter { $0.ownerId == auth.currentUser?.id }.count)
        dismiss()
    }
}
