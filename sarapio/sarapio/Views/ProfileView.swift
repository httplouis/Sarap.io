import SwiftUI
import UIKit

struct ProfileView: View {
    @EnvironmentObject private var auth: AuthManager
    @EnvironmentObject private var store: RecipeStore

    @State private var name: String = ""
    @State private var selectedAvatar: UserAccount.Avatar? = nil
    @State private var showSavedConfirmation = false

    private var myRecipes: [Recipe] {
        store.recipes.filter { $0.ownerId == auth.currentUser?.id }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                profileHeader
                statsView
                editSection
                recipesSection
                roadmapSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: loadUser)
        .alert("Profile updated", isPresented: $showSavedConfirmation) {
            Button("OK", role: .cancel) { }
        }
    }

    private var profileHeader: some View {
        HStack(spacing: 16) {
            avatarView
                .frame(width: 86, height: 86)

            VStack(alignment: .leading, spacing: 6) {
                Text(name)
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(auth.currentUser?.email ?? "")
                    .font(.subheadline)
                    .foregroundStyle(Theme.subtext)
                Button("Log out") { auth.logout() }
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
            Spacer()
        }
    }

    private var avatarView: some View {
        Group {
            if let avatar = selectedAvatar ?? auth.currentUser?.avatar,
               let imageName = avatar.imageName,
               let image = UIImage(named: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Circle()
                    .fill(Theme.olive)
                    .overlay(Text(initials(from: name)).font(.title).foregroundStyle(.white))
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.border))
    }

    private var statsView: some View {
        HStack(spacing: 32) {
            statColumn(title: "Recipes", value: myRecipes.count)
            statColumn(title: "Followers", value: auth.currentUser?.followers ?? 0)
            statColumn(title: "Following", value: auth.currentUser?.following ?? 0)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 22).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.border))
    }

    private func statColumn(title: String, value: Int) -> some View {
        VStack {
            Text("\(value)")
                .font(.title3)
                .fontWeight(.semibold)
            Text(title)
                .font(.caption)
                .foregroundStyle(Theme.subtext)
        }
        .frame(maxWidth: .infinity)
    }

    private var editSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Edit Profile")
                .font(.headline)
            TextField("Name", text: $name)
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border))

            Text("Choose avatar")
                .font(.subheadline)
                .foregroundStyle(Theme.subtext)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(UserAccount.Avatar.allCases, id: \.self) { avatar in
                    Button {
                        selectedAvatar = avatar
                    } label: {
                        avatarPreview(for: avatar)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(selectedAvatar == avatar ? Theme.olive : Theme.border, lineWidth: selectedAvatar == avatar ? 3 : 1)
                            )
                    }
                }
            }

            Button {
                auth.updateProfile(name: name, avatar: selectedAvatar)
                auth.refreshCurrentUser()
                showSavedConfirmation = true
            } label: {
                Text("Save Profile")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.olive)
        }
    }

    private func avatarPreview(for avatar: UserAccount.Avatar) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.card)
                .frame(height: 76)
            if let imageName = avatar.imageName, let image = UIImage(named: imageName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 76)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                Image(systemName: avatar.systemName)
                    .font(.title2)
                    .foregroundStyle(Theme.olive)
            }
        }
    }

    private var recipesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("My Recipes")
                    .font(.headline)
                Spacer()
                Text("\(myRecipes.count)")
                    .font(.subheadline)
                    .foregroundStyle(Theme.subtext)
            }

            if myRecipes.isEmpty {
                VStack(spacing: 8) {
                    Text("No personal recipes yet.")
                        .foregroundStyle(Theme.subtext)
                    Text("Save from the feed or add your own masterpiece!")
                        .font(.footnote)
                        .foregroundStyle(Theme.subtext)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
            } else {
                VStack(spacing: 12) {
                    ForEach(myRecipes) { recipe in
                        NavigationLink { RecipeDetailView(recipe: recipe) } label: {
                            RecipeRow(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var roadmapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Finals Prep")
                .font(.headline)
            Text("Upcoming: connect authentication, recipes, feed, notifications, and messages to a Supabase or Firebase backend. Finish AI-powered recipe recommendations and nutrition insights.")
                .font(.footnote)
                .foregroundStyle(Theme.subtext)
            Text("Research Notes")
                .font(.subheadline)
            VStack(alignment: .leading, spacing: 6) {
                Label("Spoonacular & Edamam APIs for richer data", systemImage: "flame")
                Label("Prototype AI meal suggestions based on pantry", systemImage: "wand.and.stars")
                Label("Ingredient substitution library for allergies", systemImage: "leaf")
                Label("Calorie + macros estimation per serving", systemImage: "chart.bar")
            }
            .font(.footnote)
            .foregroundStyle(Theme.subtext)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 18).fill(Theme.card))
    }

    private func loadUser() {
        guard let user = auth.currentUser else { return }
        name = user.name
        selectedAvatar = user.avatar
    }

    private func initials(from name: String) -> String {
        let components = name.split(separator: " ")
        let letters = components.prefix(2).compactMap { $0.first }
        if letters.isEmpty { return "SU" }
        return letters.map { String($0) }.joined().uppercased()
    }
}
