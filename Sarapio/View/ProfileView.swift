import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var bottomBar: BottomBarState
    @StateObject private var narrator = RecipeNarrator()

    @State private var editedName: String = ""
    @State private var isEditingName = false
    @State private var selectedAvatar: String = "person.fill"
    @State private var recipeCount: Int = 0

    private let avatarChoices = ["person.fill", "fork.knife", "flame.fill", "leaf.fill", "fish.fill", "cup.and.saucer.fill"]

    private var myRecipes: [Recipe] {
        store.recipes(for: session.currentUser)
    }
    
    private var favoriteRecipes: [Recipe] {
        myRecipes.filter { $0.isFavorite }
    }

    var body: some View {
        ScrollView {
            GeometryReader { proxy in
                Color.clear.preference(key: ScrollOffsetPreferenceKey.self,
                                       value: proxy.frame(in: .global).minY)
            }
            .frame(height: 0)

            VStack(spacing: 0) {
                // Hero Section with gradient background
                profileHeroSection
                    .padding(.bottom, 24)
                
                VStack(alignment: .leading, spacing: 28) {
                    statsRow
                    voiceAssistantSection
                    favoritesSection
                    myRecipesSection
                    logoutButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 100) // Extra padding for bottom bar
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
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            editedName = session.currentUser?.name ?? ""
            selectedAvatar = session.currentUser?.avatarSeed ?? "person.fill"
            bottomBar.reset()
            updateRecipeCount()
        }
        .task {
            await store.loadRecipes()
            updateRecipeCount()
        }
        .refreshable {
            await store.loadRecipes()
            updateRecipeCount()
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { bottomBar.handleScroll(offset: $0) }
    }

    private var profileHeroSection: some View {
        VStack(spacing: 0) {
            // Gradient background
            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    colors: [
                        Theme.olive.opacity(0.15),
                        Theme.oliveSoft.opacity(0.3),
                        Color.clear
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 200)
                .ignoresSafeArea(edges: .top)
                
                // Share button
                Button {
                    HapticManager.shared.light()
                    // Share profile
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .frame(width: 48, height: 48)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Theme.olive, Theme.oliveDark],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .shadow(color: Theme.olive.opacity(0.4), radius: 12, y: 6)
                }
                .padding(.top, 60)
                .padding(.trailing, 24)
            }
            
            // Profile content
            VStack(spacing: 20) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.oliveSoft, Theme.oliveSoft.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 110, height: 110)
                        .shadow(color: Theme.olive.opacity(0.25), radius: 16, x: 0, y: 8)
                    
                    Image(systemName: selectedAvatar)
                        .font(.system(size: 50, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Theme.olive, Theme.oliveDark],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .offset(y: -55)
                
                // Name and actions
                VStack(spacing: 16) {
                    if isEditingName {
                        VStack(spacing: 12) {
                            TextField("Display name", text: $editedName)
                                .textInputAutocapitalization(.words)
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                .multilineTextAlignment(.center)
                                .padding(12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Theme.card)
                                        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                                )
                            
                            HStack(spacing: 12) {
                                Button {
                                    HapticManager.shared.light()
                                    cancelEditing()
                                } label: {
                                    Text("Cancel")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Theme.subtext)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Theme.card)
                                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.border, lineWidth: 1))
                                        )
                                }
                                
                                Button {
                                    HapticManager.shared.success()
                                    Task {
                                        do {
                                            try await UserRepo.shared.updateName(session: session, newName: editedName)
                                            await MainActor.run {
                                                isEditingName = false
                                            }
                                        } catch {
                                            print("⚠️ Failed to update name:", error)
                                        }
                                    }
                                } label: {
                                    Text("Save")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Theme.olive, Theme.oliveDark],
                                                        startPoint: .leading,
                                                        endPoint: .trailing
                                                    )
                                                )
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    } else {
                        VStack(spacing: 12) {
                            Text(session.currentUser?.name ?? "Guest")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(Theme.text)
                            
                            HStack(spacing: 20) {
                                Button {
                                    HapticManager.shared.light()
                                    editedName = session.currentUser?.name ?? ""
                                    isEditingName = true
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "pencil")
                                            .font(.caption)
                                        Text("Edit Name")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundStyle(Theme.olive)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Theme.oliveSoft.opacity(0.5))
                                    )
                                }
                                
                                Menu {
                                    ForEach(avatarChoices, id: \.self) { symbol in
                                        Button {
                                            HapticManager.shared.selection()
                                            selectedAvatar = symbol
                                            Task {
                                                do {
                                                    try await UserRepo.shared.updateAvatar(session: session, seed: symbol)
                                                } catch {
                                                    print("⚠️ Failed to update avatar:", error)
                                                }
                                            }
                                        } label: {
                                            Label(symbol, systemImage: symbol)
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "face.smiling")
                                            .font(.caption)
                                        Text("Change Avatar")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                    }
                                    .foregroundStyle(Theme.olive)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Theme.oliveSoft.opacity(0.5))
                                    )
                                }
                            }
                        }
                    }
                }
                .padding(.top, -40)
            }
        }
    }
    
    private func updateRecipeCount() {
        recipeCount = myRecipes.count
    }

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatTile(
                title: "Recipes",
                value: "\(recipeCount)",
                icon: "book.closed.fill",
                gradient: [Theme.olive, Theme.oliveDark]
            )
            StatTile(
                title: "Followers",
                value: "\(session.currentUser?.followers ?? 0)",
                icon: "person.2.fill",
                gradient: [Color.blue, Color.blue.opacity(0.7)]
            )
            StatTile(
                title: "Following",
                value: "\(session.currentUser?.following ?? 0)",
                icon: "person.2.circle.fill",
                gradient: [Color.purple, Color.purple.opacity(0.7)]
            )
        }
    }
    
    private var voiceAssistantSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.olive.opacity(0.2), Theme.oliveSoft],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.olive)
                }
                Text("Voice Assistant Settings")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)
            }
            
            VStack(spacing: 16) {
                // Speech Speed Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Speech Speed")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .foregroundStyle(Theme.text)
                            Text("Adjust how fast the voice speaks")
                                .font(.caption)
                                .foregroundStyle(Theme.subtext)
                        }
                        Spacer()
                        Text(String(format: "%.2fx", narrator.speechRate))
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundStyle(Theme.olive)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Theme.oliveSoft.opacity(0.5))
                            )
                    }
                    
                    HStack(spacing: 12) {
                        Text("Slower")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Theme.subtext)
                            .frame(width: 50, alignment: .leading)
                        
                        Slider(value: $narrator.speechRate, in: 0.3...0.7, step: 0.01)
                            .tint(
                                LinearGradient(
                                    colors: [Theme.olive, Theme.oliveDark],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .onChange(of: narrator.speechRate) { oldValue, newValue in
                                HapticManager.shared.light()
                            }
                        
                        Text("Faster")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(Theme.subtext)
                            .frame(width: 50, alignment: .trailing)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Theme.card)
                        .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Theme.border, Theme.border.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                
                // Auto-Advance Card
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Auto-Advance Steps")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.text)
                        Text("Automatically move to next step in Chef Mode")
                            .font(.caption)
                            .foregroundStyle(Theme.subtext)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer()
                    Toggle("", isOn: $narrator.autoAdvanceSteps)
                        .tint(Theme.olive)
                        .labelsHidden()
                        .onChange(of: narrator.autoAdvanceSteps) { oldValue, newValue in
                            HapticManager.shared.selection()
                        }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Theme.card)
                        .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Theme.border, Theme.border.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
            }
        }
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.pink.opacity(0.2), Color.pink.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    Image(systemName: "heart.fill")
                        .font(.title3)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.pink, Color.pink.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                Text("Favorites")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)
            }
            
            if favoriteRecipes.isEmpty {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.pink.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Image(systemName: "heart.slash")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.pink.opacity(0.5))
                    }
                    VStack(spacing: 6) {
                        Text("No Favorites Yet")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.text)
                        Text("Mark recipes as favorites to pin them here")
                            .font(.subheadline)
                            .foregroundStyle(Theme.subtext)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Theme.card.opacity(0.5))
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(favoriteRecipes) { recipe in
                            NavigationLink {
                                RecipeDetailView(recipe: recipe)
                                    .environmentObject(store)
                                    .environmentObject(session)
                            } label: {
                                FavoriteCard(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 4)
                }
            }
        }
    }

    private var myRecipesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Theme.olive.opacity(0.2), Theme.oliveSoft],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                    Image(systemName: "book.closed.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.olive)
                }
                Text("My Recipes")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)
                
                Spacer()
                
                if !myRecipes.isEmpty {
                    Text("\(myRecipes.count)")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.subtext)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Theme.oliveSoft.opacity(0.5))
                        )
                }
            }
            
            if myRecipes.isEmpty {
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Theme.oliveSoft.opacity(0.3))
                            .frame(width: 80, height: 80)
                        Image(systemName: "book.closed")
                            .font(.system(size: 32))
                            .foregroundStyle(Theme.olive.opacity(0.5))
                    }
                    VStack(spacing: 6) {
                        Text("No Recipes Yet")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.text)
                        Text("Add your first recipe to show it off here")
                            .font(.subheadline)
                            .foregroundStyle(Theme.subtext)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Theme.card.opacity(0.5))
                )
            } else {
                VStack(spacing: 16) {
                    ForEach(myRecipes) { recipe in
                        NavigationLink {
                            RecipeDetailView(recipe: recipe)
                                .environmentObject(store)
                                .environmentObject(session)
                        } label: {
                            RecipeRow(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var logoutButton: some View {
        Button {
            HapticManager.shared.medium()
            session.logout()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.title3)
                Text("Log Out")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.red, Color.red.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(color: Color.red.opacity(0.3), radius: 12, y: 6)
            )
        }
        .padding(.top, 20)
    }

    private func cancelEditing() {
        editedName = session.currentUser?.name ?? ""
        isEditingName = false
    }
}

private struct StatTile: View {
    var title: String
    var value: String
    var icon: String = ""
    var gradient: [Color] = [Theme.olive, Theme.oliveDark]

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: gradient.map { $0.opacity(0.15) },
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(
                        LinearGradient(
                            colors: gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.text)
            
            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(Theme.subtext)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Theme.card)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Theme.border, Theme.border.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

private struct FavoriteCard: View {
    var recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                AsyncRecipeImage(recipe: recipe)
                    .scaledToFill()
                    .frame(width: 180, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                
                // Favorite badge
                ZStack {
                    Circle()
                        .fill(Color.pink.opacity(0.9))
                        .frame(width: 28, height: 28)
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                }
                .padding(10)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.text)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.caption2)
                        .foregroundStyle(Theme.subtext)
                    Text("\(recipe.minutes)m")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(Theme.subtext)
                }
            }
            .padding(14)
        }
        .frame(width: 180)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.card)
                .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Theme.border, Theme.border.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}
