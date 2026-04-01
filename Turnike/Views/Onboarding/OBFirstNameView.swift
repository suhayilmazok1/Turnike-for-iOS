import SwiftUI

// MARK: - OBFirstNameView

struct OBFirstNameView: View {

    @Bindable var viewModel: ProfileOnboardingViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("İsmin ne?")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 32)

            TextField("", text: $viewModel.firstName)
                .font(.system(size: 18))
                .foregroundStyle(.white)
                .focused($isFocused)
                .padding(.vertical, 14)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(.white.opacity(0.2))
                        .frame(height: 1)
                }
                .overlay(alignment: .bottomLeading) {
                    // Placeholder
                    if viewModel.firstName.isEmpty {
                        Text("Adını gir")
                            .font(.system(size: 18))
                            .foregroundStyle(.white.opacity(0.3))
                            .padding(.bottom, 14)
                    }
                }
                .padding(.top, 24)

            Text("Profilinde böyle görünecek.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.top, 10)

            Text("Sonradan değiştirilemez.")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.7))
                .padding(.top, 2)

            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear { isFocused = true }
    }
}
