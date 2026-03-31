import Foundation

// MARK: - OfflineActionStore

/// Tünelde (offline) yapılan aksiyonları diske kalıcı olarak saklar.
/// Actor isolation ile thread-safe. Uygulama kapansa bile kuyruk korunur.
actor OfflineActionStore {

    // MARK: - Singleton

    static let shared = OfflineActionStore()

    // MARK: - Storage

    private var actions: [OfflineAction] = []
    private let fileURL: URL

    private init() {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documentsDir.appendingPathComponent("offline_actions.json")
        self.actions = Self.loadFromDisk(url: fileURL)
    }

    // MARK: - Queue Operations

    /// Yeni bir offline aksiyon kuyruğa ekler.
    func enqueue(_ action: OfflineAction) {
        actions.append(action)
        saveToDisk()
    }

    /// Birden fazla aksiyonu topluca kuyruğa ekler.
    func enqueueAll(_ newActions: [OfflineAction]) {
        actions.append(contentsOf: newActions)
        saveToDisk()
    }

    /// Belirli statüdeki aksiyonları döner.
    func actions(withStatus status: SyncStatus) -> [OfflineAction] {
        actions.filter { $0.syncStatus == status }
    }

    /// Bekleyen (pending) tüm aksiyonları döner.
    func pendingActions() -> [OfflineAction] {
        actions(withStatus: .pending)
    }

    /// Toplam bekleyen aksiyon sayısı.
    var pendingCount: Int {
        actions.filter { $0.syncStatus == .pending || $0.syncStatus == .failed }.count
    }

    /// Tüm aksiyonları döner (debug/UI amaçlı).
    func allActions() -> [OfflineAction] {
        actions
    }

    // MARK: - Status Updates

    /// Aksiyonu "syncing" olarak işaretle.
    func markSyncing(id: UUID) {
        guard let index = actions.firstIndex(where: { $0.id == id }) else { return }
        actions[index].markSyncing()
        saveToDisk()
    }

    /// Aksiyonu başarılı olarak işaretle.
    func markSynced(id: UUID) {
        guard let index = actions.firstIndex(where: { $0.id == id }) else { return }
        actions[index].markSynced()
        saveToDisk()
    }

    /// Aksiyonu başarısız olarak işaretle.
    func markFailed(id: UUID) {
        guard let index = actions.firstIndex(where: { $0.id == id }) else { return }
        actions[index].markFailed()
        saveToDisk()
    }

    /// Toplu statü güncelleme.
    func markAllSynced(ids: [UUID]) {
        for id in ids {
            if let index = actions.firstIndex(where: { $0.id == id }) {
                actions[index].markSynced()
            }
        }
        saveToDisk()
    }

    // MARK: - Cleanup

    /// Başarıyla senkronize edilmiş aksiyonları temizler.
    func purgeSyncedActions() {
        actions.removeAll { $0.syncStatus == .synced }
        saveToDisk()
    }

    /// Retry hakkı dolmuş başarısız aksiyonları temizler.
    func purgeExhaustedActions() {
        actions.removeAll { $0.syncStatus == .failed && !$0.canRetry }
        saveToDisk()
    }

    /// Tüm kuyruğu temizler (debug/reset).
    func purgeAll() {
        actions.removeAll()
        saveToDisk()
    }

    // MARK: - Persistence

    private func saveToDisk() {
        do {
            let data = try JSONEncoder().encode(actions)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("⚠️ OfflineActionStore: Diske yazılamadı — \(error.localizedDescription)")
        }
    }

    private static func loadFromDisk(url: URL) -> [OfflineAction] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([OfflineAction].self, from: data)
        } catch {
            print("⚠️ OfflineActionStore: Diskten okunamadı — \(error.localizedDescription)")
            return []
        }
    }
}
