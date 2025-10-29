import Supabase
import Foundation

final class SupabaseClientManager {
    static let shared = SupabaseClient(
        supabaseURL: URL(string: "https://tmrdvhvhvcfmijvjkzytv.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRtcmR2aGh2Y2ZpbWp2amt6eXR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE2NDQ2NDYsImV4cCI6MjA3NzIyMDY0Nn0.Lw_4oN4XlXlN4ZiV5n-T11J0julBccCdJPHm533b2yo"
    )
}
