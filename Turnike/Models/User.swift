import Foundation

// MARK: - User

/// Turnike kullanıcı profili.
/// Offline-first mimaride yerel cache'de saklanır ve durak senkronizasyonlarında güncellenir.
struct User: Identifiable, Codable, Hashable {

    let id: UUID
    var displayName: String
    var birthDate: Date
    var bio: String?
    var photoUrls: [String]?
    var gender: Gender
    var interests: [String]?
    var prompts: [ProfilePrompt]?
    var privacyMode: PrivacyMode
    let createdAt: Date
    
    // Geçmiş API (yerel depolama) uyumluluğu için computed property
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: .now).year ?? 0
    }

    /// İlk fotoğrafa kolay erişim (eski API uyumu).
    var primaryPhotoFileName: String? {
        photoUrls?.first
    }
    
    // Supabase tablosu ile birebir eşleşme için CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case displayName = "display_name"
        case birthDate = "birth_date"
        case gender
        case bio
        case interests
        case photoUrls = "photo_urls"
        case prompts
        case privacyMode = "privacy_mode"
        case createdAt = "created_at"
    }

    init(
        id: UUID = UUID(),
        displayName: String,
        birthDate: Date,
        bio: String? = nil,
        photoUrls: [String]? = nil,
        gender: Gender,
        interests: [String]? = nil,
        prompts: [ProfilePrompt]? = nil,
        privacyMode: PrivacyMode = .instant,
        createdAt: Date = .now
    ) {
        self.id = id
        self.displayName = displayName
        self.birthDate = birthDate
        self.bio = bio
        self.photoUrls = photoUrls
        self.gender = gender
        self.interests = interests
        self.prompts = prompts
        self.privacyMode = privacyMode
        self.createdAt = createdAt
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
/// - `instant`: Eşleşmeler ve anlık bildirimler düşer.
/// - `calm`: Bildirimler check-out sonrasına ertelenir.
enum PrivacyMode: String, Codable, Hashable {
    case instant = "instant"
    case calm = "calm"

    var displayName: String {
        switch self {
        case .instant:
            return "Anlık Mod"
        case .calm:
            return "Sakin Mod"
        }
    }
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
