import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var bottomBar: BottomBarState

    @State private var editedName: String = ""
    @State private var isEditingName = false
    @State private var selectedAvatar: String = "person.fill"

    private let avatarChoices = ["person.fill", "fork.knife", "flame.fill", "leaf.fill", "fish.fill", "cup.and.saucer.fill"]

    private var myRecipes: [Recipe] {
        store.recipes(for: session.currentUser)
    }

    var body: some View {
        ScrollView {
            GeometryReader { proxy in
                Color.clear.preference(key: ScrollOffsetPreferenceKey.self,
                                       value: proxy.frame(in: .global).minY)
            }
            .frame(height: 0)

            VStack(alignment: .leading, spacing: 24) {
                profileHeader
                statsRow
                favoritesSection
                myRecipesSection
                logoutButton
            }
            .padding(24)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            editedName = session.currentUser?.name ?? ""
            selectedAvatar = session.currentUser?.avatarSeed ?? "person.fill"
            bottomBar.reset()
        }
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { bottomBar.handleScroll(offset: $0) }
    }

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(Theme.oliveSoft.opacity(0.6))
                        .frame(width: 92, height: 92)
                    Image(systemName: selectedAvatar)
                        .font(.system(size: 42))
                        .foregroundStyle(Theme.olive)
                }
                VStack(alignment: .leading, spacing: 8) {
                    if isEditingName {
                        TextField("Display name", text: $editedName)
                            .textInputAutocapitalization(.words)
                            .textFieldStyle(.roundedBorder)
                        HStack {
                            Button("Save") {
                                session.updateProfile(name: editedName)
                                isEditingName = false
                            }
                            Button("Cancel") { cancelEditing() }
                        }
                        .font(.footnote)
                    } else {
                        Text(session.currentUser?.name ?? "Guest")
                            .font(.system(size: 26, weight: .semibold, design: .rounded))
                        Button("Edit Name") {
                            editedName = session.currentUser?.name ?? ""
                            isEditingName = true
                        }
                        .font(.footnote)
                        .foregroundStyle(Theme.olive)
                    }

                    Menu("Change Avatar") {
                        ForEach(avatarChoices, id: \.self) { symbol in
                            Button {
                                selectedAvatar = symbol
                                session.updateAvatar(seed: symbol)
                            } label: {
                                Label(symbol, systemImage: symbol)
                            }
                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(Theme.olive)
                }
                Spacer()
            }
        }
        .background(RoundedRectangle(cornerRadius: 24).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 6)
        .padding(.top, 12)
    }

    private var statsRow: some View {
        HStack(spacing: 24) {
            StatTile(title: "Recipes", value: "\(myRecipes.count)")
            StatTile(title: "Followers", value: "\(session.currentUser?.followers ?? 0)")
            StatTile(title: "Following", value: "\(session.currentUser?.following ?? 0)")
        }
    }

    private var favoritesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Favorites")
                .font(Theme.titleM())
            if myRecipes.filter({ $0.isFavorite }).isEmpty {
                Text("Mark recipes as favorites to pin them here.")
                    .font(.footnote)
                    .foregroundStyle(Theme.subtext)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(myRecipes.filter { $0.isFavorite }) { recipe in
                            FavoriteCard(recipe: recipe)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private var myRecipesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Recipes")
                .font(Theme.titleM())
            if myRecipes.isEmpty {
                Text("Add your first recipe to show it off here!")
                    .font(.footnote)
                    .foregroundStyle(Theme.subtext)
            } else {
                ForEach(myRecipes) { recipe in
                    NavigationLink { RecipeDetailView(recipe: recipe) } label: {
                        RecipeRow(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var logoutButton: some View {
        Button {
            session.logout()
        } label: {
            Text("Log Out")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(RoundedRectangle(cornerRadius: 18).fill(Color.red.opacity(0.85)))
                .foregroundStyle(.white)
        }
        .padding(.top, 30)
    }

    private func cancelEditing() {
        editedName = session.currentUser?.name ?? ""
        isEditingName = false
    }
}

private struct StatTile: View {
    var title: String
    var value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
            Text(title)
                .font(.footnote)
                .foregroundStyle(Theme.subtext)
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
    }
}

private struct FavoriteCard: View {
    var recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imgName = recipe.imageName {
                Image(imgName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 96)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            Text(recipe.title)
                .font(.footnote)
                .foregroundStyle(Theme.text)
        }
        .frame(width: 140)
        .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 4)
    }
}
