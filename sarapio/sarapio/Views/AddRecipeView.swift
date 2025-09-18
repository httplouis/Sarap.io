// File: Views/AddRecipeView.swift
import SwiftUI
import PhotosUI
import UIKit

struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: RecipeStore

    var editing: Recipe?

    // MARK: - Form fields
    @State private var title: String = ""
    @State private var minutes: String = ""
    @State private var servings: String = ""
    @State private var cuisine: String = ""
    @State private var region: String = ""

    // Editable rows
    @State private var ingredients: [Ingredient] = []
    @State private var steps: [StepItem] = []

    // MARK: - Image picking
    @State private var pickerItem: PhotosPickerItem?
    @State private var pickedImageData: Data?
    @State private var pickedUIImage: UIImage?

    private var existingImageData: Data? { editing?.imageData }

    init(editing: Recipe? = nil) {
        self.editing = editing
    }

    var body: some View {
        Form {
            // PHOTO
            Section("PHOTO") {
                HStack(spacing: 16) {
                    previewImage
                        .frame(width: 84, height: 84)
                        .background(Theme.card)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))

                    PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                        Label("Choose Photo", systemImage: "photo.on.rectangle")
                            .font(.body)
                            .foregroundStyle(Theme.olive)
                    }
                }
                .listRowBackground(Theme.card)
            }

            // BASIC
            Section("BASIC") {
                TextField("Title", text: $title)

                HStack {
                    TextField("", text: $minutes)
                        .keyboardType(.numberPad)
                        .placeholder(when: minutes.isEmpty) {
                            Text("Minutes").foregroundColor(.gray)
                        }

                    TextField("", text: $servings)
                        .keyboardType(.numberPad)
                        .placeholder(when: servings.isEmpty) {
                            Text("Servings").foregroundColor(.gray)
                        }
                }

                TextField("Cuisine (optional)", text: $cuisine)
                TextField("Region (optional)", text: $region)
            }
            .listRowBackground(Theme.card)

            // INGREDIENTS
            Section("INGREDIENTS") {
                ForEach($ingredients) { $ing in
                    HStack {
                        TextField("", text: $ing.name)
                            .placeholder(when: ing.name.isEmpty) {
                                Text("Ingredient").foregroundColor(.gray)
                            }
                        TextField("", text: $ing.amount)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(Theme.subtext)
                            .placeholder(when: ing.amount.isEmpty) {
                                Text("Amount").foregroundColor(.gray)
                            }
                        TextField("", text: $ing.unit)
                            .multilineTextAlignment(.trailing)
                            .foregroundStyle(Theme.subtext)
                            .placeholder(when: ing.unit.isEmpty) {
                                Text("Unit").foregroundColor(.gray)
                            }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            if let idx = ingredients.firstIndex(where: { $0.id == ing.id }) {
                                ingredients.remove(at: idx)
                            }
                        } label: { Label("Delete", systemImage: "trash") }
                    }
                }
                .onDelete { indices in
                    ingredients.remove(atOffsets: indices)
                }

                Button {
                    ingredients.append(Ingredient("New Ingredient"))
                } label: {
                    Label("Add Ingredient", systemImage: "plus")
                }
            }
            .listRowBackground(Theme.card)

            // STEPS
            Section("STEPS") {
                ForEach($steps) { $st in
                    HStack(alignment: .firstTextBaseline) {
                        Text("\(st.order).")
                            .monospacedDigit()
                            .foregroundStyle(Theme.subtext)

                        TextField("", text: $st.text)
                            .placeholder(when: st.text.isEmpty) {
                                Text("Step description").foregroundColor(.gray)
                            }
                    }
                    .swipeActions {
                        Button(role: .destructive) {
                            if let idx = steps.firstIndex(where: { $0.id == st.id }) {
                                steps.remove(at: idx)
                                reindexSteps()
                            }
                        } label: { Label("Delete", systemImage: "trash") }
                    }
                }
                .onDelete {
                    steps.remove(atOffsets: $0)
                    reindexSteps()
                }

                Button {
                    steps.append(StepItem(order: (steps.last?.order ?? 0) + 1, text: ""))
                } label: {
                    Label("Add Step", systemImage: "plus")
                }
            }
            .listRowBackground(Theme.card)

            // SAVE
            Section {
                Button(action: save) {
                    Text(editing == nil ? "Save Recipe" : "Update Recipe")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.olive)
                .listRowBackground(Theme.card)
            }
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
        guard let r = editing else {
            if ingredients.isEmpty { ingredients = [] }
            if steps.isEmpty { steps = [] }
            return
        }
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
            imageData: nil,
            imageName: nil
        )

        if let data = pickedImageData {
            newRecipe.imageData = data
        } else if let existing = editing?.imageData {
            newRecipe.imageData = existing
        }

        if let old = editing {
            store.update(old, with: newRecipe)
        } else {
            store.add(newRecipe)
        }
        dismiss()
    }
}
