// sarapio/Repositories/UserRepo.swift
import Foundation

/// Local user repository that *reads* from SessionManager and uses its
/// public APIs to perform updates. No direct writes to `storedUsers`.
@MainActor
final class UserRepo {
    static let shared = UserRepo()
    private init() {}

    // Ensure a user record exists (no-op for local demo; Supabase version can implement this).
    func ensureUserExists(session: SessionManager, email: String) async {
        // Intentionally left as a no-op in the local implementation.
    }

    // Fetch a user by email from SessionManager's saved users or currentUser.
    func fetchUser(session: SessionManager, email: String) async throws -> AppUser {
        if let creds = session.storedUsers[email] {
            return creds.user
        }
        if let me = session.currentUser, me.email.lowercased() == email.lowercased() {
            return me
        }
        throw NSError(domain: "UserRepo", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
    }

    // Update profile name via SessionManager so UI remains in sync.
    func updateName(session: SessionManager, newName: String) async throws {
        session.updateProfile(name: newName)
    }

    // Update avatar via SessionManager.
    func updateAvatar(session: SessionManager, seed: String) async throws {
        session.updateAvatar(seed: seed)
    }

    // Followers/following: no direct mutation path without new SessionManager APIs.
    // For now, signal that it's unsupported in the local-only implementation.
    enum Unsupported: LocalizedError {
        case notImplemented
        var errorDescription: String? { "Operation not implemented in local UserRepo." }
    }

    func setFollowers(session: SessionManager, email: String, followers: Int) async throws {
        throw Unsupported.notImplemented
    }

    func setFollowing(session: SessionManager, email: String, following: Int) async throws {
        throw Unsupported.notImplemented
    }
}
