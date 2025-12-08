import SwiftUI

struct AIChatView: View {
    @EnvironmentObject private var store: RecipeStore
    @StateObject private var aiService = OpenAIService.shared
    
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isLoading: Bool = false
    @State private var showRecipeSuggestions: Bool = false
    @State private var suggestedRecipes: [Recipe] = []
    
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        if messages.isEmpty {
                            welcomeView
                        }
                        
                        ForEach(messages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }
                        
                        if isLoading {
                            HStack {
                                TypingIndicator()
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.vertical, 20)
                }
                .onChange(of: messages.count) { _, _ in
                    if let lastMessage = messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: isLoading) { _, newValue in
                    if newValue {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation {
                                proxy.scrollTo("loading", anchor: .bottom)
                            }
                        }
                    }
                }
            }
            
            // Recipe suggestions (if any)
            if showRecipeSuggestions && !suggestedRecipes.isEmpty {
                recipeSuggestionsView
            }
            
            // Input area
            inputArea
        }
        .background(Theme.bg)
        .padding(.bottom, 100) // Add bottom padding for nav bar
        .navigationTitle("AI Chef")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    messages = []
                    suggestedRecipes = []
                    showRecipeSuggestions = false
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .foregroundStyle(Theme.olive)
                }
            }
        }
        .onAppear {
            if messages.isEmpty {
                addWelcomeMessage()
            }
        }
    }
    
    private var welcomeView: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.olive, Theme.olive.opacity(0.6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            VStack(spacing: 8) {
                Text("AI Chef Assistant")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)
                
                Text("Ask me about recipes, ingredients, or cooking tips!")
                    .font(.subheadline)
                    .foregroundStyle(Theme.subtext)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            // Quick action buttons
            VStack(spacing: 12) {
                QuickActionButton(
                    icon: "magnifyingglass",
                    title: "Search by Ingredients",
                    subtitle: "I have chicken, garlic, soy sauce..."
                ) {
                    inputText = "I have these ingredients: "
                    isInputFocused = true
                }
                
                QuickActionButton(
                    icon: "book.fill",
                    title: "Find a Recipe",
                    subtitle: "Show me Adobo, Sinigang..."
                ) {
                    inputText = "Find me a recipe for "
                    isInputFocused = true
                }
                
                QuickActionButton(
                    icon: "lightbulb.fill",
                    title: "Cooking Tips",
                    subtitle: "How to cook better..."
                ) {
                    inputText = "Give me cooking tips for "
                    isInputFocused = true
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .padding(.vertical, 40)
    }
    
    private var recipeSuggestionsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "fork.knife")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.olive)
                Text("Suggested Recipes")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.text)
                Spacer()
                Button {
                    withAnimation {
                        showRecipeSuggestions = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(Theme.subtext.opacity(0.6))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(suggestedRecipes) { recipe in
                        NavigationLink {
                            RecipeDetailView(recipe: recipe)
                        } label: {
                            RecipeSuggestionCard(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 12)
        }
        .background(Theme.card)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Theme.border.opacity(0.3)),
            alignment: .top
        )
    }
    
    private var inputArea: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                TextField("Ask about recipes, ingredients...", text: $inputText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 16))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 24).fill(Theme.card))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.border.opacity(0.5), lineWidth: 1))
                    .focused($isInputFocused)
                    .lineLimit(1...4)
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Theme.subtext.opacity(0.3) : Theme.olive)
                        )
                        .shadow(color: Theme.olive.opacity(0.3), radius: 4, y: 2)
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Theme.bg)
        }
    }
    
    private func addWelcomeMessage() {
        let welcomeMessage = ChatMessage(
            role: .assistant,
            content: "Hi! I'm your AI Chef Assistant 👨‍🍳\n\nI can help you:\n• Find recipes based on your ingredients\n• Search for specific Filipino dishes\n• Provide cooking tips and advice\n• Answer questions about Filipino cuisine\n\nWhat would you like to cook today?"
        )
        messages.append(welcomeMessage)
    }
    
    private func sendMessage() {
        let userMessage = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userMessage.isEmpty else { return }
        
        // Add user message
        let message = ChatMessage(role: .user, content: userMessage)
        messages.append(message)
        
        // Clear input
        inputText = ""
        isLoading = true
        
        // Extract ingredients from message
        let ingredients = extractIngredients(from: userMessage)
        
        // Search for matching recipes
        Task {
            do {
                // Get AI response with better error handling
                let aiResponse = try await aiService.chat(
                    message: userMessage,
                    conversationHistory: Array(messages.dropLast())
                )
                
                // Add AI response
                await MainActor.run {
                    let responseMessage = ChatMessage(role: .assistant, content: aiResponse)
                    messages.append(responseMessage)
                    isLoading = false
                }
                
                // Find matching recipes based on AI response or ingredients
                let matchingRecipes = findMatchingRecipes(ingredients: ingredients)
                await MainActor.run {
                    if !matchingRecipes.isEmpty {
                        suggestedRecipes = Array(matchingRecipes.prefix(3))
                        withAnimation {
                            showRecipeSuggestions = true
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    let errorDescription: String
                    if let aiError = error as? AIError {
                        errorDescription = aiError.localizedDescription
                    } else {
                        errorDescription = error.localizedDescription
                    }
                    
                    let errorMessage = ChatMessage(
                        role: .assistant,
                        content: errorDescription.contains("Rate limit") 
                            ? "⚠️ Too many requests! Please wait a few seconds and try again. The AI is processing other requests right now."
                            : "Sorry, I encountered an error: \(errorDescription). Please check your internet connection and try again."
                    )
                    messages.append(errorMessage)
                    isLoading = false
                    
                    print("[AIChat] Error: \(error)")
                }
            }
        }
    }
    
    private func extractIngredients(from text: String) -> [String] {
        let commonIngredients = [
            "chicken", "pork", "beef", "fish", "shrimp", "egg", "eggs",
            "garlic", "onion", "tomato", "potato", "potatoes", "carrot", "carrots", "cabbage",
            "rice", "noodles", "pasta", "soy sauce", "vinegar", "salt", "pepper",
            "ginger", "lemongrass", "coconut milk", "milk", "butter", "oil", "olive oil",
            "bell pepper", "pepper", "bay leaves", "bay leaf", "peppercorns",
            "broccoli", "eggplant", "squash", "string beans", "okra",
            "adobo", "sinigang", "kare-kare", "lechon", "caldereta", "tinola"
        ]
        
        let lowercased = text.lowercased()
        var foundIngredients: [String] = []
        
        // Check for exact matches and partial matches
        for ingredient in commonIngredients {
            if lowercased.contains(ingredient) {
                foundIngredients.append(ingredient)
            }
        }
        
        // Also try to extract from "I have X, Y, Z" patterns
        if let range = lowercased.range(of: "i have") ?? lowercased.range(of: "ingredients:") {
            let afterKeyword = String(lowercased[range.upperBound...])
            let words = afterKeyword.components(separatedBy: CharacterSet(charactersIn: ",.and"))
            for word in words {
                let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
                if trimmed.count > 2 && !trimmed.isEmpty {
                    foundIngredients.append(trimmed)
                }
            }
        }
        
        return Array(Set(foundIngredients)) // Remove duplicates
    }
    
    private func findMatchingRecipes(ingredients: [String]) -> [Recipe] {
        guard !ingredients.isEmpty else { return [] }
        
        return store.recipes.map { recipe -> (recipe: Recipe, score: Int) in
            let recipeIngredients = recipe.ingredients.map { $0.name.lowercased() }
            var score = 0
            
            for ingredient in ingredients {
                if recipeIngredients.contains(where: { $0.contains(ingredient) || ingredient.contains($0) }) {
                    score += 1
                }
            }
            
            // Also check title and description
            let recipeText = (recipe.title + " " + (recipe.description ?? "")).lowercased()
            if ingredients.contains(where: { recipeText.contains($0) }) {
                score += 1
            }
            
            return (recipe, score)
        }
        .filter { $0.score > 0 }
        .sorted { $0.score > $1.score }
        .map { $0.recipe }
    }
}

private struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.role == .user {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 8) {
                    if message.role == .assistant {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Theme.olive)
                            .padding(.top, 2)
                    }
                    
                    Text(message.content)
                        .font(.system(size: 15))
                        .foregroundStyle(message.role == .user ? .white : Theme.text)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .fill(message.role == .user ? Theme.olive : Theme.card)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(message.role == .user ? Color.clear : Theme.border.opacity(0.3), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(message.role == .user ? 0.1 : 0.03), radius: 4, y: 2)
                }
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(Theme.subtext.opacity(0.6))
                    .padding(.horizontal, 4)
            }
            
            if message.role == .assistant {
                Spacer(minLength: 60)
            }
        }
        .padding(.horizontal, 20)
    }
}

private struct TypingIndicator: View {
    @State private var animationPhase = 0
    
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Theme.olive.opacity(0.6))
                    .frame(width: 8, height: 8)
                    .scaleEffect(animationPhase == index ? 1.2 : 0.8)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animationPhase
                    )
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Theme.card)
        )
        .onAppear {
            animationPhase = 1
        }
    }
}

private struct QuickActionButton: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Theme.olive)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Theme.oliveSoft.opacity(0.3))
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.text)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.subtext)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.subtext.opacity(0.5))
            }
            .padding(14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Theme.border.opacity(0.3), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

private struct RecipeSuggestionCard: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            recipe.recipeImage()
                .scaledToFill()
                .frame(width: 160, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.text)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 10))
                    Text("\(recipe.totalTime)m")
                        .font(.system(size: 11))
                }
                .foregroundStyle(Theme.subtext)
            }
            .padding(10)
        }
        .frame(width: 160)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Theme.card)
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
        )
    }
}

