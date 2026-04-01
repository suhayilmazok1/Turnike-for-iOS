import SwiftUI

// MARK: - OBPhoneView

struct OBPhoneView: View {

    @Bindable var viewModel: ProfileOnboardingViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Telefon numaran?")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 32)

            HStack(spacing: 12) {
                // Ülke kodu
                HStack(spacing: 6) {
                    Text("🇹🇷")
                        .font(.title2)
                    Text("+90")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.08))
                }

                TextField("", text: $viewModel.phoneNumber)
                    .font(.system(size: 18))
                    .foregroundStyle(.white)
                    .keyboardType(.phonePad)
                    .focused($isFocused)
                    .padding(.vertical, 14)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(.white.opacity(0.2))
                            .frame(height: 1)
                    }
                    .overlay(alignment: .bottomLeading) {
                        if viewModel.phoneNumber.isEmpty {
                            Text("5XX XXX XX XX")
                                .font(.system(size: 18))
                                .foregroundStyle(.white.opacity(0.3))
                                .padding(.bottom, 14)
                        }
                    }
            }
            .padding(.top, 24)

            Text("Doğrulama kodu daha sonra aktif edilecek.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.top, 10)

            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear { isFocused = true }
    }
}
