import SwiftUI

struct AddHubView: View {
    @EnvironmentObject private var shoppingList: ShoppingListStore
    @State private var showAddRecipe = false
    @State private var showAddPost = false
    @State private var showShoppingList = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HeroCard(title: "Add a Recipe", subtitle: "Share your kitchen masterpiece", icon: "fork.knife") {
                    showAddRecipe = true
                }

                HeroCard(title: "Create a Post", subtitle: "Tell the community what you're cooking", icon: "sparkles") {
                    showAddPost = true
                }
                
                NavigationLink {
                    ShoppingListView()
                } label: {
                    HeroCard(title: "Shopping List", subtitle: "\(shoppingList.totalCount) items • \(shoppingList.checkedCount) checked", icon: "cart.fill") {
                        showShoppingList = true
                    }
                }
                .buttonStyle(.plain)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Actions")
                        .font(Theme.titleM())
                    Text("Create recipes, share posts, and manage your shopping list all in one place.")
                        .font(Theme.body())
                        .foregroundStyle(Theme.subtext)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 22).fill(Theme.card))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Theme.border, lineWidth: 1))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 6)
            }
            .padding(24)
        }
        .background(Theme.bg.ignoresSafeArea())
        .navigationTitle("Create")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    MessagesView()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundStyle(Theme.olive)
                }
            }
        }
        .sheet(isPresented: $showAddRecipe) {
            NavigationStack { AddRecipeView() }
        }
        .sheet(isPresented: $showAddPost) {
            AddSocialPostViewWrapper()
        }
    }
}

private struct HeroCard: View {
    var title: String
    var subtitle: String
    var icon: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(Theme.oliveSoft.opacity(0.6))
                        .frame(width: 64, height: 64)
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Theme.olive)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.text)
                    Text(subtitle)
                        .font(.system(size: 15, weight: .regular, design: .rounded))
                        .foregroundStyle(Theme.subtext)
                }

                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.subtext)
            }
            .padding(22)
            .background(RoundedRectangle(cornerRadius: 26).fill(Theme.card))
            .overlay(RoundedRectangle(cornerRadius: 26).stroke(Theme.border, lineWidth: 1))
            .shadow(color: .black.opacity(0.08), radius: 10, y: 6)
        }
        .buttonStyle(.plain)
    }
}

private struct AddSocialPostViewWrapper: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var feedStore: SocialFeedStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AddSocialPostView { post in
            var recipe = post.recipe
            recipe.assignAuthor(email: session.currentUser?.email, name: session.currentUser?.name)
            Task {
                await store.add(recipe, regenerateIdentity: true, userId: session.currentUser?.id)
            }
            var updatedPost = post
            updatedPost.recipe = recipe
            feedStore.append(updatedPost)
        } onDismiss: {
            dismiss()
        }
        .environmentObject(store)
        .environmentObject(session)
        .environmentObject(feedStore)
    }
}
