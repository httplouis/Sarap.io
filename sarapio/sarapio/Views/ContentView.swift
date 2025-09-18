import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            NavigationStack {
                RecipesView()
                    .navigationTitle("My Recipes")
                    .navigationBarHidden(true)
            }
            .tabItem {
                Image(systemName: "book.fill")
                Text("My Recipes")
            }

            NavigationStack {
                SocialFeedView()
                    .navigationTitle("Feed")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .tabItem {
                Image(systemName: "person.2.fill")
                Text("Feed")
            }

            NavigationStack {
                AddRecipeView()
            }
            .tabItem {
                Image(systemName: "plus.rectangle.fill")
                Text("Add")
            }

            NavigationStack {
                ProfileView()
                    .navigationTitle("Profile")
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("Profile")
            }
        }
        .tint(Theme.olive)
    }
}
