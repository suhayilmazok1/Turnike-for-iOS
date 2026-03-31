import SwiftUI

// MARK: - OnboardingPrivacyView

/// Gizlilik modu seçimi — Anlık Mod veya Sakin Mod.
struct OnboardingPrivacyView: View {

    @Bindable var viewModel: ProfileOnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Bilgi kartı
                VStack(spacing: 8) {
                    Image(systemName: "shield.checkered")
                        .font(.system(size: 40))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.cyan, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Gizliliğin senin elinde")
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.white)

                    Text("Bildirimlerinin ne zaman geleceğini belirle")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .glass(cornerRadius: 20, opacity: 0.1)
                .padding(.horizontal, 20)

                // MARK: - Mode Cards

                // Anlık Mod
                privacyModeCard(
                    title: "Anlık Mod",
                    description: "Eşleşmeler ve beğeniler durakta anında bildirim olarak düşer. Metro'dayken sosyalleş!",
                    icon: "bolt.fill",
                    iconColor: .yellow,
                    isSelected: isInstantMode
                ) {
                    viewModel.privacyMode = .instant
                }

                // Sakin Mod
                privacyModeCard(
                    title: "Sakin Mod",
                    description: "Bildirimler metrodan indikten 15 dakika sonra topluca gelir. Yolculuğunun tadını çıkar!",
                    icon: "moon.fill",
                    iconColor: .purple,
                    isSelected: !isInstantMode
                ) {
                    viewModel.privacyMode = .calm(delayMinutes: PrivacyMode.defaultCalmDelay)
                }

                // İpucu
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(.yellow.opacity(0.7))
                        .font(.caption)

                    Text("Bu ayarı daha sonra profil ayarlarından değiştirebilirsin.")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.top, 8)
            }
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }

    private var isInstantMode: Bool {
        if case .instant = viewModel.privacyMode { return true }
        return false
    }

    // MARK: - Privacy Mode Card

    private func privacyModeCard(
        title: String,
        description: String,
        icon: String,
        iconColor: Color,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                action()
            }
        } label: {
            HStack(spacing: 14) {
                // İkon
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? iconColor : .white.opacity(0.4))
                    .frame(width: 50, height: 50)
                    .background {
                        Circle()
                            .fill(isSelected ? iconColor.opacity(0.2) : .white.opacity(0.05))
                    }

                // Metin
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body.weight(.bold))
                        .foregroundStyle(.white)

                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                // Seçim göstergesi
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? .cyan : .white.opacity(0.3))
            }
            .padding(16)
            .glass(cornerRadius: 16, opacity: isSelected ? 0.2 : 0.05)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
    }
}
