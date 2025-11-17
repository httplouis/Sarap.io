import SwiftUI

struct LoadingSkeleton: View {
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<3) { _ in
                RecipeSkeletonCard()
            }
        }
    }
}

struct RecipeSkeletonCard: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Image skeleton
            RoundedRectangle(cornerRadius: 16)
                .fill(Theme.card)
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Theme.subtext.opacity(0.1),
                                    Theme.subtext.opacity(0.2),
                                    Theme.subtext.opacity(0.1)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .offset(x: isAnimating ? 300 : -300)
                        .animation(
                            Animation.linear(duration: 1.5)
                                .repeatForever(autoreverses: false),
                            value: isAnimating
                        )
                )
            
            // Title skeleton
            RoundedRectangle(cornerRadius: 8)
                .fill(Theme.subtext.opacity(0.2))
                .frame(height: 20)
                .frame(width: 200)
            
            // Info skeleton
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Theme.subtext.opacity(0.15))
                    .frame(width: 60, height: 16)
                RoundedRectangle(cornerRadius: 6)
                    .fill(Theme.subtext.opacity(0.15))
                    .frame(width: 80, height: 16)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.card)
                .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
        )
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
        .onAppear {
            isAnimating = true
        }
    }
}

