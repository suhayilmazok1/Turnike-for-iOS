import Foundation
import Supabase

// MARK: - SupabaseManager

/// Supabase Client'ına uygulama genelinde güvenli şekilde erişmek için Singleton yönetimi.
final class SupabaseManager {
    
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: Secrets.supabaseURL,
            supabaseKey: Secrets.supabaseAnonKey
        )
    }
}
