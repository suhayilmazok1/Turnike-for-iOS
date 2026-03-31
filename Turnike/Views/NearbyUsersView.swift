import SwiftUI

// MARK: - NearbyUsersView

/// Aynı hattaki yakın kullanıcıları kart olarak gösterir.
/// Offline cache üzerinden çalışır — tünelde de göz atılabilir.
struct NearbyUsersView: View {

    @Environment(\.themeManager) private var theme

    let currentLine: MetroLine
    let users: [User]
    let checkIns: [CheckIn]
    let pendingSyncCount: Int
    let isConnected: Bool

    var onLike: ((User) -> Void)?
    var onSuperLike: ((User) -> Void)?
    var onSkip: ((User) -> Void)?
    var onCheckOut: (() -> Void)?

    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGSize = .zero
    @State private var showCheckOutConfirm = false

    var body: some View {
        ZStack {
            // Dinamik arka plan
            AnimatedMetroBackground(line: currentLine)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top Bar
                topBar

                // MARK: - Card Stack
                if users.isEmpty {
                    emptyState
                } else {
                    cardStack
                }

                Spacer()

                // MARK: - Action Buttons
                if !users.isEmpty && currentIndex < users.count {
                    actionButtons
                }

                // MARK: - Check Out Button
                checkOutButton
            }
        }
        .alert("Metrodan İndin mi?", isPresented: $showCheckOutConfirm) {
            Button("İndim", role: .destructive) { onCheckOut?() }
            Button("Hayır", role: .cancel) {}
        } message: {
            Text("Check-out yaptığında profilin aktif listeden kaldırılacak.")
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            // Hat bilgisi
            VStack(alignment: .leading, spacing: 2) {
                Text(currentLine.displayName)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.white)

                HStack(spacing: 6) {
                    Circle()
                        .fill(isConnected ? .green : .red)
                        .frame(width: 6, height: 6)
                    Text(isConnected ? "Bağlı" : "Tünel")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            Spacer()

            // Sync badge
            SyncBadge(count: pendingSyncCount, color: currentLine.seatColor)

            // Kullanıcı sayısı
            HStack(spacing: 4) {
                Image(systemName: "person.2.fill")
                    .font(.caption)
                Text("\(users.count)")
                    .font(.caption.weight(.bold))
            }
            .foregroundStyle(.white.opacity(0.7))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .glass(color: currentLine.seatColor, cornerRadius: 10, opacity: 0.15)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    // MARK: - Card Stack

    private var cardStack: some View {
        ZStack {
            // Arka plan kartları (peek)
            ForEach(visibleRange.reversed(), id: \.self) { index in
                let offset = index - currentIndex

                if index < users.count {
                    let user = users[index]
                    let checkIn = checkInFor(user: user)

                    UserCardView(user: user, checkIn: checkIn, line: currentLine)
                        .scaleEffect(1.0 - Double(offset) * 0.05)
                        .offset(y: Double(offset) * 12)
                        .opacity(offset == 0 ? 1 : 0.7)
                        .zIndex(Double(users.count - index))
                        .offset(offset == 0 ? dragOffset : .zero)
                        .rotationEffect(
                            offset == 0
                            ? .degrees(Double(dragOffset.width) / 25)
                            : .zero
                        )
                        .gesture(offset == 0 ? dragGesture : nil)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "tram.fill")
                .font(.system(size: 60))
                .foregroundStyle(currentLine.seatColor.opacity(0.4))

            Text("Şu an yakınında kimse yok")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))

            Text("Sonraki durakta yeni yolcular görünebilir")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(40)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 24) {
            // Skip
            actionCircle(icon: "xmark", color: .white.opacity(0.5), size: 52) {
                skipCurrent()
            }

            // Super Like
            actionCircle(icon: "star.fill", color: .yellow, size: 48) {
                superLikeCurrent()
            }

            // Like
            actionCircle(icon: "heart.fill", color: currentLine.seatColor, size: 60) {
                likeCurrent()
            }
        }
        .padding(.bottom, 8)
    }

    private func actionCircle(icon: String, color: Color, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: size * 0.35, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background {
                    Circle()
                        .fill(color.opacity(0.2))
                        .overlay {
                            Circle()
                                .stroke(color.opacity(0.4), lineWidth: 1.5)
                        }
                        .shadow(color: color.opacity(0.3), radius: 12)
                }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Check Out

    private var checkOutButton: some View {
        Button {
            showCheckOutConfirm = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "arrow.down.right.and.arrow.up.left")
                    .font(.caption.weight(.semibold))
                Text("İndim")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(.white.opacity(0.7))
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .glass(color: .red, cornerRadius: 20, opacity: 0.15)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 16)
    }

    // MARK: - Gestures

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
            }
            .onEnded { value in
                let threshold: CGFloat = 100
                if value.translation.width > threshold {
                    // Sağa sürükle → Like
                    likeCurrent()
                } else if value.translation.width < -threshold {
                    // Sola sürükle → Skip
                    skipCurrent()
                } else {
                    withAnimation(.spring(response: 0.4)) {
                        dragOffset = .zero
                    }
                }
            }
    }

    // MARK: - Actions

    private func likeCurrent() {
        guard currentIndex < users.count else { return }
        let user = users[currentIndex]
        withAnimation(.spring(response: 0.5)) {
            dragOffset = CGSize(width: 500, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onLike?(user)
            dragOffset = .zero
            currentIndex += 1
        }
    }

    private func superLikeCurrent() {
        guard currentIndex < users.count else { return }
        let user = users[currentIndex]
        withAnimation(.spring(response: 0.5)) {
            dragOffset = CGSize(width: 0, height: -500)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSuperLike?(user)
            dragOffset = .zero
            currentIndex += 1
        }
    }

    private func skipCurrent() {
        guard currentIndex < users.count else { return }
        let user = users[currentIndex]
        withAnimation(.spring(response: 0.5)) {
            dragOffset = CGSize(width: -500, height: 0)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onSkip?(user)
            dragOffset = .zero
            currentIndex += 1
        }
    }

    // MARK: - Helpers

    private var visibleRange: ClosedRange<Int> {
        let start = currentIndex
        let end = min(currentIndex + 2, users.count - 1)
        guard start <= end else { return 0...0 }
        return start...end
    }

    private func checkInFor(user: User) -> CheckIn {
        checkIns.first { $0.userId == user.id } ?? CheckIn(
            userId: user.id,
            line: currentLine,
            direction: currentLine.directions.end,
            currentStation: currentLine.stations.first ?? ""
        )
    }
}
