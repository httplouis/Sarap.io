import SwiftUI
import PhotosUI

struct AddRecipeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: RecipeStore

    // If editing, we receive an existing recipe
    var editing: Recipe? = nil

    // basic fields
    @State private var title = ""
    @State private var minutes: Int = 30
    @State private var servings: Int = 2
    @State private var cuisine = ""
    @State private var region = ""

    // ingredients
    @State private var ingName = ""
    @State private var ingQty = ""
    @State private var ingredients: [Ingredient] = []

    // steps
    @State private var stepText = ""
    @State private var steps: [StepItem] = []

    // image
    @State private var pickerItem: PhotosPickerItem?
    @State private var imageData: Data?

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !ingredients.isEmpty && !steps.isEmpty
    }

    var body: some View {
        List {
            // Image picker + preview
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    if let data = imageData, let ui = UIImage(data: data) {
                        Image(uiImage: ui)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 170)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Theme.card)
                            .frame(height: 120)
                            .overlay(
                                VStack(spacing: 6) {
                                    Image(systemName: "photo.on.rectangle").font(.title2)
                                    Text("Add a dish photo").font(.footnote).foregroundStyle(Theme.subtext)
                                }
                            )
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
                    }
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label("Choose from Library", systemImage: "photo")
                    }
                }
            }

            Section("Basic Info") {
                TextField("Title", text: $title)
                Stepper(value: $minutes, in: 1...240) { Text("Prep/Cook: \(minutes) min") }
                Stepper(value: $servings, in: 1...12) { Text("Servings: \(servings)") }
                TextField("Cuisine (e.g., Filipino)", text: $cuisine)
                TextField("Region/City (e.g., Lucena)", text: $region)
            }

            Section("Ingredients") {
                HStack {
                    TextField("Ingredient", text: $ingName)
                    TextField("Qty", text: $ingQty).frame(width: 100)
                    Button { addIngredient() } label: { Image(systemName: "plus.circle.fill") }
                        .disabled(ingName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                if ingredients.isEmpty { Text("Add at least one ingredient").foregroundStyle(Theme.subtext) }
                ForEach(ingredients) { ing in
                    HStack { Text(ing.name); Spacer(); Text(ing.qty).foregroundStyle(Theme.subtext) }
                }
                .onDelete { idx in ingredients.remove(atOffsets: idx) }
            }

            Section("Steps") {
                HStack(alignment: .firstTextBaseline) {
                    TextField("Step instruction", text: $stepText, axis: .vertical)
                    Button { addStep() } label: { Image(systemName: "plus.circle.fill") }
                        .disabled(stepText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                if steps.isEmpty { Text("Add at least one step").foregroundStyle(Theme.subtext) }
                ForEach(steps.sorted(by: { $0.order < $1.order })) { st in
                    HStack {
                        Text("\(st.order).").monospacedDigit().foregroundStyle(Theme.subtext)
                        Text(st.text)
                    }
                }
                .onDelete(perform: deleteStep)
            }

            Section {
                Button(action: save) {
                    Text(editing == nil ? "Save Recipe" : "Update Recipe")
                        .font(Theme.titleM())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.olive))
                        .foregroundStyle(.white)
                }
                .disabled(!canSave)
                .listRowInsets(EdgeInsets())
                .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Theme.bg)
        .navigationTitle(editing == nil ? "Add Recipe" : "Edit Recipe")
        .onChange(of: pickerItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    imageData = data
                }
            }
        }
        .onAppear(perform: loadIfEditing)
    }

    // MARK: - Actions
    private func loadIfEditing() {
        guard let r = editing, title.isEmpty else { return }
        // prefill fields
        title = r.title
        minutes = r.minutes
        servings = r.servings
        cuisine = r.cuisine ?? ""
        region  = r.region ?? ""
        ingredients = r.ingredients
        steps = r.steps
        imageData = r.imageData
    }

    private func addIngredient() {
        let name = ingName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty else { return }
        ingredients.append(Ingredient(name, qty: ingQty.trimmingCharacters(in: .whitespacesAndNewlines)))
        ingName = ""; ingQty = ""
    }

    private func addStep() {
        let text = stepText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let order = (steps.map { $0.order }.max() ?? 0) + 1
        steps.append(StepItem(order, text))
        stepText = ""
    }

    private func deleteStep(at offsets: IndexSet) {
        var new = steps.sorted(by: { $0.order < $1.order })
        new.remove(atOffsets: offsets)
        for i in new.indices { new[i].order = i + 1 }
        steps = new
    }

    private func save() {
        var r = editing ?? Recipe(title: title, minutes: minutes, servings: servings)
        r.title = title
        r.minutes = minutes
        r.servings = servings
        r.cuisine = cuisine.isEmpty ? nil : cuisine
        r.region  = region.isEmpty ? nil : region
        r.ingredients = ingredients
        r.steps = steps
        r.imageData = imageData

        if editing == nil {
            store.add(r)
        } else {
            store.update(r)
        }
        dismiss()
    }
}
