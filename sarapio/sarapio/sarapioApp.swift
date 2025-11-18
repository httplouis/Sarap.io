// SarapIOApp.swift
import SwiftUI

@main
struct SarapIOApp: App {
    @StateObject private var store = RecipeStore()
    @StateObject private var session = SessionManager()
    @StateObject private var feedStore = SocialFeedStore()
    @StateObject private var shoppingList = ShoppingListStore()
    @StateObject private var timerManager = RecipeTimerManager()
    @StateObject private var notificationStore = NotificationStore()
    @StateObject private var searchHistory = SearchHistoryStore()
    @StateObject private var appSettings = AppSettings()

    init() {
        // Large title color
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = UIColor(Theme.bg)
        nav.largeTitleTextAttributes = [.foregroundColor: UIColor(Theme.text)]
        nav.titleTextAttributes      = [.foregroundColor: UIColor(Theme.text)]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().tintColor = UIColor(Theme.olive)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(session)
                .environmentObject(feedStore)
                .environmentObject(shoppingList)
                .environmentObject(timerManager)
                .environmentObject(notificationStore)
                .environmentObject(searchHistory)
                .environmentObject(appSettings)
                .tint(Theme.olive)
                .task {
                    // Seed recipes to database if needed
                    await seedRecipesIfNeeded()
                }
        }
    }
    
    private func seedRecipesIfNeeded() async {
        // Check if we need to seed recipes
        if store.recipes.isEmpty {
            let sampleRecipes = SampleData.recipes
            // Get demo user ID
            if let demoUser = session.currentUser, demoUser.email == "demo@sarap.io" {
                // Try to get user ID from database or create one
                for recipe in sampleRecipes where recipe.authorEmail == "demo@sarap.io" {
                    await store.add(recipe, regenerateIdentity: true, userId: nil)
                }
            }
        }
    }
}
