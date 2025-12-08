import SwiftUI
import UIKit

@MainActor
final class ImageCache: ObservableObject {
    static let shared = ImageCache()
    
    private var cache: [String: UIImage] = [:]
    private let maxCacheSize = 50
    
    private init() {}
    
    func getImage(for key: String) -> UIImage? {
        return cache[key]
    }
    
    func setImage(_ image: UIImage, for key: String) {
        // Limit cache size
        if cache.count >= maxCacheSize {
            let firstKey = cache.keys.first
            cache.removeValue(forKey: firstKey ?? "")
        }
        cache[key] = image
    }
    
    func clearCache() {
        cache.removeAll()
    }
}

struct CachedAsyncImage: View {
    let url: URL?
    let placeholder: Image
    @State private var image: UIImage?
    @State private var isLoading = true
    
    init(url: URL?, placeholder: Image = Image(systemName: "photo")) {
        self.url = url
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else if isLoading {
                placeholder
                    .resizable()
                    .foregroundStyle(Theme.subtext.opacity(0.3))
            } else {
                placeholder
                    .resizable()
                    .foregroundStyle(Theme.subtext.opacity(0.3))
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard let url = url else {
            isLoading = false
            return
        }
        
        // Check cache first
        if let cached = ImageCache.shared.getImage(for: url.absoluteString) {
            image = cached
            isLoading = false
            return
        }
        
        // Load from URL
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let loadedImage = UIImage(data: data) {
                ImageCache.shared.setImage(loadedImage, for: url.absoluteString)
                image = loadedImage
            }
        } catch {
            // Handle error silently
        }
        
        isLoading = false
    }
}

