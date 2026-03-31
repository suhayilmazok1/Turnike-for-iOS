import SwiftUI

// MARK: - Glass Modifier

/// Glassmorphism "buzlu cam" efekti.
/// Metro hattının koltuk rengine göre kenar parıltısı ve arka plan tonu verir.
struct GlassModifier: ViewModifier {

    let lineColor: Color
    let cornerRadius: CGFloat
    let opacity: Double

    init(lineColor: Color = .white, cornerRadius: CGFloat = 20, opacity: Double = 0.15) {
        self.lineColor = lineColor
        self.cornerRadius = cornerRadius
        self.opacity = opacity
    }

    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(lineColor.opacity(opacity))
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        lineColor.opacity(0.6),
                                        lineColor.opacity(0.1),
                                        .white.opacity(0.15),
                                        lineColor.opacity(0.3)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: lineColor.opacity(0.15), radius: 12, x: 0, y: 8)
            }
    }
}

// MARK: - View Extension

extension View {

    /// Basit glassmorphism efekti.
    func glass(
        color: Color = .white,
        cornerRadius: CGFloat = 20,
        opacity: Double = 0.15
    ) -> some View {
        modifier(GlassModifier(lineColor: color, cornerRadius: cornerRadius, opacity: opacity))
    }

    /// Metro hattı temalı glassmorphism kartı.
    func glassCard(line: MetroLine, cornerRadius: CGFloat = 20) -> some View {
        modifier(GlassModifier(lineColor: line.seatColor, cornerRadius: cornerRadius, opacity: 0.12))
    }
}

// MARK: - GlassCard View

/// Hazır glassmorphism kart bileşeni.
struct GlassCard<Content: View>: View {

    let line: MetroLine
    let cornerRadius: CGFloat
    @ViewBuilder let content: () -> Content

    init(line: MetroLine, cornerRadius: CGFloat = 20, @ViewBuilder content: @escaping () -> Content) {
        self.line = line
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        content()
            .padding()
            .glassCard(line: line, cornerRadius: cornerRadius)
    }
}

// MARK: - Floating Glow Button

/// Parlayan, glassmorphism uyumlu buton.
struct GlowButton: View {

    let title: String
    let icon: String?
    let color: Color
    let action: () -> Void

    init(_ title: String, icon: String? = nil, color: Color = .white, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.color = color
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.semibold))
                }
                Text(title)
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .background {
                Capsule()
                    .fill(color.gradient)
                    .shadow(color: color.opacity(0.5), radius: 16, y: 6)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Animated Background

/// Dinamik koltuk rengi arka planı — yumuşak gradient animasyonu.
struct AnimatedMetroBackground: View {

    let line: MetroLine
    @State private var animate = false

    var body: some View {
        ZStack {
            // Base dark
            Color.black.ignoresSafeArea()

            // Animated gradient orbs
            Circle()
                .fill(line.seatColor.opacity(0.3))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(
                    x: animate ? 50 : -50,
                    y: animate ? -80 : 80
                )

            Circle()
                .fill(line.accentGradient)
                .frame(width: 250, height: 250)
                .blur(radius: 90)
                .offset(
                    x: animate ? -70 : 70,
                    y: animate ? 120 : -40
                )

            Circle()
                .fill(line.seatColor.opacity(0.15))
                .frame(width: 200, height: 200)
                .blur(radius: 70)
                .offset(
                    x: animate ? 100 : -30,
                    y: animate ? -150 : 100
                )
        }
        .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animate)
        .onAppear { animate = true }
    }
}

// MARK: - Sync Status Badge

/// Bekleyen senkronizasyon sayısını gösteren rozet.
struct SyncBadge: View {

    let count: Int
    let color: Color

    var body: some View {
        if count > 0 {
            HStack(spacing: 4) {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.caption2.weight(.bold))
                Text("\(count)")
                    .font(.caption2.weight(.bold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                Capsule()
                    .fill(color.opacity(0.8))
            }
        }
    }
}
