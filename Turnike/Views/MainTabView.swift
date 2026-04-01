import SwiftUI

// MARK: - MainTabView

/// Ana tab navigasyonu — glassmorphism tab bar.
struct MainTabView: View {

    @State private var selectedTab: TurnikeTab = .checkIn
    @State private var themeManager = ThemeManager()
    @Namespace private var animation
    var onProfileDeleted: (() -> Void)?

    enum TurnikeTab: String, CaseIterable {
        case checkIn = "check_in"
        case nearby = "nearby"
        case messages = "messages"
        case profile = "profile"

        var icon: String {
            switch self {
            case .checkIn: return "location.circle"
            case .nearby:  return "person.2.wave.2"
            case .messages: return "message"
            case .profile: return "person.crop.circle"
            }
        }

        var title: String {
            switch self {
            case .checkIn: return "Check-in"
            case .nearby:  return "Yakındakiler"
            case .messages: return "Mesajlar"
            case .profile: return "Profil"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab Content
            Group {
                switch selectedTab {
                case .checkIn:
                    CheckInView { checkIn in
                        themeManager.activeLine = checkIn.line
                        selectedTab = .nearby
                    }
                case .nearby:
                    NearbyUsersView(
                        currentLine: themeManager.activeLine,
                        users: [],
                        checkIns: [],
                        pendingSyncCount: 0,
                        isConnected: true
                    )
                case .messages:
                    MessagesView()
                case .profile:
                    ProfileView {
                        onProfileDeleted?()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // MARK: - Glass Tab Bar
            glassTabBar
        }
        .environment(\.themeManager, themeManager)
    }

    private var glassTabBar: some View {
        HStack(spacing: 0) {
            ForEach(TurnikeTab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .background {
            // "Adacık Cam" - Pure Glass Island
            Capsule()
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.4), radius: 20, y: 15)
                .overlay {
                    Capsule()
                        .stroke(Color.white.opacity(0.15), lineWidth: 0.5)
                }
        }
        // Pan/Drag Gesture to slide through tabs interactively
        .background(
            GeometryReader { proxy in
                Color.clear
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let count = CGFloat(TurnikeTab.allCases.count)
                                let index = Int((value.location.x / proxy.size.width) * count)
                                let safeIndex = max(0, min(TurnikeTab.allCases.count - 1, index))
                                let newTab = TurnikeTab.allCases[safeIndex]
                                
                                if selectedTab != newTab {
                                    withAnimation(.interactiveSpring(response: 0.25, dampingFraction: 0.65)) {
                                        selectedTab = newTab
                                    }
                                }
                            }
                    )
            }
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }

    private func tabButton(for tab: TurnikeTab) -> some View {
        let isActive = selectedTab == tab

        return VStack(spacing: 4) {
            Image(systemName: isActive ? "\(tab.icon).fill" : tab.icon)
                .font(.system(size: 22, weight: isActive ? .semibold : .regular))
                .foregroundStyle(isActive ? .white : .white.opacity(0.4))

            if isActive {
                Text(tab.title)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .matchedGeometryEffect(id: "TEXT_\(tab.rawValue)", in: animation)
                    .transition(.opacity.combined(with: .scale))
            } else {
                Text(tab.title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background {
            if isActive {
                Capsule()
                    .fill(Color.white.opacity(0.12))
                    .matchedGeometryEffect(id: "ACTIVE_TAB", in: animation)
            }
        }
        // Remove button wrapper to let the global DragGesture catch taps and drags everywhere continuously
        .contentShape(Rectangle())
    }

    // MARK: - Placeholders
}

// MARK: - MessagesView

struct MessagesView: View {
    @Environment(\.themeManager) private var themeManager

    var body: some View {
        ZStack {
            AnimatedMetroBackground(line: themeManager.activeLine)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "message.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(themeManager.primaryColor.opacity(0.5))

                Text("Mesajlar")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                Text("Sohbetlerin burada görünecek")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }
}

