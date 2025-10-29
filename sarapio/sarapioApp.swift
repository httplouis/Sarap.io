import SwiftUI

@main
struct SarapIOApp: App {
    @StateObject private var store = RecipeStore()
    @StateObject private var session = SessionManager()
    @StateObject private var feedStore = SocialFeedStore()

    init() {
        // UINavigationBar appearance configuration (SwiftUI-safe)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.bg)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(Theme.text)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Theme.text)
        ]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Theme.olive)

        // UITabBar appearance (for system sheets or secondary views)
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Theme.bg)
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(session)
                .environmentObject(feedStore)
                .tint(Theme.olive)
                .background(Theme.bg.ignoresSafeArea()) // consistent background
                .preferredColorScheme(.light) // optional: lock to light mode
        }
    }
}
