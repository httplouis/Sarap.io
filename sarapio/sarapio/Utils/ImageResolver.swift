import SwiftUI

extension Recipe {
    func resolvedImage() -> Image? {
        if let data = imageData, let ui = UIImage(data: data) {
            return Image(uiImage: ui)
        }
        if let name = assetName, let ui = UIImage(named: name) {
            return Image(uiImage: ui)
        }
        return nil
    }
}
