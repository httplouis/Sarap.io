import SwiftUI
import UIKit

struct AuthFlowView: View {
    enum Mode: String, CaseIterable { case login = "Log In", signup = "Sign Up" }
    @State private var mode: Mode = .login

    var body: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 40)
            VStack(spacing: 10) {
                Text("Sarap.io")
                    .font(.system(size: 44, weight: .heavy, design: .rounded))
                    .foregroundStyle(Theme.olive)
                Text("Cook, share, and discover recipes from the community.")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Theme.subtext)
                    .padding(.horizontal, 32)
            }

            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases, id: \.self) { value in
                    Text(value.rawValue).tag(value)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 32)

            Group {
                switch mode {
                case .login:
                    LoginForm()
                case .signup:
                    SignupForm(onSignedUp: { mode = .login })
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .background(Theme.bg.ignoresSafeArea())
    }
}

private struct LoginForm: View {
    @EnvironmentObject private var session: SessionManager
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 18) {
            AuthTextField(icon: "envelope.fill", placeholder: "Email", text: $email, keyboard: .emailAddress)
            AuthSecureField(icon: "lock.fill", placeholder: "Password", text: $password)

            Toggle(isOn: $rememberMe) {
                Text("Remember Me / Auto Login")
                    .font(.footnote)
                    .foregroundStyle(Theme.subtext)
            }
            .toggleStyle(SwitchToggleStyle(tint: Theme.olive))

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                errorMessage = nil
                do {
                    try session.login(email: email, password: password, remember: rememberMe)
                } catch {
                    errorMessage = error.localizedDescription
                }
            } label: {
                Text("Log In")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.olive))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 28).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 8)
    }
}

private struct SignupForm: View {
    @EnvironmentObject private var session: SessionManager
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var rememberMe = true
    var onSignedUp: () -> Void
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 18) {
            AuthTextField(icon: "person.fill", placeholder: "Full Name", text: $name, keyboard: .default, capitalization: .words)
            AuthTextField(icon: "envelope.fill", placeholder: "Email", text: $email, keyboard: .emailAddress)
            AuthSecureField(icon: "lock.fill", placeholder: "Password", text: $password)
            AuthSecureField(icon: "lock.rotation", placeholder: "Confirm Password", text: $confirmPassword)

            Toggle(isOn: $rememberMe) {
                Text("Remember Me / Auto Login")
                    .font(.footnote)
                    .foregroundStyle(Theme.subtext)
            }
            .toggleStyle(SwitchToggleStyle(tint: Theme.olive))

            if let errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                errorMessage = nil
                do {
                    try session.signup(name: name, email: email, password: password, confirmPassword: confirmPassword, remember: rememberMe)
                    onSignedUp()
                } catch {
                    errorMessage = error.localizedDescription
                }
            } label: {
                Text("Create Account")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.olive))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 6)
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 28).fill(Theme.card))
        .overlay(RoundedRectangle(cornerRadius: 28).stroke(Theme.border, lineWidth: 1))
        .shadow(color: .black.opacity(0.06), radius: 10, y: 8)
    }
}

private struct AuthTextField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType
    var capitalization: TextInputAutocapitalization = .never  // ✅ fixed here

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.olive)
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .textInputAutocapitalization(capitalization)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.bg))
    }
}

private struct AuthSecureField: View {
    var icon: String
    var placeholder: String
    @Binding var text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.olive)
            SecureField(placeholder, text: $text)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(RoundedRectangle(cornerRadius: 16).fill(Theme.bg))
    }
}
