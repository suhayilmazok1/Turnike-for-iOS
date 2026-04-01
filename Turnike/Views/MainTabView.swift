import SwiftUI

// MARK: - MainTabView

/// Ana tab navigasyonu — glassmorphism tab bar.
struct MainTabView: View {

    @State private var selectedTab: Tab = .checkIn
    @State private var themeManager = ThemeManager()
    @Namespace private var animation
    var onProfileDeleted: (() -> Void)?

    enum Tab: String, CaseIterable {
        case checkIn = "check_in"
        case nearby = "nearby"
        case matches = "matches"
        case profile = "profile"

        var icon: String {
            switch self {
            case .checkIn: return "tram"
            case .nearby:  return "person.2"
            case .matches: return "heart"
            case .profile: return "person.crop.circle"
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
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(Color(white: 0.12).opacity(0.85)) // Dark glass background
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                )
                .shadow(color: .black.opacity(0.5), radius: 15, y: 10)
                .overlay {
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }

    private func tabButton(for tab: Tab) -> some View {
        let isActive = selectedTab == tab

        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isActive ? "\(tab.icon).fill" : tab.icon)
                    .font(.system(size: 22, weight: isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? .white : .white.opacity(0.6))

                Text(tab.title)
                    .font(.system(size: 10, weight: isActive ? .bold : .medium))
                    .foregroundStyle(isActive ? .white : .white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                if isActive {
                    Capsule()
                        .fill(Color.white.opacity(0.15))
                        .matchedGeometryEffect(id: "ACTIVE_TAB", in: animation)
                }
            }
        }
        .buttonStyle(.plain)
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

