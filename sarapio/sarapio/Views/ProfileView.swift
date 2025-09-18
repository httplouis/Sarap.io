import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack(spacing: 20) {
            Circle()
                .fill(Theme.olive)
                .frame(width: 80, height: 80)
                .overlay(Text("JL").foregroundStyle(.white).font(.title))

            Text("Jose Louis")
                .font(.title2)
                .fontWeight(.semibold)

            HStack(spacing: 40) {
                VStack {
                    Text("12").font(.headline)
                    Text("Recipes").font(.footnote)
                }
                VStack {
                    Text("120").font(.headline)
                    Text("Followers").font(.footnote)
                }
                VStack {
                    Text("80").font(.headline)
                    Text("Following").font(.footnote)
                }
            }

            Spacer()
        }
        .padding()
        .background(Theme.bg)
    }
}
