import SwiftUI

struct AsyncImageURL: View {
    let urlString: String?
    let placeholder: Image
    let contentMode: ContentMode
    
    @State private var image: UIImage? = nil
    @State private var isLoading = false
    
    init(urlString: String?, placeholder: Image = Image(systemName: "photo"), contentMode: ContentMode = .fill) {
        self.urlString = urlString
        self.placeholder = placeholder
        self.contentMode = contentMode
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                placeholder
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .foregroundStyle(Theme.subtext.opacity(0.3))
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let urlString = urlString,
              let url = URL(string: urlString),
              image == nil else { return }
        
        // Check cache first
        if let cachedImage = ImageCache.shared.getImage(for: urlString) {
            self.image = cachedImage
            return
        }
        
        isLoading = true
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                ImageCache.shared.setImage(uiImage, for: urlString)
                self.image = uiImage
            }
        } catch {
            print("Error loading image from URL: \(error.localizedDescription)")
        }
        isLoading = false
    }
}

// Helper extension for Recipe images
extension Recipe {
    @ViewBuilder
    func recipeImage() -> some View {
        if let imageUrl = imageUrl, !imageUrl.isEmpty {
            AsyncImageURL(urlString: imageUrl, placeholder: Image(systemName: "leaf"))
        } else if let imgName = imageName {
            Image(imgName)
                .resizable()
        } else if let data = imageData, let ui = UIImage(data: data) {
            Image(uiImage: ui)
                .resizable()
        } else {
            ZStack {
                Theme.card
                Image(systemName: "leaf")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(Theme.olive)
            }
        }
    }
}

// Helper extension for User avatars
extension AppUser {
    @ViewBuilder
    func avatarImage() -> some View {
        if let avatarUrl = avatarUrl, !avatarUrl.isEmpty {
            AsyncImageURL(
                urlString: avatarUrl,
                placeholder: Image(systemName: avatarSeed),
                contentMode: .fill
            )
            .clipShape(Circle())
        } else {
            Image(systemName: avatarSeed)
                .resizable()
        }
    }
}

