import Foundation

// MARK: - CheckIn

/// Kullanıcının bir metro hattına giriş kaydı.
/// Check-in aktifken kullanıcı "nearby" listesinde görünür.
/// `isExpired` computed property ile zaman aşımı otomatik kontrol edilir.
struct CheckIn: Identifiable, Codable, Hashable {

    let id: UUID
    let userId: UUID
    let line: MetroLine
    var direction: String          // Yön (terminus istasyon adı)
    var currentStation: String     // Şu anki durak
    var wagonNumber: Int?          // Opsiyonel vagon numarası
    var doorNumber: Int?           // Opsiyonel kapı numarası
    let privacyMode: PrivacyMode
    let checkInTime: Date
    var checkOutTime: Date?
    var isActive: Bool

    /// Zaman aşımı süresi (saniye). Varsayılan: 45 dakika.
    static let timeoutInterval: TimeInterval = 45 * 60

    init(
        id: UUID = UUID(),
        userId: UUID,
        line: MetroLine,
        direction: String,
        currentStation: String,
        wagonNumber: Int? = nil,
        doorNumber: Int? = nil,
        privacyMode: PrivacyMode = .instant,
        checkInTime: Date = .now,
        checkOutTime: Date? = nil,
        isActive: Bool = true
    ) {
        self.id = id
        self.userId = userId
        self.line = line
        self.direction = direction
        self.currentStation = currentStation
        self.wagonNumber = wagonNumber
        self.doorNumber = doorNumber
        self.privacyMode = privacyMode
        self.checkInTime = checkInTime
        self.checkOutTime = checkOutTime
        self.isActive = isActive
    }

    // MARK: - Computed Properties

    /// Check-in süresi dolmuş mu?
    var isExpired: Bool {
        guard isActive else { return true }
        if checkOutTime != nil { return true }
        return Date.now.timeIntervalSince(checkInTime) > Self.timeoutInterval
    }

    /// Kullanıcının aktif süresini döner.
    var activeDuration: TimeInterval {
        let end = checkOutTime ?? .now
        return end.timeIntervalSince(checkInTime)
    }

    /// Vagon/kapı bilgisini okunabilir formatta döner.
    var locationDetail: String? {
        var parts: [String] = []
        if let wagon = wagonNumber { parts.append("Vagon \(wagon)") }
        if let door = doorNumber { parts.append("Kapı \(door)") }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    // MARK: - Mutations

    /// "İndim" aksiyonu — check-out yapar ve profili pasifleştirir.
    mutating func checkOut() {
        checkOutTime = .now
        isActive = false
    }
}
