import SwiftUI
import PhotosUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - OnboardingStep

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case nameAge = 1
    case photos = 2
    case bioPrompts = 3
    case interests = 4
    case privacyMode = 5

    var title: String {
        switch self {
        case .welcome:     return "Hoş Geldin!"
        case .nameAge:     return "Kendini Tanıt"
        case .photos:      return "Fotoğrafların"
        case .bioPrompts:  return "Hakkında"
        case .interests:   return "İlgi Alanların"
        case .privacyMode: return "Gizlilik Modu"
        }
    }

    var subtitle: String {
        switch self {
        case .welcome:     return "Turnike ile metro yolculuğun değişsin"
        case .nameAge:     return "Temel bilgilerini gir"
        case .photos:      return "En az 1 fotoğraf ekle"
        case .bioPrompts:  return "Kendinden biraz bahset"
        case .interests:   return "En az 3 ilgi alanı seç"
        case .privacyMode: return "Bildirim tercihini belirle"
        }
    }
}

// MARK: - ProfileOnboardingViewModel

@Observable
final class ProfileOnboardingViewModel {

    // MARK: - State

    var currentStep: OnboardingStep = .welcome

    // Step 2: Name / Age / Gender
    var displayName: String = ""
    var birthDate: Date = Calendar.current.date(byAdding: .year, value: -22, to: .now) ?? .now
    var selectedGender: Gender = .preferNotToSay

    // Step 3: Photos
    var selectedPhotos: [PhotosPickerItem] = []
    var photoImages: [UIImage?] = Array(repeating: nil, count: 6)

    // Step 4: Bio & Prompts
    var bio: String = ""
    var prompts: [ProfilePrompt] = []
    var selectedPromptQuestion: String = ProfilePrompt.availableQuestions[0]
    var currentPromptAnswer: String = ""

    // Step 5: Interests
    var selectedInterests: Set<PredefinedInterest> = []

    // Step 6: Privacy Mode
    var privacyMode: PrivacyMode = .instant

    // General
    var isCompleting: Bool = false

    private let storage = ProfileStorageService.shared

    // MARK: - Computed Age

    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: .now).year ?? 0
    }

    var ageString: String {
        "\(age)"
    }

    // MARK: - Validation

    var canProceed: Bool {
        switch currentStep {
        case .welcome:
            return true
        case .nameAge:
            return !displayName.trimmingCharacters(in: .whitespaces).isEmpty && age >= 18 && age <= 99
        case .photos:
            return photoImages.compactMap({ $0 }).count >= 1
        case .bioPrompts:
            return true // Opsiyonel
        case .interests:
            return selectedInterests.count >= 3
        case .privacyMode:
            return true
        }
    }

    var photoCount: Int {
        photoImages.compactMap({ $0 }).count
    }

    // MARK: - Navigation

    func goNext() {
        guard canProceed else { return }
        if let nextRaw = OnboardingStep(rawValue: currentStep.rawValue + 1) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                currentStep = nextRaw
            }
        }
    }

    func goBack() {
        if let prevRaw = OnboardingStep(rawValue: currentStep.rawValue - 1) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                currentStep = prevRaw
            }
        }
    }

    // MARK: - Photo Handling

    func addPhoto(_ image: UIImage, at index: Int) {
        guard index < 6 else { return }
        photoImages[index] = image
    }

    func removePhoto(at index: Int) {
        guard index < 6 else { return }
        photoImages[index] = nil
        // Compact: boşlukları kaldır
        let existing = photoImages.compactMap { $0 }
        photoImages = existing + Array(repeating: nil, count: 6 - existing.count)
    }

    @MainActor
    func loadPhoto(from item: PhotosPickerItem, at index: Int) async {
        guard let data = try? await item.loadTransferable(type: Data.self),
              let image = UIImage(data: data) else { return }
        addPhoto(image, at: index)
    }

    // MARK: - Prompts

    func addPrompt() {
        let trimmed = currentPromptAnswer.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let prompt = ProfilePrompt(question: selectedPromptQuestion, answer: trimmed)
        prompts.append(prompt)
        currentPromptAnswer = ""
        // Sonraki kullanılmamış soruya geç
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

    // MARK: - Interests

    func toggleInterest(_ interest: PredefinedInterest) {
        if selectedInterests.contains(interest) {
            selectedInterests.remove(interest)
        } else if selectedInterests.count < 8 {
            selectedInterests.insert(interest)
        }
    }

    // MARK: - Complete Onboarding

    func completeOnboarding() {
        isCompleting = true

        // Fotoğrafları kaydet
        var photoFileNames: [String] = []
        for (index, image) in photoImages.enumerated() {
            guard let image = image else { continue }
            if let fileName = storage.savePhoto(image, index: index) {
                photoFileNames.append(fileName)
            }
        }

        // User oluştur
        let user = User(
            displayName: displayName.trimmingCharacters(in: .whitespaces),
            bio: bio.trimmingCharacters(in: .whitespaces),
            age: age,
            photoFileNames: photoFileNames,
            gender: selectedGender,
            interests: selectedInterests.map(\.rawValue),
            prompts: prompts,
            privacyMode: privacyMode
        )

        // Kaydet
        storage.saveProfile(user)
        storage.markOnboardingComplete()

        isCompleting = false
    }
}
