import SwiftUI

// MARK: - MainTabView

/// Ana tab navigasyonu — glassmorphism tab bar.
struct MainTabView: View {

    @State private var selectedTab: Tab = .checkIn
    @State private var themeManager = ThemeManager()
    var onProfileDeleted: (() -> Void)?

    enum Tab: String, CaseIterable {
        case checkIn = "check_in"
        case nearby = "nearby"
        case matches = "matches"
        case profile = "profile"

        var icon: String {
            switch self {
            case .checkIn: return "tram.fill"
            case .nearby:  return "person.2.fill"
            case .matches: return "heart.fill"
            case .profile: return "person.crop.circle.fill"
            }
        }

        var title: String {
            switch self {
            case .checkIn: return "Bin"
            case .nearby:  return "Yakında"
            case .matches: return "Eşleşme"
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
                    // Placeholder — ViewModel bağlanacak
                    NearbyUsersView(
                        currentLine: themeManager.activeLine,
                        users: [],
                        checkIns: [],
                        pendingSyncCount: 0,
                        isConnected: true
                    )
                case .matches:
                    matchesPlaceholder
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

    // MARK: - Glass Tab Bar

    private var glassTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                tabButton(for: tab)
            }
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
        .padding(.bottom, 24)
        .background { tabBarBackground }
    }

    private func tabButton(for tab: Tab) -> some View {
        let isActive = selectedTab == tab
        let activeColor: Color = themeManager.primaryColor
        let inactiveIconColor: Color = .white.opacity(0.4)
        let inactiveTextColor: Color = .white.opacity(0.3)

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 20, weight: isActive ? .bold : .regular))
                    .foregroundStyle(isActive ? activeColor : inactiveIconColor)
                    .scaleEffect(isActive ? 1.15 : 1.0)

                Text(tab.title)
                    .font(.caption2.weight(isActive ? .bold : .regular))
                    .foregroundStyle(isActive ? activeColor : inactiveTextColor)

                if isActive {
                    Capsule()
                        .fill(activeColor)
                        .frame(width: 20, height: 2)
                        .transition(.scale)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var tabBarBackground: some View {
        let accentColor: Color = themeManager.primaryColor

        ZStack(alignment: .top) {
            UnevenRoundedRectangle(
                topLeadingRadius: 24,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 24
            )
            .fill(.ultraThinMaterial)

            UnevenRoundedRectangle(
                topLeadingRadius: 24,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 24
            )
            .fill(accentColor.opacity(0.05))

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [accentColor.opacity(0.3), Color.clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 0.5)
        }
        .shadow(color: Color.black.opacity(0.3), radius: 20, y: -8)
        .ignoresSafeArea()
    }

    // MARK: - Placeholders

    private var matchesPlaceholder: some View {
        ZStack {
            AnimatedMetroBackground(line: themeManager.activeLine)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "heart.circle")
                    .font(.system(size: 60))
                    .foregroundStyle(themeManager.primaryColor.opacity(0.5))

                Text("Eşleşmeler")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)

                Text("Eşleşmelerin burada görünecek")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }

}

