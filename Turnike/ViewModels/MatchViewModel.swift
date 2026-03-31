import Foundation

// MARK: - MatchViewModel

/// Eşleşmeleri yöneten ViewModel.
/// Aktif, bekleyen ve kaçırılan eşleşmeleri listeler.
@Observable
final class MatchViewModel {

    // MARK: - State

    private(set) var matches: [Match] = []
    private(set) var isLoading: Bool = false

    // MARK: - Dependencies

    private let userId: UUID

    init(userId: UUID = UUID()) {
        self.userId = userId
    }

    // MARK: - Filtered Lists

    /// Aktif eşleşmeler (karşılıklı beğeni).
    var activeMatches: [Match] {
        matches.filter { $0.status == .matched }
    }

    /// Bekleyen beğeniler (tek taraflı).
    var pendingMatches: [Match] {
        matches.filter { $0.status == .pending }
    }

    /// Kaçırılan fırsatlar.
    var missedMatches: [Match] {
        matches.filter { $0.status == .missed }
    }

    /// Süresi dolmuş eşleşmeler.
    var expiredMatches: [Match] {
        matches.filter { $0.status == .expired }
    }

    var activeCount: Int { activeMatches.count }
    var pendingCount: Int { pendingMatches.count }
    var missedCount: Int { missedMatches.count }

    // MARK: - Actions

    /// Eşleşmeleri yükler (şimdilik mock data).
    func loadMatches() async {
        isLoading = true
        defer { isLoading = false }

        // TODO: Gerçek API entegrasyonunda CacheManager / APIClient'tan çekilecek
        matches = Self.generateMockMatches(userId: userId)
    }

    /// Eşleşmenin karşı tarafının ID'sini döner.
    func otherUserId(in match: Match) -> UUID {
        match.otherUser(than: userId)
    }

    // MARK: - Mock Data

    private static func generateMockMatches(userId: UUID) -> [Match] {
        let statuses: [MatchStatus] = [.matched, .matched, .pending, .pending, .missed, .expired]
        let lines: [MetroLine] = [.m2, .m5, .marmaray, .m4, .m7, .m1a]

        return zip(statuses, lines).map { status, line in
            Match(
                users: UserPair(initiatorId: userId, targetId: UUID()),
                line: line,
                station: line.stations.randomElement(),
                matchedAt: Date.now.addingTimeInterval(-Double.random(in: 300...7200)),
                status: status
            )
        }
    }
}
