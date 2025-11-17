import Foundation
import SwiftUI

// Make BottomTab globally available (no duplicates elsewhere)
enum BottomTab: String, CaseIterable, Hashable {
    case recipes
    case feed
    case notifications
    case profile
    
    var icon: String {
        switch self {
        case .recipes: return "book.closed"
        case .feed: return "sparkles"
        case .notifications: return "bell"
        case .profile: return "person.circle"
        }
    }
    
    var title: String {
        switch self {
        case .recipes: return "Recipes"
        case .feed: return "Feed"
        case .notifications: return "Notifications"
        case .profile: return "Profile"
        }
    }
}

final class BottomBarState: ObservableObject {
    @Published var selected: BottomTab = .recipes
    @Published var isHidden: Bool = false

    private var lastOffset: CGFloat = 0
    private var initialized = false

    func handleScroll(offset: CGFloat) {
        if !initialized {
            lastOffset = offset
            initialized = true
            return
        }
        let delta = offset - lastOffset
        guard abs(delta) > 8 else { return }
        if delta < 0 { hide() } else { show() }
        lastOffset = offset
    }

    func reset() { initialized = false }

    func hide() {
        withAnimation(.easeInOut(duration: 0.25)) { isHidden = true }
    }

    func show() {
        withAnimation(.easeInOut(duration: 0.25)) { isHidden = false }
    }
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
