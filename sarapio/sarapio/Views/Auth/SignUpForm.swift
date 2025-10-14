import SwiftUI

struct SignUpForm: View {
    @EnvironmentObject private var auth: AuthManager
    @FocusState private var focusedField: Field?

    enum Field { case name, email, password, confirm }

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var acceptTerms = false
    @State private var errorMessage: String?

    var onComplete: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                }

                TextField("Full name", text: $name)
                    .textContentType(.name)
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border))
                    .focused($focusedField, equals: .name)

                TextField("Email", text: $email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .textContentType(.emailAddress)
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border))
                    .focused($focusedField, equals: .email)

                SecureField("Password", text: $password)
                    .textContentType(.newPassword)
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border))
                    .focused($focusedField, equals: .password)

                SecureField("Confirm password", text: $confirmPassword)
                    .textContentType(.newPassword)
                    .padding(14)
                    .background(RoundedRectangle(cornerRadius: 16).fill(Theme.card))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border))
                    .focused($focusedField, equals: .confirm)

                Toggle("I agree to the community guidelines", isOn: $acceptTerms)
                    .tint(Theme.olive)
            }

            Button(action: register) {
                Text("Create Account")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.olive)
            .disabled(!canSubmit)
            .opacity(canSubmit ? 1 : 0.6)
        }
        .padding()
        .background(Theme.bg)
    }

    private var canSubmit: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        password.count >= 8 &&
        password == confirmPassword &&
        acceptTerms
    }

    private func register() {
        guard canSubmit else {
            errorMessage = AuthError.missingFields.localizedDescription
            return
        }

        do {
            try auth.signUp(name: name.trimmingCharacters(in: .whitespaces),
                            email: email.trimmingCharacters(in: .whitespaces),
                            password: password)
            errorMessage = nil
            onComplete()
        } catch {
            errorMessage = error.localizedDescription
            focusedField = .email
        }
    }
}
