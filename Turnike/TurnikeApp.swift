import SwiftUI

// MARK: - TurnikeApp

/// Turnike uygulamasının giriş noktası.
@main
struct TurnikeApp: App {

    @State private var authService = AuthService.shared
    @State private var syncManager = SyncManager.shared
    @State private var isOnboardingComplete = ProfileStorageService.shared.isOnboardingComplete

    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isCheckingSession {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.ignoresSafeArea())
                } else if !authService.isAuthenticated {
                    LoginView()
                        .transition(.opacity)
                } else if isOnboardingComplete {
                    MainTabView {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            // Profil silinince onboarding'e dön (logout da yapılabilir)
                            isOnboardingComplete = false
                        }
                    }
                    .transition(.opacity)
                } else {
                    OnboardingContainerView {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isOnboardingComplete = true
                        }
                    }
                    .transition(.opacity)
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                if isOnboardingComplete {
                    syncManager.startMonitoring()
                }
            }
            .onDisappear {
                syncManager.stopMonitoring()
            }
        }
    }
}

