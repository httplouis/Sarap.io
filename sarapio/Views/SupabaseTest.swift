import SwiftUI
import Supabase

struct SupabaseTest: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("🔗 Supabase Connection Test")
                .font(.headline)

            Button("Test Connection") {
                Task {
                    await testConnection()
                }
            }
        }
        .padding()
    }

    func testConnection() async {
        let client = SupabaseClientManager.shared
        do {
            let response = try await client
                .database
                .from("recipes")
                .select()
                .limit(1)
                .execute()

            print("✅ Connection OK:", response)
        } catch {
            print("❌ Connection failed:", error.localizedDescription)
        }
    }
}
