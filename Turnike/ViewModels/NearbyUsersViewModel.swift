import Foundation

// MARK: - NearbyUsersViewModel

/// Yakındaki kullanıcıları yöneten ViewModel.
/// CacheManager'dan veri çeker, beğeni/mesaj aksiyonlarını offline kuyruğa ekler.
@Observable
final class NearbyUsersViewModel {

    // MARK: - State

    private(set) var users: [User] = []
    private(set) var checkIns: [CheckIn] = []
    private(set) var isLoading: Bool = false
    private(set) var lastRefreshTime: Date?

    var currentLine: MetroLine?

    // MARK: - Dependencies

    private let syncManager: SyncManager
    private let cacheManager: CacheManager
    private let userId: UUID

    init(
        syncManager: SyncManager = .shared,
        cacheManager: CacheManager = .shared,
        userId: UUID = UUID()
    ) {
        self.syncManager = syncManager
        self.cacheManager = cacheManager
        self.userId = userId
    }

    // MARK: - Computed

    var pendingSyncCount: Int {
        syncManager.pendingActionCount
    }

    var isConnected: Bool {
        syncManager.isConnected
    }

    var isEmpty: Bool {
        users.isEmpty
    }

    var userCount: Int {
        users.count
    }

    // MARK: - Data Loading

    /// Cache'den yakındaki kullanıcıları yükler.
    func loadCachedUsers() async {
        guard let line = currentLine else { return }

        isLoading = true
        defer { isLoading = false }

        users = await cacheManager.getCachedUsers(for: line)
        checkIns = await cacheManager.getCachedCheckIns(for: line)

        // Kendi check-in'imizi filtrele
        users = users.filter { $0.id != userId }
        checkIns = checkIns.filter { $0.userId != userId }

        lastRefreshTime = await cacheManager.lastCacheTime(for: line)
    }

    /// Sunucudan çekip cache'i günceller (online olduğunda).
    func refreshFromServer() async {
        guard let line = currentLine, isConnected else { return }

        isLoading = true
        defer { isLoading = false }

        await syncManager.pullNearbyUsers(for: line)
        await loadCachedUsers()
    }

    // MARK: - User Actions

    /// Kullanıcıyı beğenir — offline kuyruğa ekler.
    func like(user: User) async {
        await syncManager.enqueueLike(userId: userId, targetUserId: user.id)
    }

    /// Süper beğeni — offline kuyruğa ekler.
    func superLike(user: User) async {
        await syncManager.enqueueSuperLike(userId: userId, targetUserId: user.id)
    }

    /// Kullanıcıya mesaj gönderir — offline kuyruğa ekler.
    func sendMessage(to user: User, message: String) async {
        await syncManager.enqueueMessage(userId: userId, targetUserId: user.id, message: message)
    }

    /// Kullanıcıyı pas geçer (lokal aksiyon, sunucuya gitmez).
    func skip(user: User) {
        users.removeAll { $0.id == user.id }
        checkIns.removeAll { $0.userId == user.id }
    }

    /// Check-out — profili kaldırır.
    func checkOut() async {
        await syncManager.enqueueCheckOut(userId: userId)
        users.removeAll()
        checkIns.removeAll()
        currentLine = nil
    }

    // MARK: - Helpers

    /// Belirli bir kullanıcının check-in bilgisini döner.
    func checkIn(for user: User) -> CheckIn? {
        checkIns.first { $0.userId == user.id }
    }
}
