import Foundation

// MARK: - APIClient Protocol

/// Sunucu ile iletişim soyutlaması.
/// Gerçek backend entegrasyonu yapılana kadar `MockAPIClient` kullanılır.
protocol APIClient: Sendable {

    /// Offline kuyruktaki aksiyonları toplu olarak sunucuya gönderir.
    func syncActions(_ actions: [OfflineAction]) async throws -> [UUID]

    /// Belirli bir hattaki aktif kullanıcıları ve check-in'leri çeker.
    func fetchNearbyUsers(line: MetroLine) async throws -> (users: [User], checkIns: [CheckIn])

    /// Yeni check-in oluşturur.
    func checkIn(_ checkIn: CheckIn) async throws -> CheckIn

    /// Check-out yapar.
    func checkOut(checkInId: UUID) async throws
}

// MARK: - MockAPIClient

/// Geliştirme ortamı için sahte API istemcisi.
/// Gerçekçi gecikmeler ve örnek verilerle çalışır.
final class MockAPIClient: APIClient, @unchecked Sendable {

    static let shared = MockAPIClient()

    private init() {}

    // MARK: - Simulated Delay

    private func simulateNetworkDelay() async {
        let delay = UInt64.random(in: 200_000_000...800_000_000) // 200ms - 800ms
        try? await Task.sleep(nanoseconds: delay)
    }

    // MARK: - Sync

    func syncActions(_ actions: [OfflineAction]) async throws -> [UUID] {
        await simulateNetworkDelay()
        // Başarıyla senkronize edilmiş gibi tüm ID'leri döner
        return actions.map { $0.id }
    }

    // MARK: - Fetch Nearby

    func fetchNearbyUsers(line: MetroLine) async throws -> (users: [User], checkIns: [CheckIn]) {
        await simulateNetworkDelay()

        // Sahte kullanıcılar
        let mockUsers = Self.generateMockUsers(count: Int.random(in: 3...8))
        let mockCheckIns = mockUsers.map { user in
            CheckIn(
                userId: user.id,
                line: line,
                direction: line.directions.end,
                currentStation: line.stations.randomElement() ?? line.stations[0],
                wagonNumber: Bool.random() ? Int.random(in: 1...8) : nil,
                doorNumber: Bool.random() ? Int.random(in: 1...4) : nil,
                privacyMode: .instant
            )
        }

        return (users: mockUsers, checkIns: mockCheckIns)
    }

    // MARK: - Check-in / Check-out

    func checkIn(_ checkIn: CheckIn) async throws -> CheckIn {
        await simulateNetworkDelay()
        return checkIn
    }

    func checkOut(checkInId: UUID) async throws {
        await simulateNetworkDelay()
    }

    // MARK: - Mock Data Generators

    private static let mockNames = [
        "Elif", "Berk", "Zeynep", "Can", "Defne",
        "Emre", "Selin", "Kaan", "Ayşe", "Burak",
        "Deniz", "Arda", "Merve", "Onur", "Ceren"
    ]

    private static let mockBios = [
        "Kahve tutkunu ☕️",
        "Müzik & kitap 🎵📚",
        "İstanbul'u keşfediyorum 🌆",
        "Yazılımcı 💻",
        "Fotoğraf meraklısı 📸",
        "Yeni insanlarla tanışmayı seviyorum 👋",
        "Kedileri severim 🐱",
        "Yolculuk en güzel macera 🚇",
    ]

    private static let mockInterests = [
        "Kahve", "Sinema", "Müzik", "Kitap", "Seyahat",
        "Fotoğrafçılık", "Yemek", "Spor", "Teknoloji", "Sanat",
        "Doğa", "Yoga", "Dans", "Tiyatro", "Podcast"
    ]

    static func generateMockUsers(count: Int) -> [User] {
        (0..<count).map { _ in
            let randomAge = Int.random(in: 20...35)
            let birthDate = Calendar.current.date(byAdding: .year, value: -randomAge, to: .now) ?? .now
            return User(
                displayName: mockNames.randomElement()!,
                birthDate: birthDate,
                bio: mockBios.randomElement()!,
                gender: Gender.allCases.randomElement()!,
                interests: Array(mockInterests.shuffled().prefix(Int.random(in: 2...5))),
                privacyMode: Bool.random() ? .instant : .calm
            )
        }
    }
}
