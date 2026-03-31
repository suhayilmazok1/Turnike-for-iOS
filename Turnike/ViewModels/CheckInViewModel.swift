import Foundation

// MARK: - CheckInViewModel

/// Check-in ekranını yöneten ViewModel.
/// Hat/yön/durak seçimini tutar, CheckIn modelini oluşturur ve SyncManager'a iletir.
@Observable
final class CheckInViewModel {

    // MARK: - State

    var selectedLine: MetroLine?
    var selectedDirection: String?
    var selectedStation: String?
    var wagonNumber: Int?
    var doorNumber: Int?
    var privacyMode: PrivacyMode = .instant
    var isCheckingIn: Bool = false
    var activeCheckIn: CheckIn?

    // MARK: - Dependencies

    private let syncManager: SyncManager
    private let userId: UUID

    init(syncManager: SyncManager = .shared, userId: UUID = UUID()) {
        self.syncManager = syncManager
        self.userId = userId
    }

    // MARK: - Computed

    var isValid: Bool {
        selectedLine != nil && selectedDirection != nil && selectedStation != nil
    }

    var availableDirections: [String] {
        selectedLine?.directionNames ?? []
    }

    var availableStations: [String] {
        guard let line = selectedLine, let direction = selectedDirection else { return [] }
        if direction == line.directions.end {
            return line.stations
        } else {
            return line.stations.reversed()
        }
    }

    var isActive: Bool {
        activeCheckIn?.isActive == true && !(activeCheckIn?.isExpired ?? true)
    }

    // MARK: - Actions

    /// Check-in oluşturur ve senkronizasyon kuyruğuna ekler.
    func performCheckIn() async {
        guard let line = selectedLine,
              let direction = selectedDirection,
              let station = selectedStation else { return }

        isCheckingIn = true
        defer { isCheckingIn = false }

        let checkIn = CheckIn(
            userId: userId,
            line: line,
            direction: direction,
            currentStation: station,
            wagonNumber: wagonNumber,
            doorNumber: doorNumber,
            privacyMode: privacyMode
        )

        activeCheckIn = checkIn
        await syncManager.enqueueCheckIn(userId: userId, checkIn: checkIn)
    }

    /// Check-out yapar — profili listeden kaldırır.
    func performCheckOut() async {
        activeCheckIn?.checkOut()
        await syncManager.enqueueCheckOut(userId: userId)
        activeCheckIn = nil
    }

    /// Formu sıfırlar.
    func reset() {
        selectedLine = nil
        selectedDirection = nil
        selectedStation = nil
        wagonNumber = nil
        doorNumber = nil
        privacyMode = .instant
        activeCheckIn = nil
    }
}
