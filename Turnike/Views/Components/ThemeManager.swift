import SwiftUI

// MARK: - ThemeManager

/// Seçili metro hattına göre tüm UI renklerini türetir.
/// Environment üzerinden tüm view hiyerarşisine enjekte edilir.
@Observable
final class ThemeManager {

    // MARK: - Active Line

    var activeLine: MetroLine = .m2 {
        didSet { updateColors() }
    }

    // MARK: - Derived Colors

    private(set) var primaryColor: Color = .blue
    private(set) var gradient: LinearGradient = LinearGradient(colors: [.blue], startPoint: .top, endPoint: .bottom)
    private(set) var glassOverlayOpacity: Double = 0.12
    private(set) var cardBackground: Color = .blue.opacity(0.12)
    private(set) var textPrimary: Color = .white
    private(set) var textSecondary: Color = .white.opacity(0.7)

    init(line: MetroLine = .m2) {
        self.activeLine = line
        updateColors()
    }

    private func updateColors() {
        primaryColor = activeLine.seatColor
        gradient = activeLine.themeGradient
        glassOverlayOpacity = 0.12
        cardBackground = activeLine.seatColor.opacity(0.12)
        textPrimary = .white
        textSecondary = .white.opacity(0.7)
    }
}

// MARK: - Environment Key

struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager()
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}
