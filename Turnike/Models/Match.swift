import Foundation

// MARK: - Match

/// İki kullanıcı arasındaki eşleşme kaydı.
/// Offline sırasında oluşturulabilir; sunucuyla senkronize edildiğinde doğrulanır.
struct Match: Identifiable, Codable, Hashable {

    let id: UUID
    let users: UserPair
    let line: MetroLine
    let station: String?            // Eşleşmenin gerçekleştiği durak (biliniyorsa)
    let matchedAt: Date
    var status: MatchStatus

    init(
        id: UUID = UUID(),
        users: UserPair,
        line: MetroLine,
        station: String? = nil,
        matchedAt: Date = .now,
        status: MatchStatus = .pending
    ) {
        self.id = id
        self.users = users
        self.line = line
        self.station = station
        self.matchedAt = matchedAt
        self.status = status
    }

    /// Eşleşmede belirli bir kullanıcının karşı tarafını döner.
    func otherUser(than userId: UUID) -> UUID {
        users.initiatorId == userId ? users.targetId : users.initiatorId
    }
}

// MARK: - UserPair

/// Eşleşen iki kullanıcının ID çifti.
struct UserPair: Codable, Hashable {
    let initiatorId: UUID    // Beğeniyi başlatan
    let targetId: UUID       // Beğenilen kişi
}

// MARK: - MatchStatus

/// Eşleşme durumu yaşam döngüsü.
enum MatchStatus: String, Codable, CaseIterable, Hashable {

    /// Tek taraflı beğeni — karşı tarafın onayı bekleniyor.
    case pending = "pending"

    /// Karşılıklı beğeni — eşleşme tamamlandı.
    case matched = "matched"

    /// Süre doldu — beğeni zaman aşımına uğradı.
    case expired = "expired"

    /// Kaçırılan fırsat — her iki taraf da birbirini beğenmiş ama
    /// check-out'lar örtüşmemiş (retroaktif eşleşme olasılığı).
    case missed = "missed"

    var displayName: String {
        switch self {
        case .pending: return "Beklemede"
        case .matched: return "Eşleşme!"
        case .expired: return "Süresi Doldu"
        case .missed:  return "Kaçırılan Fırsat"
        }
    }

    var isResolved: Bool {
        self == .matched || self == .expired
    }
}
