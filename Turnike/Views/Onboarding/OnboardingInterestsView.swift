import SwiftUI

// MARK: - OnboardingInterestsView

/// Chip-style ilgi alanı seçimi.
struct OnboardingInterestsView: View {

    @Bindable var viewModel: ProfileOnboardingViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Bilgi kartı
                HStack(spacing: 12) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.cyan)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("En az 3, en fazla 8 ilgi alanı seç")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.7))
                        Text("Seçili: \(viewModel.selectedInterests.count)")
                            .font(.caption)
                            .foregroundStyle(.cyan)
                    }

                    Spacer()

                    // Durum göstergesi
                    if viewModel.selectedInterests.count >= 3 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                .padding(14)
                .glass(cornerRadius: 14, opacity: 0.1)
                .padding(.horizontal, 20)

                // MARK: - Interest Chips
                FlowLayout(spacing: 10) {
                    ForEach(PredefinedInterest.allCases, id: \.self) { interest in
                        interestChip(interest)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Interest Chip

    private func interestChip(_ interest: PredefinedInterest) -> some View {
        let isSelected = viewModel.selectedInterests.contains(interest)
        let isMaxed = viewModel.selectedInterests.count >= 8 && !isSelected

        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                viewModel.toggleInterest(interest)
            }
        } label: {
            HStack(spacing: 6) {
                Text(interest.icon)
                    .font(.body)

                Text(interest.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(isSelected ? .black : .white)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(isSelected
                          ? Color.cyan
                          : Color.white.opacity(isMaxed ? 0.03 : 0.08))
            }
            .overlay {
                Capsule()
                    .stroke(isSelected ? Color.clear : Color.white.opacity(0.12), lineWidth: 1)
            }
            .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
        .opacity(isMaxed ? 0.4 : 1.0)
        .disabled(isMaxed)
    }
}
