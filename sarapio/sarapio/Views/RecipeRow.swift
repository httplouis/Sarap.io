// RecipeRow.swift
import SwiftUI

struct RecipeRow: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Recipe Image
            if let imgName = recipe.imageName {
                Image(imgName)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
            } else if let data = recipe.imageData, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
            } else {
                ZStack {
                    Theme.card
                    Image(systemName: "leaf")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(Theme.olive)
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
            }

            // Title + Info
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.text)
                    .lineLimit(2)

                Text("\(recipe.minutes)m • \(recipe.ingredients.count) ingredients")
                    .font(.footnote)
                    .foregroundStyle(Theme.subtext)
            }

            // Favorite + Chevron
            HStack {
                if recipe.isFavorite {
                    Image(systemName: "heart.fill")
                        .foregroundStyle(.pink)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundStyle(Theme.subtext)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.card)
                .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
        )
    }
}
