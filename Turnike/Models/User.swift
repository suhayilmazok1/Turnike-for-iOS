import Foundation

// MARK: - User

/// Turnike kullanıcı profili.
/// Offline-first mimaride yerel cache'de saklanır ve durak senkronizasyonlarında güncellenir.
struct User: Identifiable, Codable, Hashable {

    let id: UUID
    var displayName: String
    var bio: String
    var age: Int
    var photoFileNames: [String]
    var gender: Gender
    var interests: [String]
    var prompts: [ProfilePrompt]
    var privacyMode: PrivacyMode
    let createdAt: Date
    var lastActiveAt: Date

    /// İlk fotoğrafa kolay erişim (eski API uyumu).
    var primaryPhotoFileName: String? {
        photoFileNames.first
    }

    init(
        id: UUID = UUID(),
        displayName: String,
        bio: String = "",
        age: Int,
        photoFileNames: [String] = [],
        gender: Gender,
        interests: [String] = [],
        prompts: [ProfilePrompt] = [],
        privacyMode: PrivacyMode = .instant,
        createdAt: Date = .now,
        lastActiveAt: Date = .now
    ) {
        self.id = id
        self.displayName = displayName
        self.bio = bio
        self.age = age
        self.photoFileNames = photoFileNames
        self.gender = gender
        self.interests = interests
        self.prompts = prompts
        self.privacyMode = privacyMode
        self.createdAt = createdAt
        self.lastActiveAt = lastActiveAt
    }
}

// MARK: - ProfilePrompt

/// Profil prompt'u — soru ve cevap çifti.
struct ProfilePrompt: Codable, Hashable, Identifiable {
    var id: UUID = UUID()
    var question: String
    var answer: String

    /// Uygulamadaki önceden tanımlı prompt soruları.
    static let availableQuestions: [String] = [
        "Metro'da en sevdiğim an...",
        "Bu hatta binmemin sebebi...",
        "Kulaklığımda şu an...",
        "Haftasonu planım genelde...",
        "İstanbul'un en güzel durağı...",
        "Bir süper gücüm olsa...",
        "Beni güldüren şey...",
        "Hayalimdeki metro arkadaşı..."
    ]
}

// MARK: - Predefined Interests

/// Onboarding'de seçilebilecek ilgi alanları.
enum PredefinedInterest: String, CaseIterable {
    case music = "Müzik"
    case movies = "Sinema"
    case books = "Kitap"
    case travel = "Seyahat"
    case food = "Yemek"
    case coffee = "Kahve"
    case sports = "Spor"
    case gaming = "Oyun"
    case art = "Sanat"
    case photography = "Fotoğrafçılık"
    case yoga = "Yoga"
    case tech = "Teknoloji"
    case nature = "Doğa"
    case cooking = "Yemek Yapma"
    case dancing = "Dans"
    case fashion = "Moda"
    case pets = "Evcil Hayvan"
    case fitness = "Fitness"
    case writing = "Yazarlık"
    case nightlife = "Gece Hayatı"

    var icon: String {
        switch self {
        case .music:       return "🎵"
        case .movies:      return "🎬"
        case .books:       return "📚"
        case .travel:      return "✈️"
        case .food:        return "🍕"
        case .coffee:      return "☕"
        case .sports:      return "⚽"
        case .gaming:      return "🎮"
        case .art:         return "🎨"
        case .photography: return "📸"
        case .yoga:        return "🧘"
        case .tech:        return "💻"
        case .nature:      return "🌿"
        case .cooking:     return "👨‍🍳"
        case .dancing:     return "💃"
        case .fashion:     return "👗"
        case .pets:        return "🐾"
        case .fitness:     return "💪"
        case .writing:     return "✍️"
        case .nightlife:   return "🌙"
        }
    }
}

// MARK: - PrivacyMode

/// Kullanıcının bildirim gizlilik tercihi.
/// - `instant`: Eşleşmeler ve beğeniler anında (duraktayken) bildirim olarak düşer.
/// - `calm(delayMinutes:)`: Bildirimler check-out sonrası belirli dakika sonra topluca gelir.
enum PrivacyMode: Codable, Hashable {
    case instant
    case calm(delayMinutes: Int)

    var displayName: String {
        switch self {
        case .instant:
            return "Anlık Mod"
        case .calm(let minutes):
            return "Sakin Mod (\(minutes) dk)"
        }
    }

    /// Varsayılan gecikme süresi (dakika).
    static let defaultCalmDelay: Int = 15
}

// MARK: - Gender

enum Gender: String, Codable, CaseIterable, Hashable {
    case male = "male"
    case female = "female"
    case nonBinary = "non_binary"
    case other = "other"
    case preferNotToSay = "prefer_not_to_say"

    var displayName: String {
        switch self {
        case .male:           return "Erkek"
        case .female:         return "Kadın"
        case .nonBinary:      return "Non-Binary"
        case .other:          return "Diğer"
        case .preferNotToSay: return "Belirtmek İstemiyorum"
        }
    }
}
