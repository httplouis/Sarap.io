import SwiftUI
import AVFoundation
import UIKit

struct RecipeDetailView: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @Environment(\.dismiss) private var dismiss   // ✅ para makabalik after delete
    @State private var showImageFull = false
    @State private var showDeleteConfirm = false
    @State private var showEdit = false
    @StateObject private var narrator = RecipeNarrator()

    let recipe: Recipe

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Image
                headerImage
                    .padding(.bottom, 24)
                
                VStack(alignment: .leading, spacing: 28) {
                    // Recipe Info
                    recipeInfoSection
                    
                    // Ingredients
                    ingredientsSection
                    
                    // Steps
                    stepsSection
                    
                    // Voice Assistant
                    voiceSection
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
        }
        .background(
            LinearGradient(
                colors: [Theme.bg, Theme.bg.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationTitle(recipe.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    HapticManager.shared.light()
                    shareRecipe()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                Button {
                    HapticManager.shared.light()
                    showEdit = true
                } label: {
                    Image(systemName: "square.and.pencil")
                }
                Button(role: .destructive) {
                    HapticManager.shared.medium()
                    showDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                }
                Button {
                    HapticManager.shared.selection()
                    Task { await store.toggleFavorite(recipe) }
                } label: {
                    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(recipe.isFavorite ? .pink : Theme.text)
                }
            }
        }
        .confirmationDialog("Delete this recipe?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                Task {
                    await store.delete(recipe)
                    await MainActor.run {
                        dismiss()   // ✅ balik agad sa home/list
                    }
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
            ZStack {
                Color.black.ignoresSafeArea()
                AsyncRecipeImage(recipe: recipe)
                    .scaledToFit()
                    .onTapGesture { showImageFull = false }
            }
        }
        .onDisappear { narrator.stop() }
    }

    @ViewBuilder
    private var headerImage: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncRecipeImage(recipe: recipe)
                .scaledToFill()
                .frame(height: 320)
                .clipped()
            
            // Gradient overlay
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 320)
            
            // Info overlay
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    InfoBadge(icon: "clock", text: "\(recipe.minutes)m")
                    InfoBadge(icon: "person.2", text: "\(recipe.servings)")
                    if let cuisine = recipe.cuisine {
                        InfoBadge(icon: "globe", text: cuisine)
                    }
                }
            }
            .padding(20)
        }
        .onTapGesture {
            HapticManager.shared.light()
            showImageFull = true
        }
    }
    
    private var recipeInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let region = recipe.region, !region.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(Theme.olive)
                    Text("Region: \(region)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Theme.text)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Theme.card)
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                )
            }
        }
    }
    
    private var ingredientsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Theme.oliveSoft.opacity(0.4))
                        .frame(width: 40, height: 40)
                    Image(systemName: "list.bullet.rectangle")
                        .font(.title3)
                        .foregroundStyle(Theme.olive)
                }
                Text("Ingredients")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)
            }
            
            VStack(spacing: 12) {
                ForEach(recipe.ingredients) { ing in
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(Theme.oliveSoft.opacity(0.3))
                                .frame(width: 32, height: 32)
                            Image(systemName: "circle.fill")
                                .font(.system(size: 6))
                                .foregroundStyle(Theme.olive)
                        }
                        
                        Text(ing.display)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.text)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Theme.card)
                            .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
                    )
                }
            }
        }
    }
    
    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Theme.oliveSoft.opacity(0.4))
                        .frame(width: 40, height: 40)
                    Image(systemName: "list.number")
                        .font(.title3)
                        .foregroundStyle(Theme.olive)
                }
                Text("Instructions")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)
            }
            
            VStack(spacing: 16) {
                let sortedSteps = recipe.steps.sorted { $0.order < $1.order }
                ForEach(sortedSteps) { st in
                    HStack(alignment: .top, spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Theme.olive, Theme.oliveDark],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 36, height: 36)
                            Text("\(st.order)")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }
                        
                        Text(st.text)
                            .font(.system(size: 16, weight: .regular, design: .rounded))
                            .foregroundStyle(Theme.text)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Theme.card)
                            .shadow(color: .black.opacity(0.06), radius: 10, y: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Theme.border, lineWidth: 1)
                    )
                }
            }
        }
    }
    
    private var voiceSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Theme.oliveSoft.opacity(0.4))
                        .frame(width: 40, height: 40)
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.olive)
                }
                Text("Voice Assistant")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)
            }
            
            if narrator.isChefModeActive {
                chefModeControls
            } else {
                voiceControls
            }
        }
    }
    
    private struct InfoBadge: View {
        let icon: String
        let text: String
        
        var body: some View {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(text)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(.white.opacity(0.25))
                    .background(.ultraThinMaterial, in: Capsule())
            )
        }
    }

    // MARK: - Voice Controls
    private var voiceControls: some View {
        VStack(spacing: 16) {
            // Speak Ingredients
            Button {
                HapticManager.shared.medium()
                speakIngredients()
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Theme.oliveSoft.opacity(0.4))
                            .frame(width: 48, height: 48)
                        Image(systemName: "list.bullet")
                            .font(.title3)
                            .foregroundStyle(Theme.olive)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Speak Ingredients")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.text)
                        Text("Listen to all ingredients")
                            .font(.caption)
                            .foregroundStyle(Theme.subtext)
                    }
                    
                    Spacer()
                    
                    if narrator.isSpeaking {
                        ProgressView()
                            .tint(Theme.olive)
                    } else {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Theme.olive)
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Theme.card)
                        .shadow(color: .black.opacity(0.06), radius: 10, y: 5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Theme.border, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            
            // Start Chef Mode
            Button {
                startChefMode()
            } label: {
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 56, height: 56)
                        Image(systemName: "fork.knife")
                            .font(.title2)
                            .foregroundStyle(.white)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Start Chef Mode")
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Guided cooking with voice")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "play.circle.fill")
                        .font(.title)
                        .foregroundStyle(.white.opacity(0.9))
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(
                            LinearGradient(
                                colors: [Theme.olive, Theme.oliveDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Theme.olive.opacity(0.4), radius: 16, y: 8)
                )
            }
            .buttonStyle(.plain)
            .disabled(recipe.steps.isEmpty)
        }
    }
    
    private var chefModeControls: some View {
        VStack(spacing: 20) {
            // Current Step Indicator
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.olive, Theme.oliveDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                    Image(systemName: "chef.hat.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Chef Mode Active")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Theme.olive)
                    if !recipe.steps.isEmpty {
                        Text("Step \(narrator.currentStepIndex + 1) of \(recipe.steps.count)")
                            .font(.subheadline)
                            .foregroundStyle(Theme.subtext)
                    }
                }
                
                Spacer()
                
                Button {
                    HapticManager.shared.light()
                    narrator.exitChefMode()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Theme.subtext)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Theme.oliveSoft.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Theme.olive.opacity(0.3), lineWidth: 2)
                    )
            )
            
            // Playback Controls
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    Button {
                        HapticManager.shared.light()
                        narrator.previousStep()
                    } label: {
                        Image(systemName: "backward.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Theme.olive, Theme.oliveDark],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Theme.olive.opacity(0.3), radius: 8, y: 4)
                            )
                    }
                    .disabled(narrator.currentStepIndex == 0)
                    .opacity(narrator.currentStepIndex == 0 ? 0.5 : 1.0)
                    
                    Button {
                        HapticManager.shared.medium()
                        if narrator.isPaused {
                            narrator.resume()
                        } else if narrator.isSpeaking {
                            narrator.pause()
                        } else {
                            narrator.speakCurrentStep()
                        }
                    } label: {
                        Image(systemName: narrator.isPaused ? "play.fill" : narrator.isSpeaking ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Theme.olive, Theme.oliveDark],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Theme.olive.opacity(0.4), radius: 12, y: 6)
                            )
                    }
                    
                    Button {
                        HapticManager.shared.light()
                        narrator.nextStep()
                    } label: {
                        Image(systemName: "forward.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Theme.olive, Theme.oliveDark],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(color: Theme.olive.opacity(0.3), radius: 8, y: 4)
                            )
                    }
                    .disabled(narrator.currentStepIndex >= recipe.steps.count - 1)
                    .opacity(narrator.currentStepIndex >= recipe.steps.count - 1 ? 0.5 : 1.0)
                }
                
                Button {
                    HapticManager.shared.light()
                    narrator.repeatStep()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Repeat Step")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(Theme.olive)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Theme.oliveSoft.opacity(0.4))
                    )
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Theme.card)
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Theme.border, lineWidth: 1)
            )
        }
    }
    
    private func speakIngredients() {
        let lines = recipe.ingredients.map { $0.display }.joined(separator: ". ")
        narrator.speak("Ingredients for \(recipe.title): " + lines)
    }
    
    private func startChefMode() {
        guard !recipe.steps.isEmpty else { return }
        HapticManager.shared.medium()
        let sorted = recipe.steps.sorted { $0.order < $1.order }
        let stepTexts = sorted.map { $0.text }
        narrator.startChefMode(steps: stepTexts, recipeName: recipe.title)
    }
    
    private func shareRecipe() {
        let text = "Check out this recipe: \(recipe.title)"
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}
