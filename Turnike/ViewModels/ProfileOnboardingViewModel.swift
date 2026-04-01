import SwiftUI
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - OnboardingStep

enum OnboardingStep: Int, CaseIterable {
    case firstName = 0
    case phone = 1
    case birthday = 2
    case gender = 3
    case lookingFor = 4
    case lifestyle = 5
    case aboutYou = 6
    case interests = 7
    case bioPrompts = 8
    case privacyMode = 9
    case photos = 10

    var progress: Double {
        Double(rawValue + 1) / Double(Self.allCases.count)
    }
}

// MARK: - LookingFor Option

enum LookingForOption: String, CaseIterable {
    case longTerm = "Uzun süreli ilişki"
    case longOpenShort = "Uzun süreli, kısaya açık"
    case shortOpenLong = "Kısa süreli, uzuna açık"
    case shortTerm = "Kısa süreli eğlence"
    case newFriends = "Yeni arkadaşlar"
    case figuring = "Henüz karar veremedim"

    var emoji: String {
        switch self {
        case .longTerm:       return "💕"
        case .longOpenShort:  return "😍"
        case .shortOpenLong:  return "🥂"
        case .shortTerm:      return "🎉"
        case .newFriends:     return "👋"
        case .figuring:       return "🤔"
        }
    }
}

// MARK: - Lifestyle Categories

let lifestyleOptions: [(category: String, icon: String, key: WritableKeyPath<LifestyleAnswers, String>, options: [String])] = [
    ("Ne sıklıkla içersin?", "🍷", \.drinking,
     ["İçmem", "Nadiren", "Sosyal içici", "Özel günlerde", "Haftasonları", "Çoğu akşam"]),
    ("Sigara kullanır mısın?", "🚬", \.smoking,
     ["İçmem", "Sosyal içici", "İçerken içerim", "Bırakmaya çalışıyorum", "İçerim"]),
    ("Spor yapar mısın?", "💪", \.workout,
     ["Her gün", "Sık sık", "Bazen", "Nadiren", "Hiç"]),
    ("Evcil hayvanın var mı?", "🐾", \.pets,
     ["Kedi", "Köpek", "Her ikisi", "Sürüngen", "Kuş", "Balık", "Yok ama isterim", "Yok"]),
]

// MARK: - About You Categories

let aboutYouOptions: [(category: String, icon: String, key: WritableKeyPath<AboutYouAnswers, String>, options: [String])] = [
    ("İletişim tarzın nedir?", "💬", \.communication,
     ["Mesajcı", "Telefon", "Video", "Kötü mesajcı", "Yüz yüze"]),
    ("Sevgi dilin nedir?", "❤️", \.loveLanguage,
     ["Düşünceli jestler", "Hediyeler", "Dokunma", "İltifatlar", "Birlikte vakit"]),
    ("Eğitim durumun?", "🎓", \.education,
     ["Lise", "Üniversite", "Yüksek Lisans", "Doktora", "Meslek Yüksekokulu"]),
    ("Burcun ne?", "⭐", \.zodiac,
     ["Koç", "Boğa", "İkizler", "Yengeç", "Aslan", "Başak",
      "Terazi", "Akrep", "Yay", "Oğlak", "Kova", "Balık"]),
]

// MARK: - Interest Categories

struct InterestCategory: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let items: [String]
}

let interestCategories: [InterestCategory] = [
    InterestCategory(name: "Müzik", emoji: "🎵", items: [
        "Pop", "Rock", "Hip-Hop", "Jazz", "Klasik", "R&B",
        "Elektronik", "K-Pop", "Metal", "Indie", "Türkçe Pop", "Arabesk"
    ]),
    InterestCategory(name: "Doğa & Macera", emoji: "🏔️", items: [
        "Yürüyüş", "Kamp", "Dalış", "Tırmanış", "Sörf",
        "Kayak", "Seyahat", "Fotoğrafçılık", "Bisiklet"
    ]),
    InterestCategory(name: "Sosyal & İçerik", emoji: "📱", items: [
        "Instagram", "X", "TikTok", "Spotify", "YouTube",
        "Podcast", "Blog", "Pinterest", "Twitch"
    ]),
    InterestCategory(name: "Spor & Fitness", emoji: "⚽", items: [
        "Futbol", "Basketbol", "Tenis", "Koşu", "Yoga",
        "Pilates", "Yüzme", "Fitness", "Boks", "Dans"
    ]),
    InterestCategory(name: "Ev Keyfi", emoji: "🏠", items: [
        "Okuma", "Ev Egzersizi", "Dizi Maratonu", "Yemek Yapma",
        "Bahçecilik", "Kutu Oyunları", "Bilgi Yarışması", "Puzzle"
    ]),
    InterestCategory(name: "Film & TV", emoji: "🎬", items: [
        "Aksiyon", "Animasyon", "Suç", "Fantastik",
        "Belgesel", "Drama", "Komedi", "Korku", "Bilim Kurgu"
    ]),
    InterestCategory(name: "Oyun", emoji: "🎮", items: [
        "PC Gaming", "Konsol", "Mobil Oyun", "Board Games",
        "RPG", "FPS", "Strateji", "E-Spor"
    ]),
    InterestCategory(name: "Yeme & İçme", emoji: "🍕", items: [
        "Kahve", "Çay", "Şarap", "Kokteyl", "Sokak Lezzetleri",
        "Fine Dining", "Vegan", "Tatlıcı", "Barbekü"
    ]),
]

// MARK: - ProfileOnboardingViewModel

@Observable
final class ProfileOnboardingViewModel {

    // MARK: - Navigation State
    var currentStep: OnboardingStep = .firstName

    // Step 1: First Name
    var firstName: String = ""

    // Step 2: Phone
    var phoneNumber: String = ""

    // Step 3: Birthday
    var birthDay: String = ""
    var birthMonth: String = ""
    var birthYear: String = ""

    var birthDate: Date? {
        guard let d = Int(birthDay), let m = Int(birthMonth), let y = Int(birthYear),
              d >= 1, d <= 31, m >= 1, m <= 12, y >= 1900, y <= 2010 else { return nil }
        var comps = DateComponents()
        comps.day = d; comps.month = m; comps.year = y
        return Calendar.current.date(from: comps)
    }

    var age: Int {
        guard let bd = birthDate else { return 0 }
        return Calendar.current.dateComponents([.year], from: bd, to: .now).year ?? 0
    }

    // Step 4: Gender
    var selectedGender: Gender = .preferNotToSay
    var showGenderOnProfile: Bool = true

    // Step 5: Looking For
    var lookingFor: LookingForOption? = nil

    // Step 6: Lifestyle
    var lifestyle = LifestyleAnswers()
    var answeredLifestyleCount: Int {
        [lifestyle.drinking, lifestyle.smoking, lifestyle.workout, lifestyle.pets]
            .filter { !$0.isEmpty }.count
    }

    // Step 7: About You
    var aboutYou = AboutYouAnswers()
    var answeredAboutYouCount: Int {
        [aboutYou.communication, aboutYou.loveLanguage, aboutYou.education, aboutYou.zodiac]
            .filter { !$0.isEmpty }.count
    }

    // Step 8: Interests
    var selectedInterests: Set<String> = []

    // Step 9: Bio & Prompts
    var bio: String = ""
    var prompts: [ProfilePrompt] = []
    var selectedPromptQuestion: String = ProfilePrompt.availableQuestions[0]
    var currentPromptAnswer: String = ""

    // Step 10: Privacy Mode
    var privacyMode: PrivacyMode = .instant

    // Step 11: Photos
    var selectedPhotos: [PhotosPickerItem] = []
    var photoImages: [UIImage?] = Array(repeating: nil, count: 6)
    var cropTargetIndex: Int? = nil
    var imageForCropping: UIImage? = nil

    // General
    var isCompleting: Bool = false
    private let storage = ProfileStorageService.shared

    // MARK: - Validation

    var canProceed: Bool {
        switch currentStep {
        case .firstName:
            return !firstName.trimmingCharacters(in: .whitespaces).isEmpty
        case .phone:
            return phoneNumber.count >= 10
        case .birthday:
            return birthDate != nil && age >= 18 && age <= 99
        case .gender:
            return selectedGender != .preferNotToSay
        case .lookingFor:
            return lookingFor != nil
        case .lifestyle:
            return answeredLifestyleCount >= 1
        case .aboutYou:
            return true // Skip edilebilir
        case .interests:
            return selectedInterests.count >= 3
        case .bioPrompts:
            return true // Opsiyonel
        case .privacyMode:
            return true // Varsayılan .instant zaten seçili
        case .photos:
            return photoImages.compactMap({ $0 }).count >= 2
        }
    }

    var photoCount: Int {
        photoImages.compactMap({ $0 }).count
    }

    // MARK: - Navigation

    func goNext() {
        guard canProceed else { return }
        if let nextRaw = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                currentStep = nextRaw
            }
        }
    }

    func goBack() {
        if let prevRaw = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.9)) {
                currentStep = prevRaw
            }
        }
    }

    func skipStep() {
        goNext()
    }

    // MARK: - Photo Handling

    func addPhoto(_ image: UIImage, at index: Int) {
        guard index < 6 else { return }
        photoImages[index] = image
    }

    func removePhoto(at index: Int) {
        guard index < 6 else { return }
        photoImages[index] = nil
        let existing = photoImages.compactMap { $0 }
        photoImages = existing + Array(repeating: nil, count: 6 - existing.count)
    }

    @MainActor
    func loadPhoto(from item: PhotosPickerItem, at index: Int) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        imageForCropping = image
        cropTargetIndex = index
    }

    // MARK: - Interests

    func toggleInterest(_ interest: String) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest) 
        } else if selectedInterests.count < 10 {
            selectedInterests.insert(interest)
        }
    }

    // MARK: - Prompts

    func addPrompt() {
        let trimmed = currentPromptAnswer.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let prompt = ProfilePrompt(question: selectedPromptQuestion, answer: trimmed)
        prompts.append(prompt)
        currentPromptAnswer = ""
        let usedQuestions = Set(prompts.map(\.question))
        if let next = ProfilePrompt.availableQuestions.first(where: { !usedQuestions.contains($0) }) {
            selectedPromptQuestion = next
        }
    }

    func removePrompt(at index: Int) {
        guard index < prompts.count else { return }
        prompts.remove(at: index)
    }

    var availablePromptQuestions: [String] {
        let usedQuestions = Set(prompts.map(\.question))
        return ProfilePrompt.availableQuestions.filter { !usedQuestions.contains($0) }
    }

    var canAddMorePrompts: Bool {
        prompts.count < 3 && !availablePromptQuestions.isEmpty
    }

    // MARK: - Complete Onboarding

    func completeOnboarding() {
        isCompleting = true

        Task {
            var photoFileNames: [String] = []
            for (index, image) in photoImages.enumerated() {
                guard let image = image else { continue }
                if let fileName = storage.savePhoto(image, index: index) {
                    photoFileNames.append(fileName)
                }
            }

            do {
                guard let userId = AuthService.shared.currentUser?.id,
                      let bd = birthDate else {
                    await MainActor.run { isCompleting = false }
                    return
                }

                let finalPhone = phoneNumber.trimmingCharacters(in: .whitespaces)
                let finalLookingFor = lookingFor?.rawValue

                let user = User(
                    id: userId,
                    displayName: firstName.trimmingCharacters(in: .whitespaces),
                    birthDate: bd,
                    phoneNumber: finalPhone.isEmpty ? nil : finalPhone,
                    lookingFor: finalLookingFor,
                    bio: bio.isEmpty ? nil : bio,
                    lifestyle: lifestyle,
                    aboutYou: aboutYou,
                    photoUrls: photoFileNames,
                    gender: selectedGender,
                    interests: Array(selectedInterests),
                    prompts: prompts.isEmpty ? nil : prompts,
                    privacyMode: privacyMode
                )

                try await DatabaseService.shared.createProfile(user)

                await MainActor.run {
                    storage.saveProfile(user)
                    storage.markOnboardingComplete()
                    isCompleting = false
                }
            } catch {
                print("Profil oluşturulurken hata: \(error)")
                await MainActor.run {
                    isCompleting = false
                }
            }
        }
    }
}
