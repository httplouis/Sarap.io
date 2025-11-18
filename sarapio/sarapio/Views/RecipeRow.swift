// RecipeRow.swift
import SwiftUI
import UIKit

struct RecipeRow: View {
    let recipe: Recipe
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Recipe Image
            ZStack(alignment: .topTrailing) {
                recipe.recipeImage()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                
                // Favorite badge
                if recipe.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.pink)
                        .padding(10)
                        .background(
                            Circle()
                                .fill(.white.opacity(0.9))
                                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                        )
                        .padding(12)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 12) {
                // Title
                Text(recipe.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Quick info
                HStack(spacing: 12) {
                    HStack(spacing: 5) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 12, weight: .medium))
                        Text("\(recipe.totalTime)m")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(Theme.subtext)
                    
                    HStack(spacing: 5) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 12, weight: .medium))
                        Text("\(recipe.ingredients.count) ingredients")
                            .font(.system(size: 13, weight: .medium))
                    }
                    .foregroundStyle(Theme.subtext)
                    
                    Spacer()
                    
                    if recipe.difficulty != .medium {
                        DifficultyBadge(difficulty: recipe.difficulty)
                    }
                }
            }
            .padding(16)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Theme.card)
                .shadow(color: .black.opacity(0.08), radius: 12, y: 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Theme.border.opacity(0.3), lineWidth: 1)
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .onTapGesture {
            isPressed = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }
    }
}

private struct DifficultyBadge: View {
    let difficulty: Recipe.Difficulty
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: difficulty.icon)
                .font(.system(size: 10, weight: .semibold))
            Text(difficulty.rawValue)
                .font(.system(size: 11, weight: .semibold))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(difficulty.color.opacity(0.15)))
        .foregroundStyle(difficulty.color)
        .overlay(
            Capsule()
                .stroke(difficulty.color.opacity(0.3), lineWidth: 1)
        )
    }
}
