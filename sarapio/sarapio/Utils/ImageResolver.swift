import SwiftUI

extension Recipe {
    /// Returns a SwiftUI `Image` using user photo first, else the asset.
    func resolvedImage() -> Image? {
        if let data = imageData, let ui = UIImage(data: data) {
            return Image(uiImage: ui)
        }
        if let name = assetName, !name.isEmpty {
            return Image(name) // must exist in Assets.xcassets
        }
        return nil
    }
}
