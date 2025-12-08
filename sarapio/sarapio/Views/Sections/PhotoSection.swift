import SwiftUI
import PhotosUI

struct PhotoSection: View {
    @Binding var pickerItem: PhotosPickerItem?
    var previewImage: () -> AnyView   

    var body: some View {
        Section("PHOTO") {
            HStack(spacing: 16) {
                previewImage()   // call closure
                    .frame(width: 84, height: 84)
                    .background(Theme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Theme.border, lineWidth: 1))

                PhotosPicker(selection: $pickerItem, matching: .images, photoLibrary: .shared()) {
                    Label("Choose Photo", systemImage: "photo.on.rectangle")
                        .font(.body)
                        .foregroundStyle(Theme.olive)
                }
            }
            .listRowBackground(Theme.card)
        }
    }
}
