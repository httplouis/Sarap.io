import SwiftUI

struct SkeletonView: View {
    @State private var isAnimating = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: [
                        Theme.card.opacity(0.6),
                        Theme.card.opacity(0.3),
                        Theme.card.opacity(0.6)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Theme.border, lineWidth: 1)
            )
            .shimmer(isAnimating: isAnimating)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

struct RecipeRowSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SkeletonView()
                .frame(height: 200)
            
            SkeletonView()
                .frame(height: 20)
                .frame(width: 200)
            
            SkeletonView()
                .frame(height: 16)
                .frame(width: 150)
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 20).fill(Theme.card))
    }
}

extension View {
    func shimmer(isAnimating: Bool) -> some View {
        self.modifier(ShimmerModifier(isAnimating: isAnimating))
    }
}

struct ShimmerModifier: ViewModifier {
    var isAnimating: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.white.opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: isAnimating ? geometry.size.width : -geometry.size.width)
                }
            )
            .clipped()
    }
}

