// SarapIOApp.swift
import SwiftUI

@main
struct SarapIOApp: App {
    @StateObject private var store = RecipeStore()
    @StateObject private var session = SessionManager()
    @StateObject private var feedStore = SocialFeedStore()

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
                .tint(Theme.olive)
        }
    }
}
