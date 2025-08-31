import SwiftUI

struct RecipeRow: View {
    let recipe: Recipe

    var body: some View {
        HStack(spacing: 14) {
            thumb
                .frame(width: 60, height: 60)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))

            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Theme.text)
                    .lineLimit(2)
                Text("\(recipe.minutes)m • \(recipe.ingredients.count) ingredients")
                    .font(.footnote)
                    .foregroundStyle(Theme.subtext)
            }
            Spacer()
            if recipe.isFavorite { Image(systemName: "heart.fill").foregroundStyle(.pink) }
            Image(systemName: "chevron.right").foregroundStyle(Theme.subtext)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Theme.card)
                .shadow(color: .black.opacity(0.06), radius: 10, y: 6)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.border, lineWidth: 1))
        )
    }

    @ViewBuilder private var thumb: some View {
        if let img = recipe.resolvedImage() {
            img.resizable().scaledToFill()
        } else {
            ZStack {
                Theme.bg
                Image(systemName: "leaf")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Theme.olive)
            }
        }
    }
}
