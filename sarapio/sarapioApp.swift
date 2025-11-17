//
//  SarapioApp.swift
//  Sarapio
//
//  Created by STUDENT on 10/30/25.
//

import SwiftUI

@main
struct SarapioApp: App {
    @StateObject private var session = SessionManager()
    @StateObject private var store = RecipeStore()
    @StateObject private var feedStore = SocialFeedStore()

    var body: some Scene {
        WindowGroup {
            if session.currentUser == nil {
                AuthFlowView()
                    .environmentObject(session)
            } else {
                ContentView()
                    .environmentObject(session)
                    .environmentObject(store)
                    .environmentObject(feedStore)
                    .task {
                        // Ensure user exists in Supabase
                        if let email = session.currentUser?.email {
                            await UserRepo.shared.ensureUserExists(session: session, email: email)
                        }
                    }
            }
        }
    }
}
