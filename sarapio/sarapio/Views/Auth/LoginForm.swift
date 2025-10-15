import SwiftUI

struct LoginForm: View {
    @EnvironmentObject private var auth: AuthManager
    @FocusState private var focusedField: Field?

    enum Field { case email, password }

    @State private var email = ""
    @State private var password = ""
    @State private var remember = true
    @State private var errorMessage: String?

    var switchToSignUp: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                        .transition(.opacity)
                }

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border))
                    .focused($focusedField, equals: .email)

                SecureField("Password", text: $password)
                    .textContentType(.password)
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border))
                    .focused($focusedField, equals: .password)

                Toggle("Remember me", isOn: $remember)
                    .tint(Theme.olive)
            }

            Button {
                authenticate()
            } label: {
                Text("Login")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.olive)

            Button(action: switchToSignUp) {
                Text("Need an account? Sign up")
                    .font(.subheadline)
                    .foregroundStyle(Theme.olive)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Theme.bg)
        .onAppear {
            email = auth.currentUser?.email ?? ""
            remember = auth.rememberMe
        }
    }

    private func authenticate() {
        do {
            try auth.login(email: email.trimmingCharacters(in: .whitespaces), password: password, remember: remember)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
            focusedField = .email
        }
    }
}
