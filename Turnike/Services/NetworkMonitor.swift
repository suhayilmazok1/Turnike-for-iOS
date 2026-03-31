import Foundation
import Network

// MARK: - NetworkMonitor

/// NWPathMonitor sarmalayıcı.
/// Metro tünellerinde bağlantı kesilir, duraklarda geri gelir.
/// `onReconnect` callback'i ile SyncManager tetiklenir.
@Observable
final class NetworkMonitor {

    // MARK: - Properties

    private(set) var isConnected: Bool = false
    private(set) var connectionType: ConnectionType = .unknown

    /// Offline → Online geçişinde tetiklenir (durak algılandı).
    var onReconnect: (() -> Void)?

    private let monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "com.turnike.networkmonitor", qos: .utility)
    private var wasDisconnected: Bool = true

    // MARK: - Init

    init() {
        self.monitor = NWPathMonitor()
    }

    // MARK: - Lifecycle

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }

            let connected = path.status == .satisfied
            let type = self.resolveConnectionType(path)

            DispatchQueue.main.async {
                let previouslyDisconnected = self.wasDisconnected
                self.isConnected = connected
                self.connectionType = type

                if connected {
                    if previouslyDisconnected {
                        // Tünelden çıkıp durağa geldik
                        self.onReconnect?()
                    }
                    self.wasDisconnected = false
                } else {
                    // Tünele girdik
                    self.wasDisconnected = true
                }
            }
        }

        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }

    // MARK: - Helpers

    private func resolveConnectionType(_ path: NWPath) -> ConnectionType {
        if path.usesInterfaceType(.wifi) { return .wifi }
        if path.usesInterfaceType(.cellular) { return .cellular }
        if path.usesInterfaceType(.wiredEthernet) { return .wired }
        return .unknown
    }
}

// MARK: - ConnectionType

enum ConnectionType: String, Codable {
    case wifi
    case cellular
    case wired
    case unknown

    var displayName: String {
        switch self {
        case .wifi:     return "Wi-Fi"
        case .cellular: return "Mobil Veri"
        case .wired:    return "Kablolu"
        case .unknown:  return "Bilinmiyor"
        }
    }
}
