
import SwiftUI
struct Tag: View {
    var text: String
    var icon: String? = nil
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.caption2)
            }
            Text(text)
        }
        .font(Theme.label())
        .padding(.horizontal, 10).padding(.vertical, 6)
        .background(Capsule().fill(Theme.oliveSoft.opacity(0.6)))
        .foregroundStyle(Theme.oliveDark)
    }
}
