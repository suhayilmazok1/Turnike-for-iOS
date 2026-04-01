import Foundation
import Supabase

// MARK: - DatabaseService

/// Supabase PostgreSQL (PostgREST) API'si ile haberleşerek veritabanı okuma/yazma (CRUD)
/// işlemlerini yöneten servis.
final class DatabaseService {
    
    // Singleton Instance
    static let shared = DatabaseService()
    private let client = SupabaseManager.shared.client
    
    private init() {}
    
    // MARK: - Profiles (Kullanıcı Profilleri)
    
    /// Sisteme giriş yapmış aktif kullanıcının (kendi) ID'sini döner
    private func getCurrentUserId() throws -> UUID {
        guard let id = AuthService.shared.currentUser?.id else {
            throw DatabaseError.notAuthenticated
        }
        return id
    }
    
    /// Supabase 'profiles' tablosunda yeni profil oluşturur (Insert)
    func createProfile(_ user: User) async throws {
        // RLS kuralına göre user.id == auth.uid() olmak zorundadır.
        try await client
            .from("profiles")
            .insert(user)
            .execute()
    }
    
    /// Verilen UUID'ye ait profili getirir (Read)
    func getProfile(id: UUID) async throws -> User {
        let response: User = try await client
            .from("profiles")
            .select()
            .eq("id", value: id.uuidString)
            .single()
            .execute()
            .value
            
        return response
    }
    
    /// Sisteme giriş yapmış kullanıcının kendi profilini çeker
    func getCurrentUserProfile() async throws -> User {
        let userId = try getCurrentUserId()
        return try await getProfile(id: userId)
    }
    
    /// Veritabanındaki kendi profilimizi günceller (Update)
    func updateProfile(_ user: User) async throws {
        let userId = try getCurrentUserId()
        
        // Sadece kendisini güncelleyebilir (RLS kuralı koruyor)
        try await client
            .from("profiles")
            .update(user)
            .eq("id", value: userId.uuidString)
            .execute()
    }
}

// MARK: - Errors

enum DatabaseError: Error, LocalizedError {
    case notAuthenticated
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "Veritabanı işlemi için giriş yapmış olmalısınız."
        }
    }
}
