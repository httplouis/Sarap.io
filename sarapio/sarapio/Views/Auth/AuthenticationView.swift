import SwiftUI

struct AuthenticationView: View {
    enum Mode: String, CaseIterable, Identifiable {
        case login = "Login"
        case signup = "Sign Up"

        var id: String { rawValue }
    }

    @State private var selectedMode: Mode = .login

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 6) {
                Text("Sarap.io")
                    .font(Theme.titleXL())
                    .foregroundStyle(Theme.olive)
                Text("Cook, share, and discover the best home recipes.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.subtext)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            Picker("Mode", selection: $selectedMode) {
                ForEach(Mode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 32)

            Spacer(minLength: 0)

            if selectedMode == .login {
                LoginForm(switchToSignUp: { selectedMode = .signup })
            } else {
                SignUpForm(onComplete: { selectedMode = .login })
            }

            Spacer()
        }
        .padding(.horizontal)
        .background(Theme.bg.ignoresSafeArea())
    }
}
