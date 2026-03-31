import Foundation

// MARK: - CacheManager

/// Duraktayken çekilen yakındaki kullanıcıları önbelleğe alır.
/// Tüneldeyken bu cache üzerinden göz atma yapılır.
actor CacheManager {

    // MARK: - Singleton

    static let shared = CacheManager()

    // MARK: - Types

    /// Önbellekteki hat verisi.
    struct LineCacheEntry: Codable {
        let line: MetroLine
        var users: [User]
        var checkIns: [CheckIn]
        let cachedAt: Date

        /// TTL kontrolü.
        func isExpired(ttl: TimeInterval) -> Bool {
            Date.now.timeIntervalSince(cachedAt) > ttl
        }
    }

    // MARK: - Storage

    private var lineCache: [MetroLine: LineCacheEntry] = [:]
    private let fileURL: URL

    /// Varsayılan önbellek ömrü: 10 dakika.
    let defaultTTL: TimeInterval = 10 * 60

    private init() {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.fileURL = documentsDir.appendingPathComponent("nearby_cache.json")
        self.lineCache = Self.loadFromDisk(url: fileURL)
    }

    // MARK: - Read

    /// Belirli bir hat için önbellekteki kullanıcıları döner.
    /// TTL dolmuşsa boş döner.
    func getCachedUsers(for line: MetroLine) -> [User] {
        guard let entry = lineCache[line], !entry.isExpired(ttl: defaultTTL) else {
            return []
        }
        return entry.users
    }

    /// Belirli bir hat için önbellekteki check-in'leri döner.
    func getCachedCheckIns(for line: MetroLine) -> [CheckIn] {
        guard let entry = lineCache[line], !entry.isExpired(ttl: defaultTTL) else {
            return []
        }
        return entry.checkIns
    }

    /// Cache hâlâ geçerli mi?
    func isCacheValid(for line: MetroLine) -> Bool {
        guard let entry = lineCache[line] else { return false }
        return !entry.isExpired(ttl: defaultTTL)
    }

    /// Son cache zamanı.
    func lastCacheTime(for line: MetroLine) -> Date? {
        lineCache[line]?.cachedAt
    }

    // MARK: - Write

    /// Durakta sunucudan çekilen verileri önbelleğe yazar.
    func updateCache(for line: MetroLine, users: [User], checkIns: [CheckIn]) {
        lineCache[line] = LineCacheEntry(
            line: line,
            users: users,
            checkIns: checkIns,
            cachedAt: .now
        )
        saveToDisk()
    }

    // MARK: - Cleanup

    /// Süresi dolmuş tüm cache girişlerini temizler.
    func purgeExpiredEntries() {
        lineCache = lineCache.filter { !$0.value.isExpired(ttl: defaultTTL) }
        saveToDisk()
    }

    /// Belirli bir hattın cache'ini temizler.
    func clearCache(for line: MetroLine) {
        lineCache.removeValue(forKey: line)
        saveToDisk()
    }

    /// Tüm cache'i temizler.
    func clearAll() {
        lineCache.removeAll()
        saveToDisk()
    }

    // MARK: - Persistence

    private func saveToDisk() {
        do {
            let entries = Array(lineCache.values)
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("⚠️ CacheManager: Diske yazılamadı — \(error.localizedDescription)")
        }
    }

    private static func loadFromDisk(url: URL) -> [MetroLine: LineCacheEntry] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [:] }
        do {
            let data = try Data(contentsOf: url)
            let entries = try JSONDecoder().decode([LineCacheEntry].self, from: data)
            var dict: [MetroLine: LineCacheEntry] = [:]
            for entry in entries {
                dict[entry.line] = entry
            }
            return dict
        } catch {
            print("⚠️ CacheManager: Diskten okunamadı — \(error.localizedDescription)")
            return [:]
        }
    }
}
