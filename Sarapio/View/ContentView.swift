//
//  ContentView.swift
//  Sarapio
//
//  Created by STUDENT on 10/30/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: RecipeStore
    @EnvironmentObject private var session: SessionManager
    @EnvironmentObject private var feedStore: SocialFeedStore
    @StateObject private var bottomBar = BottomBarState()

    @State private var selectedTab: BottomTab = .recipes
    @State private var showAddHub = false
    @State private var showMessages = false

    var body: some View {
        NavigationStack {
            ZStack {
                // MARK: - Tab Content
                Group {
                    switch selectedTab {
                    case .recipes:
                        RecipesView()
                            .environmentObject(store)
                            .environmentObject(bottomBar)
                    case .feed:
                        SocialFeedView()
                            .environmentObject(feedStore)
                            .environmentObject(session)
                            .environmentObject(bottomBar)
                    case .notifications:
                        NotificationsView()
                            .environmentObject(bottomBar)
                    case .profile:
                        ProfileView()
                            .environmentObject(session)
                            .environmentObject(bottomBar)
                            .environmentObject(store)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Theme.bg.ignoresSafeArea())

                // MARK: - Bottom Tab Bar + Overlapping Add Button
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Bottom Tab Bar with overlapping plus button
                    ZStack(alignment: .top) {
                        HStack(spacing: 0) {
                            ForEach(BottomTab.allCases, id: \.self) { tab in
                                Button {
                                    HapticManager.shared.selection()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedTab = tab
                                    }
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: tab.icon)
                                            .font(.system(size: 22, weight: selectedTab == tab ? .semibold : .regular))
                                            .foregroundStyle(selectedTab == tab ? Theme.olive : Theme.subtext)
                                        
                                        Text(tab.title)
                                            .font(.system(size: 11, weight: selectedTab == tab ? .semibold : .regular, design: .rounded))
                                            .foregroundStyle(selectedTab == tab ? Theme.olive : Theme.subtext)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                }
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Theme.card)
                                .shadow(color: .black.opacity(0.1), radius: 20, y: -5)
                        )
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                        
                        // Plus Button Overlapping (half visible)
                        Button {
                            HapticManager.shared.medium()
                            showAddHub = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 64, height: 64)
                                .background(
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [Theme.olive, Theme.oliveDark],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .shadow(color: Theme.olive.opacity(0.4), radius: 12, y: 6)
                                )
                        }
                        .offset(y: -32) // Half overlapping (32px = half of 64px button)
                    }
                }
            }
            .sheet(isPresented: $showAddHub) {
                AddHubView()
                    .environmentObject(store)
                    .environmentObject(session)
            }
            .sheet(isPresented: $showMessages) {
                NavigationStack {
                    MessagesView()
                }
            }
            .task {
                await store.loadRecipes()
                await feedStore.loadPosts()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionManager())
        .environmentObject(RecipeStore())
        .environmentObject(SocialFeedStore())
}
