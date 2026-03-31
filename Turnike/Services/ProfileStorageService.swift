import Foundation
#if canImport(UIKit)
import UIKit
#endif

// MARK: - ProfileStorageService

/// Kullanıcı profilini yerel olarak saklar.
/// Fotoğraflar Documents/ProfilePhotos/ dizinine, profil JSON olarak UserDefaults'a kaydedilir.
final class ProfileStorageService {

    static let shared = ProfileStorageService()

    private let profileKey = "turnike_user_profile"
    private let onboardingCompleteKey = "turnike_onboarding_complete"
    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Onboarding Status

    var isOnboardingComplete: Bool {
        defaults.bool(forKey: onboardingCompleteKey)
    }

    func markOnboardingComplete() {
        defaults.set(true, forKey: onboardingCompleteKey)
    }

    // MARK: - Profile CRUD

    func saveProfile(_ user: User) {
        if let data = try? JSONEncoder().encode(user) {
            defaults.set(data, forKey: profileKey)
        }
    }

    func loadProfile() -> User? {
        guard let data = defaults.data(forKey: profileKey) else { return nil }
        return try? JSONDecoder().decode(User.self, from: data)
    }

    func clearProfile() {
        defaults.removeObject(forKey: profileKey)
        defaults.set(false, forKey: onboardingCompleteKey)
        clearAllPhotos()
    }

    // MARK: - Photo Storage

    /// Fotoğrafları Documents/ProfilePhotos/ dizinine kaydeder.
    private var photosDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("ProfilePhotos", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    #if canImport(UIKit)
    /// Fotoğrafı diske kaydeder ve dosya adını döndürür.
    func savePhoto(_ image: UIImage, index: Int) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let fileName = "profile_photo_\(index)_\(UUID().uuidString.prefix(8)).jpg"
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: fileURL)
            return fileName
        } catch {
            print("❌ Fotoğraf kaydedilemedi: \(error)")
            return nil
        }
    }

    /// Kaydedilmiş fotoğrafı yükler.
    func loadPhoto(named fileName: String) -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        return UIImage(data: data)
    }
    #endif

    /// Tüm fotoğrafları siler.
    func clearAllPhotos() {
        try? FileManager.default.removeItem(at: photosDirectory)
    }

    /// Belirli bir fotoğrafı siler.
    func deletePhoto(named fileName: String) {
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: fileURL)
    }
}
