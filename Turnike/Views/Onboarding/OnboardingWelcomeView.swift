import SwiftUI

// MARK: - OnboardingWelcomeView

/// Karşılama ekranı — uygulama logosu, tagline ve başla butonu.
struct OnboardingWelcomeView: View {

    var onStart: () -> Void
    @State private var showContent = false
    @State private var pulseGlow = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // MARK: - Logo & Title
            VStack(spacing: 24) {
                // Logo
                ZStack {
                    // Glow ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [.cyan, .purple, .cyan.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 120, height: 120)
                        .scaleEffect(pulseGlow ? 1.1 : 1.0)
                        .opacity(pulseGlow ? 0.6 : 1.0)

                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 110, height: 110)
                        .overlay {
                            Image(systemName: "tram.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.cyan, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.7)

                // App Name
                VStack(spacing: 8) {
                    Text("Turnike")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)

                    Text("Metro yolculuğun, sosyal çemberin")
                        .font(.body.weight(.medium))
                        .foregroundStyle(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 10)
                }
            }

            Spacer()

            // MARK: - Features
            VStack(spacing: 16) {
                featureRow(icon: "person.2.fill", text: "Aynı hattaki insanlarla tanış")
                featureRow(icon: "shield.checkered", text: "Gizlilik senin elinde")
                featureRow(icon: "sparkles", text: "Seyahatin bir anlam kazansın")
            }
            .padding(.horizontal, 32)
            .opacity(showContent ? 1 : 0)
            .offset(y: showContent ? 0 : 30)

            Spacer()

            // MARK: - Start Button
            Button(action: onStart) {
                HStack(spacing: 10) {
                    Text("Hadi Başlayalım")
                        .font(.title3.weight(.bold))

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.cyan, .cyan.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .cyan.opacity(0.4), radius: 20, y: 8)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 28)
            .padding(.bottom, 48)
            .opacity(showContent ? 1 : 0)
            .scaleEffect(showContent ? 1 : 0.9)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                showContent = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true).delay(0.5)) {
                pulseGlow = true
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(.cyan)
                .frame(width: 36, height: 36)
                .background {
                    Circle()
                        .fill(.cyan.opacity(0.15))
                }

            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))

            Spacer()
        }
    }
}
