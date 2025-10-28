import Foundation
import SwiftUI

final class BottomBarState: ObservableObject {
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

        if delta < 0 {
            hide()
        } else {
            show()
        }
        lastOffset = offset
    }

    func reset() {
        initialized = false
    }

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
