
import SwiftUI
struct Tag: View {
    var text: String
    var body: some View {
        Text(text)
            .font(Theme.label())
            .padding(.horizontal, 10).padding(.vertical, 6)
            .background(Capsule().fill(Theme.oliveSoft.opacity(0.6)))
            .foregroundStyle(Theme.oliveDark)
    }
}
