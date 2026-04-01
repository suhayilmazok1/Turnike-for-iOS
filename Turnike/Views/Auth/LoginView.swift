import SwiftUI
import AuthenticationServices

// MARK: - LoginView

/// Yenilenmiş, temiz OAuth ve Telefon odaklı giriş ekranı (İlham: Tinder/Bumble tarzı)
struct LoginView: View {
    
    @Environment(\.webAuthenticationSession) private var webAuthSession
    private let authService = AuthService.shared
    
    @State private var errorMessage: String?
    // Pembe ve Mavi'nin 'Mat' (Matte/Desaturated) tonlarıyla geçişi
    private let backgroundGradient = LinearGradient(
        stops: [
            // Mat Pembe (Gül Kurusu hissiyatı)
            .init(color: Color(red: 215/255, green: 130/255, blue: 165/255), location: 0.0),
            // Mat Açık Mavi (Çok bağırmayan, paslanmış mavi)
            .init(color: Color(red: 110/255, green: 155/255, blue: 200/255), location: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            // Arka Plan
            backgroundGradient
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // Logo ve Başlık
                VStack(spacing: 8) {
                    Image(systemName: "tram.fill")
                        .font(.system(size: 65, weight: .bold))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                    
                    Text("Turnike")
                        .font(.custom("HelveticaNeue-Bold", size: 40))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                }
                
                Spacer()
                
                // Alt Kontroller
                VStack(spacing: 20) {
                    
                    // Terms & Privacy Text
                    (Text("By tapping 'Sign in' you agree to our ")
                     + Text("Terms").underline()
                     + Text(". Learn how we process your data in our ")
                     + Text("Privacy Policy").underline()
                     + Text(" and ")
                     + Text("Cookies Policy").underline()
                     + Text("."))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .padding(.bottom, 10)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(Color.red.opacity(0.8))
                            .clipShape(Capsule())
                    }
                    
                    // Butonlar
                    VStack(spacing: 12) {
                        
                        // Apple Girişi (Yakında)
                        oauthButton(
                            title: "Apple ile Giriş Yap (Yakında)",
                            icon: "applelogo",
                            textColor: .black,
                            backgroundColor: .white
                        ) {
                            // TODO: İleride native Apple Login
                        }
                        .disabled(true)
                        .opacity(0.9)
                        
                        // Google Girişi
                        oauthButton(
                            title: "Google ile Giriş Yap",
                            icon: "g.circle.fill",
                            textColor: .black,
                            backgroundColor: .white
                        ) {
                            loginWithGoogle()
                        }
                        
                        // Telefon Numarası
                        oauthButton(
                            title: "Telefon Numarası (Yakında)",
                            icon: "phone.fill",
                            textColor: .white,
                            backgroundColor: .clear,
                            borderColor: .white
                        ) {
                            // TODO: İleride OTP
                        }
                        .disabled(true)
                        .opacity(0.8)
                    }
                    .padding(.horizontal, 30)
                    
                    // Giriş sorunu butonu
                    Button("Giriş yapamıyor musun?") {
                        // TODO: Yardım sayfası
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.top, 10)
                }
                .padding(.bottom, 40)
            }
        }
    }
    
    // MARK: - Actions
    
    private func loginWithGoogle() {
        Task {
            do {
                let url = try await authService.getGoogleOAuthURL()
                let callbackURL = try await webAuthSession.authenticate(
                    using: url,
                    callbackURLScheme: "turnike",
                    preferredBrowserSession: .ephemeral
                )
                try await authService.handleOAuthRedirect(url: callbackURL)
            } catch {
                await MainActor.run { errorMessage = error.localizedDescription }
            }
        }
    }
    
    // MARK: - UI Helpers
    
    @ViewBuilder
    private func oauthButton(title: String, icon: String, textColor: Color, backgroundColor: Color, borderColor: Color = .clear, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3.weight(.bold))
                    // Hizalama için ikonu sola çekip tam merkezli hissi vermek:
                    .frame(width: 30, alignment: .leading)
                
                Text(title)
                    .font(.headline.weight(.bold))
                
                Spacer().frame(width: 30) // Sağ tarafı dengeler
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 24)
            .foregroundStyle(textColor)
            .background(backgroundColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(borderColor, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}
