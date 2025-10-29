import SwiftUI

struct BasicInfoSection: View {
    @Binding var title: String
    @Binding var minutes: String
    @Binding var servings: String
    @Binding var cuisine: String
    @Binding var region: String

    var body: some View {
        Section("BASIC") {
            TextField("Title", text: $title)

            HStack {
                TextField("Minutes", text: $minutes).keyboardType(.numberPad)
                TextField("Servings", text: $servings).keyboardType(.numberPad)
            }

            TextField("Cuisine (optional)", text: $cuisine)
            TextField("Region (optional)", text: $region)
        }
        .listRowBackground(Theme.card)
    }
}
