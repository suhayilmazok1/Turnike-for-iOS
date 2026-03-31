import SwiftUI

// MARK: - OnboardingContainerView

/// Tinder/Bumble ilhamlı adım adım profil oluşturma akışı.
struct OnboardingContainerView: View {

    @State private var viewModel = ProfileOnboardingViewModel()
    var onComplete: () -> Void

    var body: some View {
        ZStack {
            // Dinamik arka plan
            AnimatedMetroBackground(line: .m2)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: - Header
                if viewModel.currentStep != .welcome {
                    onboardingHeader
                }

                // MARK: - Content
                Group {
                    switch viewModel.currentStep {
                    case .welcome:
                        OnboardingWelcomeView {
                            viewModel.goNext()
                        }
                    case .nameAge:
                        OnboardingNameAgeView(viewModel: viewModel)
                    case .photos:
                        OnboardingPhotosView(viewModel: viewModel)
                    case .bioPrompts:
                        OnboardingBioPromptsView(viewModel: viewModel)
                    case .interests:
                        OnboardingInterestsView(viewModel: viewModel)
                    case .privacyMode:
                        OnboardingPrivacyView(viewModel: viewModel)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))

                // MARK: - Bottom Bar
                if viewModel.currentStep != .welcome {
                    bottomBar
                }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: viewModel.currentStep)
        .preferredColorScheme(.dark)
    }

    // MARK: - Header

    private var onboardingHeader: some View {
        VStack(spacing: 12) {
            HStack {
                // Geri butonu
                Button {
                    viewModel.goBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .glass(cornerRadius: 12, opacity: 0.2)
                }

                Spacer()

                // İlerleme göstergesi
                progressDots

                Spacer()

                // Boşluk (simetri)
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 20)

            Text(viewModel.currentStep.title)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)

            Text(viewModel.currentStep.subtitle)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    private var progressDots: some View {
        HStack(spacing: 6) {
            ForEach(OnboardingStep.allCases, id: \.self) { step in
                Capsule()
                    .fill(step.rawValue <= viewModel.currentStep.rawValue
                          ? Color.cyan
                          : Color.white.opacity(0.2))
                    .frame(width: step == viewModel.currentStep ? 24 : 8, height: 4)
                    .animation(.spring(response: 0.3), value: viewModel.currentStep)
            }
        }
    }

    // MARK: - Bottom Bar

    private var bottomBar: some View {
        VStack(spacing: 0) {
            if viewModel.currentStep == .privacyMode {
                // Son adım — Tamamla butonu
                GlowButton("Profili Tamamla ✨", icon: "checkmark.circle.fill", color: .cyan) {
                    viewModel.completeOnboarding()
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        onComplete()
                    }
                }
                .opacity(viewModel.canProceed ? 1 : 0.5)
                .disabled(!viewModel.canProceed)
                .padding(.bottom, 32)
            } else {
                // Devam butonu
                GlowButton("Devam Et", icon: "arrow.right", color: .cyan) {
                    viewModel.goNext()
                }
                .opacity(viewModel.canProceed ? 1 : 0.5)
                .disabled(!viewModel.canProceed)
                .padding(.bottom, 32)
            }
        }
        .padding(.horizontal, 20)
    }
}
