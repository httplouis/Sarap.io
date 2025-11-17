import SwiftUI

struct FilterChip: View {
    let title: String
    @Binding var isOn: Bool
    
    init(_ title: String, isOn: Binding<Bool>) {
        self.title = title
        self._isOn = isOn
    }
    
    var body: some View {
        Button {
            HapticManager.shared.selection()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isOn.toggle()
            }
        } label: {
            HStack(spacing: 6) {
                if isOn {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                }
                Text(title)
                    .font(.footnote)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isOn ? .white : Theme.text)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(isOn ? Theme.olive : Theme.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isOn ? Theme.olive : Theme.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

