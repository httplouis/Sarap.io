// RecipeRow.swift
import SwiftUI
import UIKit

struct RecipeRow: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Recipe Image with overlay
            ZStack(alignment: .topTrailing) {
                AsyncRecipeImage(recipe: recipe)
                    .scaledToFill()
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                
                // Favorite badge
                if recipe.isFavorite {
                    ZStack {
                        Circle()
                            .fill(Color.pink.opacity(0.95))
                            .frame(width: 36, height: 36)
                        Image(systemName: "heart.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                    .padding(16)
                }
                
                // Gradient overlay for better text readability
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 24))
            }

            // Content
            VStack(alignment: .leading, spacing: 12) {
                // Title
                Text(recipe.title)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(Theme.text)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                // Info badges
                HStack(spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundStyle(Theme.olive)
                        Text("\(recipe.minutes)m")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.text)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Theme.oliveSoft.opacity(0.4))
                    )
                    
                    HStack(spacing: 6) {
                        Image(systemName: "person.2")
                            .font(.caption)
                            .foregroundStyle(Theme.olive)
                        Text("\(recipe.servings)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.text)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Theme.oliveSoft.opacity(0.4))
                    )
                    
                    if let cuisine = recipe.cuisine {
                        Text(cuisine)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(Theme.olive)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Theme.oliveSoft.opacity(0.3))
                            )
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.subtext)
                }
            }
            .padding(18)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Theme.card)
                .shadow(color: .black.opacity(0.1), radius: 16, y: 8)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    LinearGradient(
                        colors: [Theme.border, Theme.border.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: recipe.id)
    }
}
