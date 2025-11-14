// sarapio/Repositories/UserRepo.swift
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
            // Check if user exists
            let response = try await client
                .database
                .from("users")
                .select()
                .eq("email", value: email)
                .single()
                .execute()
            
            // User exists, update if needed
            if response.data != nil {
                try await updateUser(user: currentUser)
            }
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
        let userDict: [String: Any] = [
            "id": user.id.uuidString,
            "email": user.email,
            "name": user.name,
            "avatar_seed": user.avatarSeed
        ]
        
        _ = try await client
            .database
            .from("users")
            .insert([userDict])
            .execute()
    }
    
    private func updateUser(user: AppUser) async throws {
        let userDict: [String: Any] = [
            "name": user.name,
            "avatar_seed": user.avatarSeed
        ]
        
        _ = try await client
            .database
            .from("users")
            .update(userDict)
            .eq("id", value: user.id.uuidString)
            .execute()
    }

    // Fetch a user by email from Supabase
    func fetchUser(email: String) async throws -> AppUser {
        let response = try await client
            .database
            .from("users")
            .select()
            .eq("email", value: email)
            .single()
            .execute()
        
        if let data = response.data,
           let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            let id = UUID(uuidString: json["id"] as? String ?? "") ?? UUID()
            let name = json["name"] as? String ?? "Unknown"
            let email = json["email"] as? String ?? ""
            let avatarSeed = json["avatar_seed"] as? String ?? "person.fill"
            
            return AppUser(
                id: id,
                name: name,
                email: email,
                avatarSeed: avatarSeed,
                followers: 0,
                following: 0
            )
        }
        
        throw NSError(domain: "UserRepo", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
    }

    // Update profile name
    func updateName(session: SessionManager, newName: String) async throws {
        guard let user = session.currentUser else { return }
        
        session.updateProfile(name: newName)
        
        // Sync to Supabase
        do {
            _ = try await client
                .database
                .from("users")
                .update(["name": newName])
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
            _ = try await client
                .database
                .from("users")
                .update(["avatar_seed": seed])
                .eq("id", value: user.id.uuidString)
                .execute()
        } catch {
            print("⚠️ Failed to update avatar in Supabase:", error.localizedDescription)
        }
    }
}
