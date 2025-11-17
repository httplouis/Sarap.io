import Foundation
import Combine
import SwiftUI

struct AppUser: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var email: String
    var avatarSeed: String
    var followers: Int
    var following: Int

    init(
        id: UUID = UUID(),
        name: String,
        email: String,
        avatarSeed: String = "person.fill",
        followers: Int = 0,
        following: Int = 0
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.avatarSeed = avatarSeed
        self.followers = followers
        self.following = following
    }
}

@MainActor
final class SessionManager: ObservableObject {
    enum AuthError: LocalizedError {
        case emptyFields
        case passwordTooShort
        case passwordMismatch
        case emailAlreadyUsed
        case invalidCredentials

        var errorDescription: String? {
            switch self {
            case .emptyFields: return "Please fill in all fields."
            case .passwordTooShort: return "Password should be at least 6 characters."
            case .passwordMismatch: return "Passwords do not match."
            case .emailAlreadyUsed: return "That email is already registered."
            case .invalidCredentials: return "Email or password is incorrect."
            }
        }
    }

    @Published private(set) var currentUser: AppUser?
    @Published var rememberMe: Bool = false
    @Published private(set) var storedUsers: [String: StoredCredentials] = [:]

    private let rememberedKey = "sarapio.rememberedUser"
    private let usersKey = "sarapio.savedUsers"

    struct StoredCredentials: Codable {
        var user: AppUser
        var password: String
    }

    init() {
        loadStoredUsers()
        seedDemoAccountIfNeeded()
        autoLoginIfAvailable()
    }

    func signup(name: String, email: String, password: String, confirmPassword: String, remember: Bool) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedConfirm = confirmPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty, !trimmedEmail.isEmpty, !trimmedPassword.isEmpty, !trimmedConfirm.isEmpty else {
            throw AuthError.emptyFields
        }
        guard trimmedPassword.count >= 6 else { throw AuthError.passwordTooShort }
        guard trimmedPassword == trimmedConfirm else { throw AuthError.passwordMismatch }
        guard storedUsers[trimmedEmail] == nil else { throw AuthError.emailAlreadyUsed }

        let avatars = ["person.fill", "fork.knife", "flame.fill", "leaf.fill", "fish.fill"]
        let user = AppUser(
            name: trimmedName,
            email: trimmedEmail,
            avatarSeed: avatars.randomElement() ?? "person.fill",
            followers: Int.random(in: 20...150),
            following: Int.random(in: 10...120)
        )
        let credentials = StoredCredentials(user: user, password: trimmedPassword)
        storedUsers[trimmedEmail] = credentials
        persistUsers()
        currentUser = user
        rememberMe = remember
        persistRememberedUser(remember ? credentials : nil)
    }

    func login(email: String, password: String, remember: Bool) throws {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else { throw AuthError.emptyFields }
        guard let credentials = storedUsers[trimmedEmail], credentials.password == trimmedPassword else {
            throw AuthError.invalidCredentials
        }
        currentUser = credentials.user
        rememberMe = remember
        persistRememberedUser(remember ? credentials : nil)
    }

    func logout() {
        currentUser = nil
        rememberMe = false
        persistRememberedUser(nil)
    }

    private func loadStoredUsers() {
        guard let data = UserDefaults.standard.data(forKey: usersKey) else { return }
        if let decoded = try? JSONDecoder().decode([String: StoredCredentials].self, from: data) {
            storedUsers = decoded
        }
    }

    private func persistUsers() {
        if let data = try? JSONEncoder().encode(storedUsers) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }

    private func seedDemoAccountIfNeeded() {
        if storedUsers.isEmpty {
            let demo = AppUser(
                name: "Chef Demo",
                email: "demo@sarap.io",
                avatarSeed: "fork.knife",
                followers: 248,
                following: 132
            )
            storedUsers[demo.email] = StoredCredentials(user: demo, password: "password")
            persistUsers()
        }
    }

    private func autoLoginIfAvailable() {
        guard
            let data = UserDefaults.standard.data(forKey: rememberedKey),
            let stored = try? JSONDecoder().decode(StoredCredentials.self, from: data)
        else { return }

        storedUsers[stored.user.email] = storedUsers[stored.user.email] ?? stored
        currentUser = stored.user
        rememberMe = true
    }

    private func persistRememberedUser(_ credentials: StoredCredentials?) {
        if let credentials, let data = try? JSONEncoder().encode(credentials) {
            UserDefaults.standard.set(data, forKey: rememberedKey)
        } else {
            UserDefaults.standard.removeObject(forKey: rememberedKey)
        }
    }

    func updateProfile(name: String) {
        guard var user = currentUser else { return }
        user.name = name
        currentUser = user
        if var credentials = storedUsers[user.email] {
            credentials.user = user
            storedUsers[user.email] = credentials
            persistUsers()
            if rememberMe { persistRememberedUser(credentials) }
        }
    }

    func updateAvatar(seed: String) {
        guard var user = currentUser else { return }
        user.avatarSeed = seed
        currentUser = user
        if var credentials = storedUsers[user.email] {
            credentials.user = user
            storedUsers[user.email] = credentials
            persistUsers()
            if rememberMe { persistRememberedUser(credentials) }
        }
    }
}
