import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var bottomBar: BottomBarState
    @EnvironmentObject private var settings: AppSettings

    @State private var editedName: String = ""
    @State private var isEditingName = false
    @State private var selectedAvatar: String = "person.fill"
    @State private var showSettings = false

    private let avatarChoices = ["person.fill", "fork.knife", "flame.fill", "leaf.fill", "fish.fill", "cup.and.saucer.fill", "star.fill", "heart.fill"]

    private var myRecipes: [Recipe] {
        store.recipes(for: session.currentUser)
    }
    
    private var favoriteRecipes: [Recipe] {
        myRecipes.filter { $0.isFavorite }
    }

    var body: some View {
        ScrollView {
            GeometryReader { proxy in
                Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .global).minY)
            }
            .frame(height: 0)

            VStack(alignment: .leading, spacing: 20) {
                profileHeader
                statsRow
                quickActions
                favoritesSection
                myRecipesSection
                logoutButton
            }
            .padding(20)
            .padding(.bottom, 100) // Add bottom padding for nav bar
        }
        .background(Theme.bg.ignoresSafeArea())
        .task {
            // Reload recipes for current user
            if let userId = session.currentUser?.id {
                await store.loadRecipes(userId: userId)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.olive)
                }
                
                NavigationLink {
                    MessagesView()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.olive)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        .onAppear {
            editedName = session.currentUser?.name ?? ""
            selectedAvatar = session.currentUser?.avatarSeed ?? "person.fill"
            bottomBar.reset()
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { bottomBar.handleScroll(offset: $0) }
    }

    private var profileHeader: some View {
        HStack(spacing: 20) {
            avatarSection
            nameSection
            Spacer()
        }
        .padding(20)
        .background(RoundedRectangle(cornerRadius: 24).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
    }
    
    private var avatarSection: some View {
        ZStack {
            if let user = session.currentUser, let avatarUrl = user.avatarUrl, !avatarUrl.isEmpty {
                AsyncImageURL(
                    urlString: avatarUrl,
                    placeholder: Image(systemName: selectedAvatar),
                    contentMode: .fill
                )
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Theme.olive.opacity(0.3), lineWidth: 3)
                )
                .shadow(color: Theme.olive.opacity(0.2), radius: 8, x: 0, y: 4)
            } else {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Theme.oliveSoft, Theme.oliveSoft.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: Theme.olive.opacity(0.2), radius: 8, x: 0, y: 4)
                
                Image(systemName: selectedAvatar)
                    .font(.system(size: 36, weight: .medium))
                    .foregroundStyle(Theme.olive)
                    .overlay(
                        Circle()
                            .stroke(Theme.olive.opacity(0.3), lineWidth: 3)
                    )
            }
        }
    }
    
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if isEditingName {
                editingNameView
            } else {
                displayNameView
            }
        }
    }
    
    private var editingNameView: some View {
        VStack(alignment: .leading, spacing: 10) {
            TextField("Display name", text: $editedName)
                .textInputAutocapitalization(.words)
                .textFieldStyle(.roundedBorder)
                .font(.headline)
            HStack(spacing: 12) {
                Button {
                    session.updateProfile(name: editedName)
                    isEditingName = false
                    hapticFeedback(.success)
                } label: {
                    Text("Save")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.olive))
                }
                Button {
                    cancelEditing()
                } label: {
                    Text("Cancel")
                        .font(.subheadline)
                        .foregroundStyle(Theme.subtext)
                }
            }
        }
    }
    
    private var displayNameView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(session.currentUser?.name ?? "Guest")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.text)
            
            HStack(spacing: 16) {
                Button {
                    editedName = session.currentUser?.name ?? ""
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isEditingName = true
                    }
                } label: {
                    Label("Edit Name", systemImage: "pencil")
                        .font(.subheadline)
                        .foregroundStyle(Theme.olive)
                }
                
                avatarMenu
            }
        }
    }
    
    private var avatarMenu: some View {
        let choices: [String] = avatarChoices
        return Menu {
            ForEach(choices, id: \.self) { symbol in
                Button {
                    selectedAvatar = symbol
                    session.updateAvatar(seed: symbol)
                    hapticFeedback(.light)
                } label: {
                    HStack {
                        Image(systemName: symbol)
                        Text(symbol.replacingOccurrences(of: ".fill", with: "").capitalized)
                        if selectedAvatar == symbol {
                            Spacer()
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Label("Avatar", systemImage: "face.smiling")
                .font(.subheadline)
                .foregroundStyle(Theme.olive)
        }
    }
    
    private var quickActions: some View {
        HStack(spacing: 12) {
            NavigationLink {
                SettingsView()
            } label: {
                QuickActionButton(icon: "gearshape.fill", title: "Settings", color: Theme.olive)
            }
            .buttonStyle(.plain)
            
            NavigationLink {
                ShoppingListView()
            } label: {
                QuickActionButton(icon: "cart.fill", title: "Shopping", color: .orange)
            }
            .buttonStyle(.plain)
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

    private var statsRow: some View {
        HStack(spacing: 12) {
            StatTile(
                title: "Recipes",
                value: "\(myRecipes.count)",
                icon: "book.fill",
                color: Theme.olive
            )
            StatTile(
                title: "Followers",
                value: "\(session.currentUser?.followers ?? 0)",
                icon: "person.2.fill",
                color: .blue
            )
            StatTile(
                title: "Following",
                value: "\(session.currentUser?.following ?? 0)",
                icon: "person.2.badge.plus.fill",
                color: .green
            )
        }
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Favorites", systemImage: "heart.fill")
                    .font(Theme.titleM())
                    .foregroundStyle(.pink)
                Spacer()
                if !favoriteRecipes.isEmpty {
                    Text("\(favoriteRecipes.count)")
                        .font(.caption)
                        .foregroundStyle(Theme.subtext)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Theme.oliveSoft))
                }
            }
            
            if favoriteRecipes.isEmpty {
                EmptyStateCard(
                    icon: "heart",
                    title: "No favorites yet",
                    message: "Mark recipes as favorites to pin them here"
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(favoriteRecipes) { recipe in
                            NavigationLink {
                                RecipeDetailView(recipe: recipe)
                            } label: {
                                FavoriteCard(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private var myRecipesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("My Recipes", systemImage: "book.fill")
                    .font(Theme.titleM())
                Spacer()
                if !myRecipes.isEmpty {
                    Text("\(myRecipes.count)")
                        .font(.caption)
                        .foregroundStyle(Theme.subtext)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Theme.oliveSoft))
                }
            }
            
            if myRecipes.isEmpty {
                EmptyStateCard(
                    icon: "book.closed",
                    title: "No recipes yet",
                    message: "Add your first recipe to show it off here!"
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(myRecipes) { recipe in
                        NavigationLink { 
                            RecipeDetailView(recipe: recipe) 
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
            session.logout()
        } label: {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                Text("Log Out")
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 18).fill(Color.red.opacity(0.9)))
            .foregroundStyle(.white)
            .shadow(color: .red.opacity(0.3), radius: 8, y: 4)
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
    var icon: String
    var color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(color)
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.text)
            Text(title)
                .font(.caption)
                .foregroundStyle(Theme.subtext)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}

private struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(Theme.text)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }
}

private struct EmptyStateCard: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(Theme.subtext.opacity(0.4))
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.text)
            Text(message)
                .font(.caption)
                .foregroundStyle(Theme.subtext)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card.opacity(0.5)))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
    }
}

private struct FavoriteCard: View {
    var recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            recipe.recipeImage()
                .scaledToFill()
                .frame(width: 150, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Theme.text)
                    .lineLimit(2)
                
                HStack(spacing: 6) {
                    Label("\(recipe.totalTime)m", systemImage: "clock.fill")
                        .font(.caption2)
                        .foregroundStyle(Theme.subtext)
                }
            }
            .padding(10)
        }
        .frame(width: 150)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
    }
}
