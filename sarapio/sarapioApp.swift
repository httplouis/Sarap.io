import SwiftUI

@main
struct SarapIOApp: App {
    @StateObject private var store = RecipeStore()
    @StateObject private var session = SessionManager()
    @StateObject private var feedStore = SocialFeedStore()

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Theme.bg)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Theme.text)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Theme.text)]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Theme.olive)

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Theme.bg)
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if session.currentUser == nil {
                    AuthView()
                        .environmentObject(session)
                } else {
                    ContentView()
                        .environmentObject(store)
                        .environmentObject(session)
                        .environmentObject(feedStore)
                }
            }
            .tint(Theme.olive)
            .background(Theme.bg.ignoresSafeArea())
            .preferredColorScheme(.light)
        }
    }
}
