import Foundation

// MARK: - SyncManager

/// Offline-first senkronizasyon orkestratörü.
/// Tünelde biriken aksiyonları durakta toplu (batch) olarak sunucuya gönderir.
/// Aynı zamanda yakındaki kullanıcı cache'ini günceller.
@Observable
final class SyncManager {

    // MARK: - Singleton

    static let shared = SyncManager()

    // MARK: - Dependencies

    private let networkMonitor: NetworkMonitor
    private let actionStore: OfflineActionStore
    private let cacheManager: CacheManager
    private let apiClient: APIClient

    // MARK: - Published State

    private(set) var isSyncing: Bool = false
    private(set) var pendingActionCount: Int = 0
    private(set) var lastSyncTime: Date?
    private(set) var lastSyncError: String?

    /// Aktif check-in hattı — cache güncellemesi için.
    var activeLine: MetroLine?

    // MARK: - Init

    init(
        networkMonitor: NetworkMonitor = NetworkMonitor(),
        actionStore: OfflineActionStore = .shared,
        cacheManager: CacheManager = .shared,
        apiClient: APIClient = MockAPIClient.shared
    ) {
        self.networkMonitor = networkMonitor
        self.actionStore = actionStore
        self.cacheManager = cacheManager
        self.apiClient = apiClient

        setupNetworkCallbacks()
    }

    // MARK: - Setup

    private func setupNetworkCallbacks() {
        networkMonitor.onReconnect = { [weak self] in
            guard let self else { return }
            Task {
                await self.performFullSync()
            }
        }
    }

    /// Uygulamanın başlangıcında çağrılır.
    func startMonitoring() {
        networkMonitor.startMonitoring()
        Task { await refreshPendingCount() }
    }

    func stopMonitoring() {
        networkMonitor.stopMonitoring()
    }

    // MARK: - Connection State

    var isConnected: Bool {
        networkMonitor.isConnected
    }

    var connectionType: ConnectionType {
        networkMonitor.connectionType
    }

    // MARK: - Full Sync Cycle

    /// Tünelden çıkıp durağa geldiğimizde çalışır:
    /// 1. Push: Offline kuyruk → sunucu
    /// 2. Pull: Sunucu → cache güncelle
    func performFullSync() async {
        guard !isSyncing else { return }

        await MainActor.run { isSyncing = true }
        defer { Task { @MainActor in isSyncing = false } }

        // 1) Push: Bekleyen aksiyonları gönder
        await pushPendingActions()

        // 2) Pull: Yakındaki kullanıcıları güncelle
        if let line = activeLine {
            await pullNearbyUsers(for: line)
        }

        // 3) Temizlik
        await actionStore.purgeSyncedActions()
        await actionStore.purgeExhaustedActions()
        await refreshPendingCount()

        await MainActor.run { lastSyncTime = .now }
    }

    // MARK: - Push (Offline Queue → Server)

    /// Bekleyen tüm aksiyonları toplu olarak sunucuya gönderir.
    private func pushPendingActions() async {
        let pending = await actionStore.pendingActions()
        guard !pending.isEmpty else { return }

        // Retry yapılabilecekleri de ekle
        let retryable = await actionStore.actions(withStatus: .failed)
            .filter { $0.canRetry }

        let allToSync = pending + retryable

        // Hepsini "syncing" olarak işaretle
        for action in allToSync {
            await actionStore.markSyncing(id: action.id)
        }

        do {
            let syncedIds = try await apiClient.syncActions(allToSync)
            await actionStore.markAllSynced(ids: syncedIds)
            await MainActor.run { lastSyncError = nil }
        } catch {
            // Başarısız olanları işaretle
            for action in allToSync {
                await actionStore.markFailed(id: action.id)
            }
            await MainActor.run {
                lastSyncError = error.localizedDescription
            }
        }
    }

    // MARK: - Pull (Server → Cache)

    /// Aktif hat için yakındaki kullanıcıları sunucudan çeker ve cache'e yazar.
    func pullNearbyUsers(for line: MetroLine) async {
        do {
            let (users, checkIns) = try await apiClient.fetchNearbyUsers(line: line)
            await cacheManager.updateCache(for: line, users: users, checkIns: checkIns)
        } catch {
            print("⚠️ SyncManager: Kullanıcılar çekilemedi — \(error.localizedDescription)")
        }
    }

    // MARK: - Action Enqueue (UI → Queue)

    /// Beğeni aksiyonunu kuyruğa ekler.
    func enqueueLike(userId: UUID, targetUserId: UUID) async {
        let action = OfflineAction(
            userId: userId,
            type: .like,
            targetUserId: targetUserId
        )
        await actionStore.enqueue(action)
        await refreshPendingCount()

        // Online'sa hemen gönder
        if isConnected { await pushPendingActions() }
    }

    /// Süper beğeni aksiyonunu kuyruğa ekler.
    func enqueueSuperLike(userId: UUID, targetUserId: UUID) async {
        let action = OfflineAction(
            userId: userId,
            type: .superLike,
            targetUserId: targetUserId
        )
        await actionStore.enqueue(action)
        await refreshPendingCount()

        if isConnected { await pushPendingActions() }
    }

    /// Mesaj aksiyonunu kuyruğa ekler.
    func enqueueMessage(userId: UUID, targetUserId: UUID, message: String) async {
        let action = OfflineAction(
            userId: userId,
            type: .message,
            targetUserId: targetUserId,
            payload: message
        )
        await actionStore.enqueue(action)
        await refreshPendingCount()

        if isConnected { await pushPendingActions() }
    }

    /// Check-in aksiyonunu kuyruğa ekler ve gönderir.
    func enqueueCheckIn(userId: UUID, checkIn: CheckIn) async {
        let action = OfflineAction(
            userId: userId,
            type: .checkIn,
            payload: try? String(data: JSONEncoder().encode(checkIn), encoding: .utf8)
        )
        await actionStore.enqueue(action)
        activeLine = checkIn.line
        await refreshPendingCount()

        if isConnected { await performFullSync() }
    }

    /// Check-out aksiyonunu kuyruğa ekler.
    func enqueueCheckOut(userId: UUID) async {
        let action = OfflineAction(
            userId: userId,
            type: .checkOut
        )
        await actionStore.enqueue(action)
        await refreshPendingCount()

        if isConnected { await pushPendingActions() }
        activeLine = nil
    }

    // MARK: - Helpers

    private func refreshPendingCount() async {
        let count = await actionStore.pendingCount
        await MainActor.run { pendingActionCount = count }
    }
}
