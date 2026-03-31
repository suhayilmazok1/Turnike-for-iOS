import SwiftUI

// MARK: - UserCardView

/// Yakındaki kullanıcıyı gösteren glassmorphism profil kartı.
/// Koltuk rengi vurgusu, istasyon rozeti ve vagon detayı içerir.
struct UserCardView: View {

    let user: User
    let checkIn: CheckIn
    let line: MetroLine

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Profil Fotoğrafı Alanı
            ZStack(alignment: .bottomLeading) {
                // Placeholder gradient
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                line.seatColor.opacity(0.4),
                                line.seatColor.opacity(0.1),
                                .black.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 320)
                    .overlay {
                        // İnisyaller
                        Text(initials(from: user.displayName))
                            .font(.system(size: 72, weight: .thin, design: .rounded))
                            .foregroundStyle(.white.opacity(0.3))
                    }

                // Alt gradient overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 24))

                // İsim ve yaş
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(user.displayName)
                            .font(.title.weight(.bold))
                        Text("\(user.age)")
                            .font(.title2.weight(.light))
                    }
                    .foregroundStyle(.white)
                }
                .padding(20)
            }

            // MARK: - Detaylar
            VStack(spacing: 12) {
                // Bio
                if !user.bio.isEmpty {
                    Text(user.bio)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.85))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                // Konum bilgileri
                HStack(spacing: 8) {
                    // Durak rozeti
                    Label(checkIn.currentStation, systemImage: "tram.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background {
                            Capsule()
                                .fill(line.seatColor.opacity(0.3))
                        }

                    // Yön
                    Label(checkIn.direction, systemImage: "arrow.right")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.7))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background {
                            Capsule()
                                .fill(.white.opacity(0.1))
                        }

                    Spacer()
                }

                // Vagon / Kapı
                if let detail = checkIn.locationDetail {
                    HStack(spacing: 4) {
                        Image(systemName: "door.sliding.left.hand.open")
                            .font(.caption2)
                        Text(detail)
                            .font(.caption)
                    }
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                // İlgi alanları
                if !user.interests.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(user.interests, id: \.self) { interest in
                                Text(interest)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.white.opacity(0.9))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background {
                                        Capsule()
                                            .fill(line.seatColor.opacity(0.2))
                                            .overlay {
                                                Capsule()
                                                    .stroke(line.seatColor.opacity(0.3), lineWidth: 0.5)
                                            }
                                    }
                            }
                        }
                    }
                }
            }
            .padding(16)
        }
        .glassCard(line: line, cornerRadius: 24)
    }

    // MARK: - Helpers

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        let initials = parts.compactMap { $0.first }.map(String.init)
        return initials.prefix(2).joined()
    }
}
