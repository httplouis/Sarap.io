import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var session: SessionManager
    @State private var isLogin = true

    // login
    @State private var email = ""
    @State private var password = ""
    @State private var remember = true

    // signup
    @State private var name = ""
    @State private var confirmPassword = ""

    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(isLogin ? "Login" : "Create Account")) {
                    if !isLogin {
                        TextField("Full name", text: $name)
                            .textInputAutocapitalization(.words)
                    }
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    SecureField("Password", text: $password)
                    if !isLogin {
                        SecureField("Confirm password", text: $confirmPassword)
                    }
                    Toggle("Remember me", isOn: $remember)
                }

                if let errorText {
                    Text(errorText)
                        .foregroundStyle(.red)
                }

                Button(isLogin ? "Login" : "Sign Up") {
                    submit()
                }
                .font(.headline)
            }
            .navigationTitle("Welcome")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(isLogin ? "Sign Up" : "Login") {
                        withAnimation { isLogin.toggle() }
                        errorText = nil
                    }
                }
            }
        }
    }

    private func submit() {
        do {
            if isLogin {
                try session.login(email: email, password: password, remember: remember)
            } else {
                try session.signup(name: name, email: email, password: password, confirmPassword: confirmPassword, remember: remember)
            }
        } catch {
            errorText = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        }
    }
}
