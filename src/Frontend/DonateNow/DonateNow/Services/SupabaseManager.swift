import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        let url = Constants.supabaseURL
        let key = Constants.supabaseAnonKey
        print("DEBUG - Supabase URL string: '\(url.absoluteString)'")
        print("DEBUG - Supabase URL host: '\(url.host ?? "nil")'")
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: key,
            options: SupabaseClientOptions(
                auth: .init(emitLocalSessionAsInitialSession: true)
            )
        )
    }
}
