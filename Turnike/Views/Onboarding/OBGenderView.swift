import SwiftUI

// MARK: - OBGenderView

struct OBGenderView: View {

    @Bindable var viewModel: ProfileOnboardingViewModel
    
    // Gradient renkler (pembe→mavi)
    private let accentGradient = LinearGradient(
        colors: [Color(red: 215/255, green: 130/255, blue: 165/255),
                 Color(red: 110/255, green: 155/255, blue: 200/255)],
        startPoint: .leading, endPoint: .trailing
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Cinsiyetin ne?")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 32)

            VStack(spacing: 14) {
                genderButton("Kadın", gender: .female)
                genderButton("Erkek", gender: .male)
                genderButton("Non-Binary", gender: .nonBinary)
                genderButton("Diğer", gender: .other)
            }
            .padding(.top, 28)

            Spacer()

            // "Profilimde göster" checkbox
            HStack(spacing: 10) {
                Button {
                    viewModel.showGenderOnProfile.toggle()
                } label: {
                    Image(systemName: viewModel.showGenderOnProfile ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundStyle(viewModel.showGenderOnProfile
                            ? AnyShapeStyle(accentGradient)
                            : AnyShapeStyle(.white.opacity(0.4)))
                }

                Text("Cinsiyetimi profilimde göster")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - Gender Button

    private func genderButton(_ title: String, gender: Gender) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                viewModel.selectedGender = gender
            }
        } label: {
            Text(title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(viewModel.selectedGender == gender
                            ? Color(red: 215/255, green: 130/255, blue: 165/255).opacity(0.15)
                            : .clear)
                        .overlay {
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(
                                    viewModel.selectedGender == gender
                                    ? AnyShapeStyle(accentGradient)
                                    : AnyShapeStyle(.white.opacity(0.2)),
                                    lineWidth: viewModel.selectedGender == gender ? 2 : 1
                                )
                        }
                }
        }
        .buttonStyle(.plain)
    }
}
