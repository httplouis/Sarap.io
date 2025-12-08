import SwiftUI
import AVFoundation

struct RecipeDetailView: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var shoppingList: ShoppingListStore
    @EnvironmentObject private var timerManager: RecipeTimerManager
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @State private var showImageFull = false
    @State private var showDeleteConfirm = false
    @State private var showEdit = false
    @State private var showShoppingList = false
    @StateObject private var narrator = RecipeNarrator()
    @State private var currentStepIndex = 0
    @State private var timerUpdateTimer: Timer?

    let recipe: Recipe

    var body: some View {
        List {
            headerImage
            recipeInfoSection
            ingredientsSection
            stepsSection
            tipsSection
            actionsSection
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
                Button { 
                    Task {
                        await store.toggleFavorite(recipe, userId: session.currentUser?.id)
                        hapticFeedback(.success)
                    }
                } label: {
                    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(recipe.isFavorite ? .pink : Theme.olive)
                }
            }
        }
        .onAppear {
            store.incrementViewCount(for: recipe)
            startTimerUpdates()
            narrator.settings = settings
        }
        .onDisappear {
            stopTimerUpdates()
            narrator.stop()
        }
        .confirmationDialog("Delete this recipe?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task {
                    await store.delete(recipe)
                    dismiss()   // ✅ balik agad sa home/list
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showEdit) {
            NavigationStack { AddRecipeView(editing: recipe) }
                .environmentObject(store)
                .environmentObject(session)
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
        .sheet(isPresented: $showShoppingList) {
            NavigationStack {
                ShoppingListView()
            }
        }
    }
    
    private func startTimerUpdates() {
        timerUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Force UI update for timers
        }
    }
    
    private func stopTimerUpdates() {
        timerUpdateTimer?.invalidate()
        timerUpdateTimer = nil
    }
    
    
    private var recipeInfoSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Tag(text: "\(recipe.totalTime)m", icon: "clock.fill")
                    Tag(text: "Serves \(recipe.servings)", icon: "person.2.fill")
                    if let c = recipe.cuisine { Tag(text: c, icon: "globe") }
                    DifficultyBadge(difficulty: recipe.difficulty)
                }
                
                if !recipe.description.isEmpty {
                    Text(recipe.description)
                        .font(.body)
                        .foregroundStyle(Theme.subtext)
                }
                
                HStack {
                    if let region = recipe.region, !region.isEmpty {
                        Label(region, systemImage: "mappin.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(Theme.subtext)
                    }
                    Spacer()
                    if recipe.viewCount > 0 {
                        Label("\(recipe.viewCount) views", systemImage: "eye.fill")
                            .font(.footnote)
                            .foregroundStyle(Theme.subtext)
                    }
                }
                
                if recipe.calories != nil || recipe.protein != nil {
                    NutritionInfoView(recipe: recipe)
                }
            }
        }
    }
    
    private var ingredientsSection: some View {
        Section("INGREDIENTS") {
            ForEach(recipe.ingredients) { ing in
                HStack {
                    Text(ing.display)
                    Spacer()
                    Button {
                        shoppingList.addIngredient(ing)
                        hapticFeedback(.success)
                    } label: {
                        Image(systemName: "cart.badge.plus")
                            .foregroundStyle(Theme.olive)
                    }
                }
            }
            
            Button {
                shoppingList.addIngredients(from: recipe)
                hapticFeedback(.success)
            } label: {
                Label("Add All to Shopping List", systemImage: "cart.fill")
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var stepsSection: some View {
        Section("STEPS") {
            ForEach(recipe.steps.sorted { $0.order < $1.order }) { step in
                StepRowView(step: step, recipeId: recipe.id, timerManager: timerManager)
            }
        }
    }
    
    @ViewBuilder
    private var tipsSection: some View {
        if !recipe.tips.isEmpty {
            Section("COOKING TIPS") {
                ForEach(recipe.tips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.yellow)
                        Text(tip)
                            .font(.footnote)
                    }
                }
            }
        }
    }
    
    private var actionsSection: some View {
        Section("ACTIONS") {
            Button {
                speakIngredients()
            } label: {
                Label("Speak Ingredients", systemImage: "speaker.wave.2.fill")
            }

            Button {
                startStepNarration()
            } label: {
                Label("Speak Steps", systemImage: "list.number")
            }

            Button {
                speakNextStep()
            } label: {
                Label("Next Step", systemImage: "arrowtriangle.forward.fill")
            }
            .disabled(recipe.steps.isEmpty)
        }
    }

    @ViewBuilder
    private var headerImage: some View {
        recipe.recipeImage()
            .scaledToFill()
            .frame(height: 250)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
            .onTapGesture { showImageFull = true }
    }

    private func speakIngredients() {
        narrator.stop() // Stop any ongoing speech
        let lines = recipe.ingredients.map { $0.display }.joined(separator: ". ")
        let fullText = "Ingredients for \(recipe.title): " + lines
        narrator.speakIngredients(fullText)
        hapticFeedback(.success)
    }

    private func startStepNarration() {
        narrator.stop() // Stop any ongoing speech
        currentStepIndex = 0
        guard !recipe.steps.isEmpty else { 
            narrator.speakSteps("No steps available for this recipe.")
            return 
        }
        let sorted = recipe.steps.sorted { $0.order < $1.order }
        let intro = "Let's cook \(recipe.title)."
        narrator.speakSteps(intro)
        
        // Wait a bit then speak first step
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.narrator.speakSteps("Step 1: " + sorted[0].text)
        }
        hapticFeedback(.success)
    }

    private func speakNextStep() {
        let sorted = recipe.steps.sorted { $0.order < $1.order }
        guard !sorted.isEmpty else { return }
        if currentStepIndex < sorted.count - 1 {
            currentStepIndex += 1
            let stepNumber = sorted[currentStepIndex].order
            narrator.speakSteps("Step \(stepNumber): " + sorted[currentStepIndex].text)
            hapticFeedback(.light)
        } else {
            narrator.speakSteps("That's the last step. Enjoy your meal!")
            hapticFeedback(.success)
        }
    }
    
    private func hapticFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Supporting Views

private struct DifficultyBadge: View {
    let difficulty: Recipe.Difficulty
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: difficulty.icon)
            Text(difficulty.rawValue)
        }
        .font(.caption)
        .fontWeight(.semibold)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 12).fill(difficulty.color.opacity(0.2)))
        .foregroundStyle(difficulty.color)
    }
}

private struct NutritionInfoView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Nutrition (per serving)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.subtext)
            
            HStack(spacing: 16) {
                if let calories = recipe.calories {
                    NutritionItem(label: "Calories", value: "\(calories)", icon: "flame.fill", color: .orange)
                }
                if let protein = recipe.protein {
                    NutritionItem(label: "Protein", value: String(format: "%.1fg", protein), icon: "dumbbell.fill", color: .blue)
                }
                if let carbs = recipe.carbs {
                    NutritionItem(label: "Carbs", value: String(format: "%.1fg", carbs), icon: "leaf.fill", color: .green)
                }
                if let fat = recipe.fat {
                    NutritionItem(label: "Fat", value: String(format: "%.1fg", fat), icon: "drop.fill", color: .purple)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

private struct NutritionItem: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Theme.subtext)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct StepRowView: View {
    let step: StepItem
    let recipeId: UUID
    @ObservedObject var timerManager: RecipeTimerManager
    @State private var showTimer = false
    
    private var activeTimer: RecipeTimerManager.RecipeTimer? {
        timerManager.activeTimers.first { $0.recipeId == recipeId && $0.stepOrder == step.order }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 12) {
                Text("\(step.order).")
                    .monospacedDigit()
                    .font(.headline)
                    .foregroundStyle(Theme.olive)
                Text(step.text)
                    .font(.body)
            }
            
            // Timer button
            if step.hasTimer, let minutes = step.timerMinutes {
                if let timer = activeTimer {
                    TimerControlView(timer: timer, timerManager: timerManager)
                } else {
                    Button {
                        _ = timerManager.startTimer(
                            name: "Step \(step.order)",
                            duration: TimeInterval(minutes * 60),
                            recipeId: recipeId,
                            stepOrder: step.order
                        )
                    } label: {
                        Label("Start \(minutes)m timer", systemImage: "timer")
                            .font(.caption)
                            .foregroundStyle(Theme.olive)
                    }
                }
            }
            
            // Step tip
            if let tip = step.tip {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.caption)
                    Text(tip)
                        .font(.caption)
                        .foregroundStyle(Theme.subtext)
                }
                .padding(.leading, 24)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct TimerControlView: View {
    let timer: RecipeTimerManager.RecipeTimer
    @ObservedObject var timerManager: RecipeTimerManager
    @State private var timeRemaining: String = ""
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "timer")
                .foregroundStyle(.orange)
            Text(timer.formattedTime)
                .monospacedDigit()
                .font(.headline)
                .foregroundStyle(timer.isFinished ? .red : Theme.text)
            
            Spacer()
            
            if timer.isPaused {
                Button {
                    timerManager.resumeTimer(timer.id)
                } label: {
                    Image(systemName: "play.fill")
                        .foregroundStyle(Theme.olive)
                }
            } else {
                Button {
                    timerManager.pauseTimer(timer.id)
                } label: {
                    Image(systemName: "pause.fill")
                        .foregroundStyle(Theme.olive)
                }
            }
            
            Button {
                timerManager.cancelTimer(timer.id)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(RoundedRectangle(cornerRadius: 12).fill(Theme.oliveSoft.opacity(0.3)))
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            timeRemaining = timer.formattedTime
        }
    }
}

