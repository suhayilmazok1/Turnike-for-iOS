import SwiftUI

// MARK: - OnboardingContainerView

/// Tinder/Hinge tarzı adım adım profil oluşturma akışı.
struct OnboardingContainerView: View {

    @State private var viewModel = ProfileOnboardingViewModel()
    var onComplete: () -> Void

    // Gradient renkleri (pembe → mavi)
    private let progressGradient = LinearGradient(
        colors: [
            Color(red: 215/255, green: 130/255, blue: 165/255),
            Color(red: 110/255, green: 155/255, blue: 200/255)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    // Hangi adımlar "Skip" edilebilir
    private var canSkip: Bool {
        switch viewModel.currentStep {
        case .lifestyle, .aboutYou, .bioPrompts: return true
        default: return false
        }
    }

    var body: some View {
        ZStack {
            // Koyu arka plan
            Color(red: 20/255, green: 20/255, blue: 30/255)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Top Bar (Progress + Back + Skip)
                topBar

                // MARK: - Content
                Group {
                    switch viewModel.currentStep {
                    case .firstName:
                        OBFirstNameView(viewModel: viewModel)
                    case .phone:
                        OBPhoneView(viewModel: viewModel)
                    case .birthday:
                        OBBirthdayView(viewModel: viewModel)
                    case .gender:
                        OBGenderView(viewModel: viewModel)
                    case .lookingFor:
                        OBLookingForView(viewModel: viewModel)
                    case .lifestyle:
                        OBLifestyleView(viewModel: viewModel)
                    case .aboutYou:
                        OBAboutYouView(viewModel: viewModel)
                    case .interests:
                        OBInterestsView(viewModel: viewModel)
                    case .bioPrompts:
                        OBBioPromptsView(viewModel: viewModel)
                    case .privacyMode:
                        OBPrivacyModeView(viewModel: viewModel)
                    case .photos:
                        OBPhotosView(viewModel: viewModel)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                // MARK: - Bottom Bar
                bottomBar
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.9), value: viewModel.currentStep)
        .preferredColorScheme(.dark)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        VStack(spacing: 0) {
            // Gradient Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    // Background track
                    Capsule()
                        .fill(.white.opacity(0.1))
                        .frame(height: 4)

                    // Fill
                    Capsule()
                        .fill(progressGradient)
                        .frame(width: geo.size.width * viewModel.currentStep.progress, height: 4)
                        .animation(.spring(response: 0.5), value: viewModel.currentStep)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 20)
            .padding(.top, 8)

            // Geri + Skip
            HStack {
                // Geri butonu (ilk adımda çıkış)
                if viewModel.currentStep.rawValue > 0 {
                    Button {
                        viewModel.goBack()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                    }
                } else {
                    // İlk adımda çıkış butonu
                    Button {
                        Task {
                            try? await AuthService.shared.signOut()
                        }
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                    }
                }

                Spacer()

                // Skip butonu
                if canSkip {
                    Button {
                        viewModel.skipStep()
                    } label: {
                        Text("Geç")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            // Lifestyle / About You: "Next X / 4" counter
            if viewModel.currentStep == .lifestyle {
                counterText("Sonraki \(viewModel.answeredLifestyleCount) / 4")
            } else if viewModel.currentStep == .aboutYou {
                counterText("Sonraki \(viewModel.answeredAboutYouCount) / 4")
            }

            // Son adımda "Profili Tamamla" butonu
            if viewModel.currentStep == .photos {
                Button {
                    viewModel.completeOnboarding()
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        onComplete()
                    }
                } label: {
                    nextButtonLabel("Profili Tamamla ✨")
                }
                .disabled(!viewModel.canProceed || viewModel.isCompleting)
                .opacity(viewModel.canProceed ? 1 : 0.5)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            } else {
                // Normal "Sonraki" butonu
                Button {
                    viewModel.goNext()
                } label: {
                    nextButtonLabel("Sonraki")
                }
                .disabled(!viewModel.canProceed)
                .opacity(viewModel.canProceed ? 1 : 0.5)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)
            }
        }
    }

    // MARK: - Helpers

    private func nextButtonLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(viewModel.canProceed ? .black : .white.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                Capsule()
                    .fill(viewModel.canProceed
                        ? AnyShapeStyle(.white)
                        : AnyShapeStyle(.white.opacity(0.1)))
            }
    }

    private func counterText(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundStyle(.white.opacity(0.4))
            .padding(.bottom, 8)
    }
}
