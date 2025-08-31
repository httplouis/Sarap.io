import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Theme.bg.ignoresSafeArea()
                RecipesView()
            }
        }
    }
}
