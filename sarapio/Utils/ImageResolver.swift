import SwiftUI

extension Recipe {
    func resolvedImage() -> Image? {
        if let data = imageData, let ui = UIImage(data: data) {
            return Image(uiImage: ui)
        }
        if let name = assetName, let ui = UIImage(named: name) {
            return Image(uiImage: ui)
        }
        if let name = imageName {
            return Image(name)
        }
        return nil
    }
}

// AsyncImage wrapper for loading images from URLs
struct AsyncRecipeImage: View {
    let recipe: Recipe
    @State private var loadedImage: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let image = loadedImage {
                Image(uiImage: image)
                    .resizable()
            } else if let localImage = recipe.resolvedImage() {
                localImage
                    .resizable()
            } else if isLoading {
                ZStack {
                    Theme.card
                    ProgressView()
                }
            } else {
                ZStack {
                    Theme.card
                    Image(systemName: "leaf")
                        .font(.system(size: 30, weight: .semibold))
                        .foregroundStyle(Theme.olive)
                }
            }
        }
        .task {
            if let photoUrl = recipe.photo_url, loadedImage == nil, !isLoading {
                await loadImage(from: photoUrl)
            }
        }
    }
    
    private func loadImage(from urlString: String) async {
        guard let url = URL(string: urlString) else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await MainActor.run {
                    loadedImage = image
                }
            }
        } catch {
            print("⚠️ Failed to load image from URL:", error.localizedDescription)
        }
    }
}
