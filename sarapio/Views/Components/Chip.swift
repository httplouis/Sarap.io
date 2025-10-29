// Views/Components/Chip.swift
import SwiftUI

struct Chip: View {
    var title: String
    @Binding var isOn: Bool
    init(_ title: String, isOn: Binding<Bool>) { self.title = title; _isOn = isOn }

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.15)) { isOn.toggle() }
        } label: {
            Text(title)
                .font(Theme.label())
                .foregroundStyle(isOn ? .white : Theme.text)
                .padding(.horizontal, 14).padding(.vertical, 8)
                .background(
                    Capsule().fill(isOn ? Theme.olive : Theme.oliveSoft)
                )
                .overlay(
                    Capsule().stroke(Theme.olive.opacity(isOn ? 0 : 0.4), lineWidth: 1)
                )
        }.buttonStyle(.plain)
    }
}

