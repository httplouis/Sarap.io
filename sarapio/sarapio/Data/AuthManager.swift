import Foundation

enum AuthError: LocalizedError {
    case emailAlreadyUsed
    case invalidCredentials
    case weakPassword
    case missingFields

    var errorDescription: String? {
        switch self {
        case .emailAlreadyUsed:
            return "Email is already registered."
        case .invalidCredentials:
            return "Invalid email or password."
        case .weakPassword:
            return "Password should be at least 8 characters."
        case .missingFields:
            return "Please fill in all required fields."
        }
    }
}

final class AuthManager: ObservableObject {
    @Published private(set) var users: [UserAccount]
    @Published var currentUser: UserAccount?
    @Published var rememberMe = false

    private let storageKey = "sarapio.users"
    private let rememberEmailKey = "sarapio.rememberedEmail"
    private let rememberFlagKey = "sarapio.rememberedFlag"

    init() {
        let defaultUser = UserAccount(
            name: "Ana Dela Cruz",
            email: "ana@sarap.io",
            password: "password123",
            avatar: .ana,
            followers: 120,
            following: 86
        )

        if let data = UserDefaults.standard.data(forKey: storageKey),
           let decoded = try? JSONDecoder().decode([UserAccount].self, from: data),
           !decoded.isEmpty {
            self.users = decoded
        } else {
            self.users = [defaultUser]
            persistUsers()
        }

        let defaults = UserDefaults.standard
        if defaults.bool(forKey: rememberFlagKey),
           let rememberedEmail = defaults.string(forKey: rememberEmailKey),
           let match = users.first(where: { $0.email.caseInsensitiveCompare(rememberedEmail) == .orderedSame }) {
            currentUser = match
            rememberMe = true
        }
    }

    func login(email: String, password: String, remember: Bool) throws {
        guard !email.isEmpty, !password.isEmpty else { throw AuthError.missingFields }
        guard let user = users.first(where: { $0.email.caseInsensitiveCompare(email) == .orderedSame }) else {
            throw AuthError.invalidCredentials
        }
        guard user.password == password else { throw AuthError.invalidCredentials }

        currentUser = user
        rememberMe = remember
        updateRememberedState(email: remember ? user.email : nil)
    }

    func signUp(name: String, email: String, password: String) throws {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty else { throw AuthError.missingFields }
        guard password.count >= 8 else { throw AuthError.weakPassword }
        guard users.first(where: { $0.email.caseInsensitiveCompare(email) == .orderedSame }) == nil else {
            throw AuthError.emailAlreadyUsed
        }

        let newUser = UserAccount(
            name: name,
            email: email.lowercased(),
            password: password,
            avatar: .chefHat,
            followers: Int.random(in: 20...150),
            following: Int.random(in: 10...120)
        )
        users.append(newUser)
        persistUsers()
        currentUser = newUser
        rememberMe = true
        updateRememberedState(email: newUser.email)
    }

    func logout() {
        currentUser = nil
        rememberMe = false
        updateRememberedState(email: nil)
    }

    func updateProfile(name: String, avatar: UserAccount.Avatar?) {
        guard var user = currentUser else { return }
        user.name = name
        user.avatar = avatar
        if let idx = users.firstIndex(where: { $0.id == user.id }) {
            users[idx] = user
            persistUsers()
        }
        currentUser = user
    }

    func updateStats(recipesCount: Int) {
        guard var user = currentUser else { return }
        user.followers = max(user.followers, recipesCount * 5)
        user.following = max(user.following, recipesCount * 3)
        if let idx = users.firstIndex(where: { $0.id == user.id }) {
            users[idx] = user
            persistUsers()
        }
        currentUser = user
    }

    func refreshCurrentUser() {
        guard let user = currentUser,
              let refreshed = users.first(where: { $0.id == user.id }) else { return }
        currentUser = refreshed
    }

    private func updateRememberedState(email: String?) {
        let defaults = UserDefaults.standard
        if let email {
            defaults.set(email, forKey: rememberEmailKey)
            defaults.set(true, forKey: rememberFlagKey)
        } else {
            defaults.removeObject(forKey: rememberEmailKey)
            defaults.set(false, forKey: rememberFlagKey)
        }
    }

    private func persistUsers() {
        guard let data = try? JSONEncoder().encode(users) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
