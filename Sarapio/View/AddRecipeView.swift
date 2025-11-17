import SwiftUI
import PhotosUI
import UIKit

struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager

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
    @State private var showValidationError = false
    @State private var validationMessage = ""
    @State private var showError = false
    @State private var errorMessage = ""

    private var existingImageData: Data? { editing?.imageData }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        ingredients.contains { !$0.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    init(editing: Recipe? = nil) {
        self.editing = editing
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Photo Picker
                PhotoSection(
                    pickerItem: $pickerItem,
                    previewImage: { AnyView(previewImage) }
                )

                // MARK: - Basic Info
                BasicInfoSection(
                    title: $title,
                    minutes: $minutes,
                    servings: $servings,
                    cuisine: $cuisine,
                    region: $region
                )

                // MARK: - Ingredients
                IngredientsSection(ingredients: $ingredients)

                // MARK: - Steps
                StepsSection(
                    steps: $steps,
                    reindexSteps: reindexSteps
                )

                // MARK: - Save Button
                SaveSection(
                    editing: editing,
                    isDisabled: !isFormValid || isSaving,
                    saveAction: save
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(Theme.bg.ignoresSafeArea())
        .tint(Theme.olive)
        .navigationTitle(editing == nil ? "Add Recipe" : "Edit Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadEditingIfAny)
        .onChange(of: pickerItem) {
            Task { await loadPickedImage(from: pickerItem) }
        }
        .alert("Validation", isPresented: $showValidationError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(validationMessage)
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .onChange(of: store.errorMessage) { oldValue, newValue in
            if let error = newValue {
                errorMessage = error
                showError = true
            }
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

    // MARK: - Save
    @State private var isSaving = false
    
    private func save() {
        guard isFormValid else {
            HapticManager.shared.warning()
            validationMessage = "Please add a title and at least one ingredient."
            showValidationError = true
            return
        }
        
        HapticManager.shared.medium()

        Task {
            isSaving = true
            defer { isSaving = false }
            
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
                user_id: session.currentUser?.id,
                authorEmail: nil,
                authorName: nil,
                photo_url: nil,
                imageData: pickedImageData ?? editing?.imageData,
                assetName: nil,
                imageName: nil,
                created_at: nil
            )

            newRecipe.assignAuthor(email: session.currentUser?.email, name: session.currentUser?.name)

            // Upload image if available
            if let imageData = pickedImageData ?? editing?.imageData {
                do {
                    let photoUrl = try await store.uploadImage(imageData, recipeId: newRecipe.id)
                    newRecipe.photo_url = photoUrl
                } catch {
                    print("⚠️ Image upload failed, continuing without image:", error)
                }
            }

            do {
                if let old = editing {
                    newRecipe.id = old.id
                    await store.update(old, with: newRecipe)
                } else {
                    await store.add(newRecipe, regenerateIdentity: true)
                }
                
                HapticManager.shared.success()
                await MainActor.run {
                    dismiss()
                }
            } catch {
                HapticManager.shared.error()
                await MainActor.run {
                    errorMessage = "Failed to save recipe: \(error.localizedDescription)"
                    showError = true
                }
            }
        }
    }
}
