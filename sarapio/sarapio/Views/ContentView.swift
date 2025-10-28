import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var session: SessionManager

    var body: some View {
        Group {
            if session.currentUser != nil {
                HomeTabView()
            } else {
                AuthFlowView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: session.currentUser != nil)
    }
}
