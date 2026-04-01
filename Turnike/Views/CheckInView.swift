import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - CheckInView

/// Metro biniş check-in akışı.
/// Adım adım: Hat → Yön → Durak → Vagon/Kapı → Gizlilik Modu seçimi.
/// Her adımda glassmorphism kartlar ve dinamik arka plan.
struct CheckInView: View {

    @Environment(\.themeManager) private var theme
    @State private var step: CheckInStep = .selectLine
    @State private var selectedLine: MetroLine?
    @State private var selectedDirection: String?
    @State private var selectedStation: String?
    @State private var wagonNumber: String = ""
    @State private var doorNumber: String = ""
    @State private var privacyMode: PrivacyMode = .instant
    @State private var showConfirmation = false

    /// Check-in tamamlandığında çağrılır.
    var onCheckInComplete: ((CheckIn) -> Void)?

    var body: some View {
        ZStack {
            // Dinamik arka plan
            if let line = selectedLine {
                AnimatedMetroBackground(line: line)
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea()
                // Varsayılan animasyon
                AnimatedMetroBackground(line: .m2)
                    .ignoresSafeArea()
                    .opacity(0.4)
            }

            VStack(spacing: 0) {
                // MARK: - Header
                header

                // MARK: - Content
                ScrollView {
                    VStack(spacing: 16) {
                        switch step {
                        case .selectLine:
                            lineSelectionGrid
                        case .selectDirection:
                            directionPicker
                        case .selectStation:
                            stationPicker
                        case .optionalDetails:
                            detailsInput
                        case .privacyMode:
                            privacyModePicker
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: step)
        .overlay(alignment: .bottom) {
            if showConfirmation {
                confirmationOverlay
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            HStack {
                // Geri butonu (ilk adım değilse)
                if step != .selectLine {
                    Button {
                        goBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .glass(color: selectedLine?.seatColor ?? .white, cornerRadius: 12, opacity: 0.2)
                    }
                }

                Spacer()

                // İlerleme göstergesi
                HStack(spacing: 6) {
                    ForEach(CheckInStep.allCases, id: \.self) { s in
                        Capsule()
                            .fill(s.rawValue <= step.rawValue
                                  ? (selectedLine?.seatColor ?? .white)
                                  : .white.opacity(0.2))
                            .frame(width: s == step ? 24 : 8, height: 4)
                    }
                }

                Spacer()

                // Placeholder for symmetry
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)

            Text(step.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text(step.subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    // MARK: - Step 1: Hat Seçimi

    private var lineSelectionGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(MetroLine.allCases) { line in
                Button {
                    withAnimation(.spring(response: 0.4)) {
                        selectedLine = line
                        theme.activeLine = line
                        step = .selectDirection
                    }
                } label: {
                    VStack(spacing: 8) {
                        // Renk çemberi
                        Circle()
                            .fill(line.seatColor.gradient)
                            .frame(width: 40, height: 40)
                            .shadow(color: line.seatColor.opacity(0.5), radius: 8)

                        Text(line.displayName)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .glass(color: line.seatColor, cornerRadius: 16, opacity: selectedLine == line ? 0.3 : 0.08)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Step 2: Yön Seçimi

    private var directionPicker: some View {
        VStack(spacing: 12) {
            if let line = selectedLine {
                ForEach(line.directionNames, id: \.self) { direction in
                    Button {
                        withAnimation(.spring(response: 0.4)) {
                            selectedDirection = direction
                            step = .selectStation
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title3)
                                .foregroundStyle(line.seatColor)

                            Text("\(direction) yönü")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .padding(16)
                        .glass(color: line.seatColor, cornerRadius: 16, opacity: 0.1)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Step 3: Durak Seçimi

    private var stationPicker: some View {
        VStack(spacing: 8) {
            if let line = selectedLine {
                let stations = resolveStations(line: line)
                ForEach(Array(stations.enumerated()), id: \.offset) { index, station in
                    Button {
                        withAnimation(.spring(response: 0.4)) {
                            selectedStation = station
                            step = .optionalDetails
                        }
                    } label: {
                        HStack(spacing: 12) {
                            // İstasyon numarası
                            Text("\(index + 1)")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(line.seatColor)
                                .frame(width: 28, height: 28)
                                .background {
                                    Circle()
                                        .fill(line.seatColor.opacity(0.2))
                                }

                            Text(station)
                                .font(.body.weight(.medium))
                                .foregroundStyle(.white)

                            Spacer()

                            if selectedStation == station {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(line.seatColor)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .glass(
                            color: line.seatColor,
                            cornerRadius: 12,
                            opacity: selectedStation == station ? 0.25 : 0.05
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Step 4: Vagon / Kapı (Opsiyonel)

    private var detailsInput: some View {
        VStack(spacing: 16) {
            if let line = selectedLine {
                GlassCard(line: line) {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Vagon Numarası (Opsiyonel)", systemImage: "tram")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))

                        TextField("Örn: 3", text: $wagonNumber)
                            #if canImport(UIKit)
                            .keyboardType(.numberPad)
                            #endif
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(12)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white.opacity(0.08))
                            }
                    }
                }

                GlassCard(line: line) {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Kapı Numarası (Opsiyonel)", systemImage: "door.sliding.left.hand.open")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))

                        TextField("Örn: 2", text: $doorNumber)
                            #if canImport(UIKit)
                            .keyboardType(.numberPad)
                            #endif
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(12)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(.white.opacity(0.08))
                            }
                    }
                }

                GlowButton("Devam Et", icon: "arrow.right", color: line.seatColor) {
                    withAnimation(.spring(response: 0.4)) {
                        step = .privacyMode
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
            }
        }
    }

    // MARK: - Step 5: Gizlilik Modu

    private var privacyModePicker: some View {
        VStack(spacing: 16) {
            if let line = selectedLine {
                // Anlık Mod
                privacyModeCard(
                    title: "Anlık Mod",
                    description: "Eşleşmeler ve beğeniler durakta anında bildirim olarak düşer.",
                    icon: "bolt.fill",
                    isSelected: isInstantMode,
                    line: line
                ) {
                    privacyMode = .instant
                }

                // Sakin Mod
                privacyModeCard(
                    title: "Sakin Mod",
                    description: "Bildirimler metrodan indikten 15 dakika sonra topluca gelir.",
                    icon: "moon.fill",
                    isSelected: !isInstantMode,
                    line: line
                ) {
                    privacyMode = .calm
                }

                // Onayla butonu
                GlowButton("Bindim! 🚇", icon: "checkmark.circle.fill", color: line.seatColor) {
                    completeCheckIn()
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
            }
        }
    }

    private func privacyModeCard(
        title: String,
        description: String,
        icon: String,
        isSelected: Bool,
        line: MetroLine,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? line.seatColor : .white.opacity(0.4))
                    .frame(width: 44, height: 44)
                    .background {
                        Circle()
                            .fill(isSelected ? line.seatColor.opacity(0.2) : .white.opacity(0.05))
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? line.seatColor : .white.opacity(0.3))
            }
            .padding(16)
            .glass(color: line.seatColor, cornerRadius: 16, opacity: isSelected ? 0.2 : 0.05)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Confirmation Overlay

    private var confirmationOverlay: some View {
        VStack(spacing: 16) {
            if let line = selectedLine {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(line.seatColor)
                    .symbolEffect(.bounce, value: showConfirmation)

                Text("Check-in Tamamlandı!")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                if let station = selectedStation {
                    Text("\(line.displayName) • \(station)")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .padding(32)
        .glass(color: selectedLine?.seatColor ?? .white, cornerRadius: 24, opacity: 0.2)
        .padding(.horizontal, 40)
        .padding(.bottom, 60)
    }

    // MARK: - Logic

    private var isInstantMode: Bool {
        if case .instant = privacyMode { return true }
        return false
    }

    private func resolveStations(line: MetroLine) -> [String] {
        guard let direction = selectedDirection else { return line.stations }
        // Yöne göre durak sırasını belirle
        if direction == line.directions.end {
            return line.stations
        } else {
            return line.stations.reversed()
        }
    }

    private func goBack() {
        withAnimation(.spring(response: 0.4)) {
            switch step {
            case .selectLine: break
            case .selectDirection:
                step = .selectLine
                selectedLine = nil
            case .selectStation:
                step = .selectDirection
                selectedDirection = nil
            case .optionalDetails:
                step = .selectStation
                selectedStation = nil
            case .privacyMode:
                step = .optionalDetails
            }
        }
    }

    private func completeCheckIn() {
        guard let line = selectedLine,
              let direction = selectedDirection,
              let station = selectedStation else { return }

        let checkIn = CheckIn(
            userId: UUID(), // Gerçek uygulamada oturumdaki kullanıcı ID'si
            line: line,
            direction: direction,
            currentStation: station,
            wagonNumber: Int(wagonNumber),
            doorNumber: Int(doorNumber),
            privacyMode: privacyMode
        )

        withAnimation(.spring(response: 0.5)) {
            showConfirmation = true
        }

        // 2 saniye sonra callback'i tetikle
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            onCheckInComplete?(checkIn)
        }
    }
}

// MARK: - CheckInStep

enum CheckInStep: Int, CaseIterable {
    case selectLine = 0
    case selectDirection = 1
    case selectStation = 2
    case optionalDetails = 3
    case privacyMode = 4

    var title: String {
        switch self {
        case .selectLine:      return "Hat Seç"
        case .selectDirection: return "Yön Seç"
        case .selectStation:   return "Durak Seç"
        case .optionalDetails: return "Detaylar"
        case .privacyMode:     return "Gizlilik Modu"
        }
    }

    var subtitle: String {
        switch self {
        case .selectLine:      return "Hangi hattasın?"
        case .selectDirection: return "Hangi yöne gidiyorsun?"
        case .selectStation:   return "Hangi duraktasın?"
        case .optionalDetails: return "Vagon ve kapı bilgisi (opsiyonel)"
        case .privacyMode:     return "Bildirimleri nasıl almak istersin?"
        }
    }
}
