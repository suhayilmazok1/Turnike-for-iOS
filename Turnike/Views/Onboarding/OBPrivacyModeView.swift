import SwiftUI

// MARK: - OBPrivacyModeView

struct OBPrivacyModeView: View {

    var viewModel: ProfileOnboardingViewModel
    @State private var showInfo = false

    // Gradient renkler
    private let accentPink = Color(red: 215/255, green: 130/255, blue: 165/255)
    private let accentBlue = Color(red: 110/255, green: 155/255, blue: 200/255)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Başlık + info butonu
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Gizlilik modunu seç")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)

                    Text("Bu seni diğerlerinden ayıran farkımız.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()

                Button {
                    showInfo = true
                } label: {
                    Image(systemName: "info.circle.fill")
                        .font(.title2)
                        .foregroundStyle(accentBlue)
                }
            }
            .padding(.top, 32)

            // Mod Kartları
            VStack(spacing: 16) {
                // Anlık Mod
                modeCard(
                    title: "Anlık Mod",
                    icon: "bolt.fill",
                    iconColor: .yellow,
                    description: "Bildirimler anında gelir. Etkileşimler gerçek zamanlı.",
                    features: [
                        "💬 Mesajlar anında ulaşır",
                        "👀 Online durumun görünür",
                        "⚡ Anında eşleşme bildirimleri"
                    ],
                    isSelected: viewModel.privacyMode == .instant,
                    borderColor: accentPink
                ) {
                    withAnimation(.spring(response: 0.35)) {
                        viewModel.privacyMode = .instant
                    }
                }

                // Sakin Mod
                modeCard(
                    title: "Sakin Mod",
                    icon: "moon.fill",
                    iconColor: .purple,
                    description: "Bildirimler metrodan indikten sonra topluca gelir.",
                    features: [
                        "🔕 Yolculuk sırasında sessizlik",
                        "🕐 İndikten 15 dk sonra bildirimler",
                        "👻 Kimse online olduğunu görmez"
                    ],
                    isSelected: viewModel.privacyMode == .calm,
                    borderColor: accentBlue
                ) {
                    withAnimation(.spring(response: 0.35)) {
                        viewModel.privacyMode = .calm
                    }
                }
            }
            .padding(.top, 28)

            // Alt ipucu
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                Text("İstediğin zaman ayarlardan değiştirebilirsin.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(.top, 20)

            Spacer()
        }
        .padding(.horizontal, 24)
        .sheet(isPresented: $showInfo) {
            infoSheet
        }
    }

    // MARK: - Mode Card

    private func modeCard(
        title: String,
        icon: String,
        iconColor: Color,
        description: String,
        features: [String],
        isSelected: Bool,
        borderColor: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(iconColor)

                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)

                    Spacer()

                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(isSelected ? borderColor : .white.opacity(0.3))
                }

                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.leading)

                VStack(alignment: .leading, spacing: 6) {
                    ForEach(features, id: \.self) { feature in
                        Text(feature)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
            }
            .padding(18)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(isSelected ? borderColor.opacity(0.1) : .white.opacity(0.04))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(isSelected ? borderColor : .white.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                    }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Info Sheet

    private var infoSheet: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Başlık
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Turnike Gizlilik Modları")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)

                        Text("Diğer uygulamalardan farklı olarak, Turnike sana metroda nasıl etkileşime geçeceğini seçme özgürlüğü verir.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    // Anlık Mod detay
                    infoSection(
                        icon: "bolt.fill",
                        iconColor: .yellow,
                        title: "⚡ Anlık Mod",
                        items: [
                            ("Gerçek zamanlı iletişim", "Mesajlar ve bildirimler anında gelir. Metro içindeyken diğer kullanıcılarla canlı etkileşim kurabilirsin."),
                            ("Online durumu görünür", "Aynı hatta olan diğer kullanıcılar senin aktif olduğunu görebilir."),
                            ("Anında eşleşme", "Birisi seni beğendiğinde hemen haberdar olursun.")
                        ]
                    )

                    // Sakin Mod detay
                    infoSection(
                        icon: "moon.fill",
                        iconColor: .purple,
                        title: "🌙 Sakin Mod",
                        items: [
                            ("Yolculukta huzur", "Metro yolculuğun sırasında hiçbir bildirim almaz, rahatsız edilmezsin."),
                            ("Toplu bildirim", "Metrodan indikten yaklaşık 15 dakika sonra tüm bildirimler tek seferde gelir."),
                            ("Görünmez mod", "Kimse senin online olduğunu göremez. Profil kartın yine görünür ama sen 'hayalet' moddasın.")
                        ]
                    )

                    // Neden farklı
                    VStack(alignment: .leading, spacing: 8) {
                        Text("🎯 Neden bu önemli?")
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text("Çoğu uygulama seni sürekli bildirimlerle bunaltır. Turnike, metro deneyimini senin kontrol etmeni sağlar. Yolculuğun keyfini çıkar, etkileşimleri istediğin zaman gör.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(16)
                    .background {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(LinearGradient(
                                colors: [accentPink.opacity(0.1), accentBlue.opacity(0.1)],
                                startPoint: .topLeading, endPoint: .bottomTrailing))
                    }
                }
                .padding(24)
            }
            .background(Color(red: 20/255, green: 20/255, blue: 30/255).ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Tamam") { showInfo = false }
                        .foregroundStyle(.cyan)
                }
            }
        }
        .presentationDetents([.large])
        .preferredColorScheme(.dark)
    }

    // MARK: - Info Section

    private func infoSection(icon: String, iconColor: Color, title: String, items: [(String, String)]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(items, id: \.0) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.0)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                    Text(item.1)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white.opacity(0.05))
                }
            }
        }
    }
}
