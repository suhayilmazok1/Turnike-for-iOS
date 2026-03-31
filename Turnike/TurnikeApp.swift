import SwiftUI

// MARK: - TurnikeApp

/// Turnike uygulamasının giriş noktası.
@main
struct TurnikeApp: App {

    @State private var syncManager = SyncManager.shared
    @State private var isOnboardingComplete = ProfileStorageService.shared.isOnboardingComplete

    var body: some Scene {
        WindowGroup {
            Group {
                if isOnboardingComplete {
                    MainTabView {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
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

