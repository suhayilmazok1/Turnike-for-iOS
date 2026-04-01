import SwiftUI

// MARK: - OBLookingForView

struct OBLookingForView: View {

    @Bindable var viewModel: ProfileOnboardingViewModel

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Ne arıyorsun?")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 32)

            Text("Değişirse sorun değil. Herkes için bir şey var.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.top, 6)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(LookingForOption.allCases, id: \.self) { option in
                    lookingForCard(option)
                }
            }
            .padding(.top, 28)

            Spacer()
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Card

    private func lookingForCard(_ option: LookingForOption) -> some View {
        let isSelected = viewModel.lookingFor == option
        return Button {
            withAnimation(.spring(response: 0.3)) {
                viewModel.lookingFor = option
            }
        } label: {
            VStack(spacing: 8) {
                Text(option.emoji)
                    .font(.system(size: 36))

                Text(option.rawValue)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background {
                RoundedRectangle(cornerRadius: 14)
                    .fill(isSelected
                        ? Color(red: 215/255, green: 130/255, blue: 165/255).opacity(0.15)
                        : .white.opacity(0.06))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isSelected
                                ? Color(red: 215/255, green: 130/255, blue: 165/255)
                                : .clear,
                                lineWidth: 2
                            )
                    }
            }
        }
        .buttonStyle(.plain)
    }
}
