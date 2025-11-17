// sarapio/Services/UserRepo.swift
import Foundation
import Supabase

@MainActor
final class UserRepo: ObservableObject {
    static let shared = UserRepo()
    private let client = SupabaseClientManager.shared
    private init() {}

    // Ensure a user record exists in Supabase
    func ensureUserExists(session: SessionManager, email: String) async {
        guard let currentUser = session.currentUser else { return }
        
        do {
            struct UserRecord: Codable {
                let id: UUID
                let email: String
                let name: String?
                let avatar_seed: String?
            }
            
            // Check if user exists
            let _: UserRecord = try await client
                .database
                .from("users")
                .select()
                .eq("email", value: email)
                .single()
                .execute()
                .value
            
            // User exists, update if needed
            try await updateUser(user: currentUser)
        } catch {
            // User doesn't exist, create it
            do {
                try await createUser(user: currentUser)
            } catch {
                print("⚠️ Failed to create user in Supabase:", error.localizedDescription)
            }
        }
    }
    
    private func createUser(user: AppUser) async throws {
        struct UserInsert: Codable {
            let id: String
            let email: String
            let name: String?
            let avatar_seed: String?
        }
        
        let insert = UserInsert(
            id: user.id.uuidString,
            email: user.email,
            name: user.name,
            avatar_seed: user.avatarSeed
        )
        
        _ = try await client
            .database
            .from("users")
            .insert(insert)
            .execute()
    }
    
    private func updateUser(user: AppUser) async throws {
        struct UserUpdate: Codable {
            let name: String?
            let avatar_seed: String?
        }
        
        let update = UserUpdate(
            name: user.name,
            avatar_seed: user.avatarSeed
        )
        
        _ = try await client
            .database
            .from("users")
            .update(update)
            .eq("id", value: user.id.uuidString)
            .execute()
    }

    // Fetch a user by email from Supabase
    func fetchUser(email: String) async throws -> AppUser {
        struct UserRecord: Codable {
            let id: UUID
            let email: String
            let name: String?
            let avatar_seed: String?
        }
        
        let record: UserRecord = try await client
            .database
            .from("users")
            .select()
            .eq("email", value: email)
            .single()
            .execute()
            .value
        
        return AppUser(
            id: record.id,
            name: record.name ?? "Unknown",
            email: record.email,
            avatarSeed: record.avatar_seed ?? "person.fill",
            followers: 0,
            following: 0
        )
    }

    // Update profile name
    func updateName(session: SessionManager, newName: String) async throws {
        guard let user = session.currentUser else { return }
        
        session.updateProfile(name: newName)
        
        // Sync to Supabase
        do {
            struct NameUpdate: Codable {
                let name: String
            }
            _ = try await client
                .database
                .from("users")
                .update(NameUpdate(name: newName))
                .eq("id", value: user.id.uuidString)
                .execute()
        } catch {
            print("⚠️ Failed to update name in Supabase:", error.localizedDescription)
        }
    }

    // Update avatar
    func updateAvatar(session: SessionManager, seed: String) async throws {
        guard let user = session.currentUser else { return }
        
        session.updateAvatar(seed: seed)
        
        // Sync to Supabase
        do {
            struct AvatarUpdate: Codable {
                let avatar_seed: String
            }
            _ = try await client
                .database
                .from("users")
                .update(AvatarUpdate(avatar_seed: seed))
                .eq("id", value: user.id.uuidString)
                .execute()
        } catch {
            print("⚠️ Failed to update avatar in Supabase:", error.localizedDescription)
        }
    }
}
