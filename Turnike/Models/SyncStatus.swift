import Foundation

// MARK: - OfflineAction

/// Tünelde (offline) yapılan aksiyonların sıraya alınmış hali.
/// Cihaz durağa gelip bağlantı kurduğunda topluca (batch sync) sunucuya gönderilir.
struct OfflineAction: Identifiable, Codable, Hashable {

    let id: UUID
    let userId: UUID
    let type: ActionType
    let targetUserId: UUID?        // Beğeni/mesaj hedefi (check-in/out için nil)
    let payload: String?           // Mesaj içeriği veya ek veri (JSON string)
    let createdAt: Date
    var syncStatus: SyncStatus
    var lastSyncAttempt: Date?
    var retryCount: Int

    /// Maksimum yeniden deneme sayısı.
    static let maxRetries: Int = 3

    init(
        id: UUID = UUID(),
        userId: UUID,
        type: ActionType,
        targetUserId: UUID? = nil,
        payload: String? = nil,
        createdAt: Date = .now,
        syncStatus: SyncStatus = .pending,
        lastSyncAttempt: Date? = nil,
        retryCount: Int = 0
    ) {
        self.id = id
        self.userId = userId
        self.type = type
        self.targetUserId = targetUserId
        self.payload = payload
        self.createdAt = createdAt
        self.syncStatus = syncStatus
        self.lastSyncAttempt = lastSyncAttempt
        self.retryCount = retryCount
    }

    // MARK: - Computed

    /// Yeniden denenebilir mi?
    var canRetry: Bool {
        syncStatus == .failed && retryCount < Self.maxRetries
    }

    // MARK: - Mutations

    /// Senkronizasyon denemesi başlat.
    mutating func markSyncing() {
        syncStatus = .syncing
        lastSyncAttempt = .now
    }

    /// Başarılı senkronizasyon.
    mutating func markSynced() {
        syncStatus = .synced
    }

    /// Başarısız senkronizasyon.
    mutating func markFailed() {
        syncStatus = .failed
        retryCount += 1
    }
}

// MARK: - ActionType

/// Offline kuyrukta tutulabilecek aksiyon tipleri.
enum ActionType: String, Codable, CaseIterable, Hashable {
    case like       = "like"
    case superLike  = "super_like"
    case message    = "message"
    case checkIn    = "check_in"
    case checkOut   = "check_out"

    var displayName: String {
        switch self {
        case .like:      return "Beğeni"
        case .superLike: return "Süper Beğeni"
        case .message:   return "Mesaj"
        case .checkIn:   return "Check-in"
        case .checkOut:  return "Check-out"
        }
    }

    /// Hedef kullanıcı gerektiren aksiyon mu?
    var requiresTarget: Bool {
        switch self {
        case .like, .superLike, .message: return true
        case .checkIn, .checkOut:         return false
        }
    }
}

// MARK: - SyncStatus

/// Offline aksiyonun senkronizasyon durumu.
enum SyncStatus: String, Codable, CaseIterable, Hashable {
    case pending  = "pending"   // Sırada bekliyor
    case syncing  = "syncing"   // Gönderiliyor
    case synced   = "synced"    // Başarıyla gönderildi
    case failed   = "failed"    // Başarısız — retry olabilir

    var displayName: String {
        switch self {
        case .pending: return "Beklemede"
        case .syncing: return "Senkronize Ediliyor"
        case .synced:  return "Gönderildi"
        case .failed:  return "Başarısız"
        }
    }
}
