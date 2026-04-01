import Foundation
import Supabase
import Observation

// MARK: - AuthService

/// Uygulamanın yetkilendirme (Authentication) işlemlerini yöneten servis.
/// Giriş yapma, kayıt olma, çıkış yapma ve aktif oturumu takip etme işlemlerinden sorumludur.
@Observable
final class AuthService {
    
    // Singleton instance (Opsiyonel olarak Dependency Injection da kullanılabilir)
    static let shared = AuthService()
    
    /// Aktif Supabase session'ı (oturum token'ları vb.)
    private(set) var currentSession: Session?
    
    /// Sisteme giriş yapmış aktif kullanıcı objesi (Email vb. içerir)
    private(set) var currentUser: Supabase.User?
    
    /// Oturum doğrulama durumu. (Uygulama ilk açıldığında kontrol sürerken true olabilir)
    var isCheckingSession: Bool = true
    
    /// Kullanıcının giriş yapıp yapmadığını basitçe kontrol eden computed property
    var isAuthenticated: Bool {
        return currentUser != nil
    }
    
    private let client = SupabaseManager.shared.client
    
    private init() {
        // Obje oluştuğunda hemen önceden kalmış bir oturum var mı diye kontrol et (app launch'ta)
        Task {
            await verifySession()
        }
    }
    
    // MARK: - Auth Methods
    
    /// Email ve şifre ile yeni hesap oluşturur
    func signUp(email: String, password: String) async throws {
        _ = try await client.auth.signUp(
            email: email,
            password: password
        )
        // Signup olduğunda çoğu zaman Auth Confirmed olmadan aktif sayılmaz (mail onayı kapalıysa anında giriş yapar)
        // İşlemin sonucunda session durumunu tekrar güncelleyelim.
        await verifySession()
    }
    
    /// Email ve şifre ile giriş yapar
    func signIn(email: String, password: String) async throws {
        _ = try await client.auth.signIn(
            email: email,
            password: password
        )
        await verifySession()
    }
    
    /// Aktif hesaptan çıkış yapar
    func signOut() async throws {
        try await client.auth.signOut()
        
        // Çıkış sonrası state'leri sıfırla
        await MainActor.run {
            self.currentUser = nil
            self.currentSession = nil
        }
    }
    
    // MARK: - OAuth & Advanced
    
    /// Web tabanlı Google girişi başlatır
    func getGoogleOAuthURL() async throws -> URL {
        return try await client.auth.getOAuthSignInURL(
            provider: .google,
            redirectTo: URL(string: "turnike://auth-callback")
        )
    }
    
    /// Web Authentication Session'dan dönen URL'i alıp oturumu doğrular
    func handleOAuthRedirect(url: URL) async throws {
        try await client.auth.session(from: url)
        await verifySession()
    }
    
    /// Apple'ın native olarak döneceği ID Token ile oturum açar
    func signInWithApple(idToken: String, nonce: String, fullName: String?) async throws {
        _ = try await client.auth.signInWithIdToken(
            credentials: .init(provider: .apple, idToken: idToken, nonce: nonce)
        )
        await verifySession()
    }
    
    /// Hesabı Supabase RPC kullanarak GERÇEKTEN siler
    func deleteAccount() async throws {
        // SQL Editor'de tanımlanacak "delete_user" PostgreSQL fonksiyonunu çağırıyoruz
        try await client.rpc("delete_user").execute()
        
        // Silme sonrası çıkış yapmış sayılırız
        await MainActor.run {
            self.currentUser = nil
            self.currentSession = nil
        }
    }
    
    // MARK: - Session Verification
    
    /// Uygulama her açıldığında Supabase Auth'taki güncel oturumu doğrular ve objeleri günceller
    @MainActor
    private func verifySession() async {
        isCheckingSession = true
        defer { isCheckingSession = false }
        
        do {
            let session = try await client.auth.session
            self.currentSession = session
            self.currentUser = session.user
            print("AuthService: Aktif oturum bulundu. Kullanıcı: \(session.user.email ?? "Bilinmiyor")")
        } catch {
            // Eğer bir session bulunamazsa veya geçerliliğini yitirdiyse buraları nil yaparız
            self.currentSession = nil
            self.currentUser = nil
            print("AuthService: Oturum yok veya geçersiz.")
        }
    }
}
