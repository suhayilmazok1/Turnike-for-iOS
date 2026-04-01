import SwiftUI
import PhotosUI

// MARK: - ProfileView

/// Kullanıcı profil ekranı — onboarding'de girilen bilgileri gösterir ve düzenleme imkânı sunar.
struct ProfileView: View {

    @Environment(\.themeManager) private var theme
    @State private var user: User? = ProfileStorageService.shared.loadProfile()
    @State private var isEditing = false
    @State private var showDeleteAlert = false
    var onProfileDeleted: (() -> Void)?

    // Düzenleme state'leri
    @State private var editName: String = ""
    @State private var editBio: String = ""
    @State private var editBirthDate: Date = .now
    @State private var editGender: Gender = .preferNotToSay
    @State private var editInterests: Set<PredefinedInterest> = []
    @State private var editPrivacyMode: PrivacyMode = .instant

    // Fotoğraf düzenleme
    @State private var editPhotoImages: [UIImage?] = Array(repeating: nil, count: 6)
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var editingPhotoIndex: Int?

    @State private var isDeleting = false
    private let storage = ProfileStorageService.shared
    private let authService = AuthService.shared

    var body: some View {
        ZStack {
            AnimatedMetroBackground(line: theme.activeLine)
                .ignoresSafeArea()

            if let user = user {
                ScrollView {
                    VStack(spacing: 20) {
                        profileHeader(user)
                        photosSection(user)
                        bioSection(user)
                        promptsSection(user)
                        interestsSection(user)
                        privacySection(user)
                        dangerZone
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
            }
        }
        .onAppear { loadUserData() }
        .alert("Profili Sil", isPresented: $showDeleteAlert) {
            Button("Sil", role: .destructive) { 
                Task { await deleteProfile() }
            }
            Button("Vazgeç", role: .cancel) {}
        } message: {
            Text("Profilin ve tüm verilerin veritabanından KALICI olarak silinecek. Bu işlem geri alınamaz.")
        }
        .overlay {
            if isDeleting {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    ProgressView("Hesap siliniyor...")
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .environment(\.locale, Locale(identifier: "tr_TR"))
    }

    // MARK: - Header

    private func profileHeader(_ user: User) -> some View {
        VStack(spacing: 12) {
            // Profil fotoğrafı
            ZStack {
                if let firstName = user.primaryPhotoFileName,
                   let image = storage.loadPhoto(named: firstName) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(theme.primaryColor.opacity(0.3))
                        .frame(width: 100, height: 100)
                        .overlay {
                            Text(initials(from: user.displayName))
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                }
            }

            Text(user.displayName)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            HStack(spacing: 12) {
                Label("\(user.age)", systemImage: "calendar")
                Label(user.gender.displayName, systemImage: "person.fill")
            }
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.6))

            // Düzenle butonu
            Button {
                startEditing()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                    Text("Profili Düzenle")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.cyan)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .glass(color: .cyan, cornerRadius: 20, opacity: 0.15)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 16)
        .sheet(isPresented: $isEditing) {
            editProfileSheet
        }
    }

    // MARK: - Photos Section

    private func photosSection(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Fotoğraflar", icon: "photo.fill")

            let columns = [GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8), GridItem(.flexible(), spacing: 8)]
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(0..<min(user.photoUrls?.count ?? 0, 6), id: \.self) { index in
                    let fileName = user.photoUrls![index]
                    if let image = storage.loadPhoto(named: fileName) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 110)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding(16)
        .glass(color: theme.primaryColor, cornerRadius: 16, opacity: 0.08)
    }

    // MARK: - Bio Section

    private func bioSection(_ user: User) -> some View {
        Group {
            if let bio = user.bio, !bio.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    sectionHeader("Hakkında", icon: "text.quote")

                    Text(bio)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.85))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(16)
                .glass(color: theme.primaryColor, cornerRadius: 16, opacity: 0.08)
            }
        }
    }

    // MARK: - Prompts Section

    private func promptsSection(_ user: User) -> some View {
        Group {
            if let prompts = user.prompts, !prompts.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    sectionHeader("Prompt'lar", icon: "bubble.left.and.bubble.right.fill")

                    ForEach(prompts) { prompt in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(prompt.question)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.cyan)
                            Text(prompt.answer)
                                .font(.body)
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.white.opacity(0.05))
                        }
                    }
                }
                .padding(16)
                .glass(color: theme.primaryColor, cornerRadius: 16, opacity: 0.08)
            }
        }
    }

    // MARK: - Interests Section

    private func interestsSection(_ user: User) -> some View {
        Group {
            if let interests = user.interests, !interests.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    sectionHeader("İlgi Alanları", icon: "sparkles")

                    FlowLayout(spacing: 8) {
                        ForEach(interests, id: \.self) { interest in
                            let predefined = PredefinedInterest.allCases.first { $0.rawValue == interest }
                            HStack(spacing: 4) {
                                if let p = predefined {
                                    Text(p.icon)
                                }
                                Text(interest)
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background {
                                Capsule()
                                    .fill(theme.primaryColor.opacity(0.2))
                            }
                        }
                    }
                }
                .padding(16)
                .glass(color: theme.primaryColor, cornerRadius: 16, opacity: 0.08)
            }
        }
    }

    // MARK: - Privacy Section

    private func privacySection(_ user: User) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Gizlilik Modu", icon: "shield.checkered")

            HStack(spacing: 12) {
                Image(systemName: user.privacyMode == .instant ? "bolt.fill" : "moon.fill")
                    .font(.title3)
                    .foregroundStyle(user.privacyMode == .instant ? .yellow : .purple)

                VStack(alignment: .leading, spacing: 2) {
                    Text(user.privacyMode.displayName)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(user.privacyMode == .instant ? "Bildirimler an\u{0131}nda gelir" : "Bildirimler toplu gelir")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Spacer()
            }
        }
        .padding(16)
        .glass(color: theme.primaryColor, cornerRadius: 16, opacity: 0.08)
    }

    // MARK: - Danger Zone

    private var dangerZone: some View {
        Button {
            showDeleteAlert = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "trash.fill")
                Text("Profili Sil")
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.red)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .glass(color: .red, cornerRadius: 16, opacity: 0.1)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Edit Sheet

    private var editProfileSheet: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // İsim
                        editField("İsim", icon: "person.fill") {
                            TextField("İsmin", text: $editName)
                                .font(.body)
                                .foregroundStyle(.white)
                                .autocorrectionDisabled()
                                #if canImport(UIKit)
                                .textInputAutocapitalization(.words)
                                #endif
                        }

                        // Doğum Tarihi
                        editField("Doğum Tarihi", icon: "calendar") {
                            DatePicker(
                                "",
                                selection: $editBirthDate,
                                in: ...Calendar.current.date(byAdding: .year, value: -18, to: .now)!,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.compact)
                            .labelsHidden()
                            .colorScheme(.dark)
                        }

                        // Cinsiyet
                        editField("Cinsiyet", icon: "person.2") {
                            FlowLayout(spacing: 8) {
                                ForEach(Gender.allCases, id: \.self) { gender in
                                    Button {
                                        editGender = gender
                                    } label: {
                                        Text(gender.displayName)
                                            .font(.caption.weight(.semibold))
                                            .foregroundStyle(editGender == gender ? .black : .white)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 8)
                                            .background {
                                                Capsule()
                                                    .fill(editGender == gender ? Color.cyan : Color.white.opacity(0.1))
                                            }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        // Bio
                        editField("Hakkında", icon: "text.quote") {
                            TextEditor(text: $editBio)
                                .font(.body)
                                .foregroundStyle(.white)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 80)
                                .onChange(of: editBio) { _, newValue in
                                    if newValue.count > 300 {
                                        editBio = String(newValue.prefix(300))
                                    }
                                }
                        }

                        // İlgi Alanları
                        editField("İlgi Alanları", icon: "sparkles") {
                            FlowLayout(spacing: 8) {
                                ForEach(PredefinedInterest.allCases, id: \.self) { interest in
                                    let selected = editInterests.contains(interest)
                                    let maxed = editInterests.count >= 8 && !selected
                                    Button {
                                        if selected {
                                            editInterests.remove(interest)
                                        } else if !maxed {
                                            editInterests.insert(interest)
                                        }
                                    } label: {
                                        HStack(spacing: 4) {
                                            Text(interest.icon)
                                                .font(.caption)
                                            Text(interest.rawValue)
                                                .font(.caption.weight(.medium))
                                                .foregroundStyle(selected ? .black : .white)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background {
                                            Capsule()
                                                .fill(selected ? Color.cyan : Color.white.opacity(0.08))
                                        }
                                    }
                                    .buttonStyle(.plain)
                                    .opacity(maxed ? 0.4 : 1)
                                    .disabled(maxed)
                                }
                            }
                        }

                        // Gizlilik
                        editField("Gizlilik Modu", icon: "shield.checkered") {
                            VStack(spacing: 8) {
                                privacyOption("Anlık Mod", icon: "bolt.fill", isSelected: isInstantEdit) {
                                    editPrivacyMode = .instant
                                }
                                privacyOption("Sakin Mod", icon: "moon.fill", isSelected: !isInstantEdit) {
                                    editPrivacyMode = .calm
                                }
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Profili Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Vazgeç") { isEditing = false }
                        .foregroundStyle(.white.opacity(0.7))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") { saveEdits() }
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.cyan)
                        .disabled(editName.trimmingCharacters(in: .whitespaces).isEmpty || editInterests.count < 3)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Edit Helpers

    private func editField<Content: View>(_ title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white.opacity(0.6))

            content()
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.white.opacity(0.06))
                }
        }
    }

    private func privacyOption(_ title: String, icon: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(isSelected ? .cyan : .white.opacity(0.4))
                Text(title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? .cyan : .white.opacity(0.3))
            }
            .padding(10)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.cyan.opacity(0.1) : Color.clear)
            }
        }
        .buttonStyle(.plain)
    }

    private var isInstantEdit: Bool {
        if case .instant = editPrivacyMode { return true }
        return false
    }

    // MARK: - Section Header

    private func sectionHeader(_ title: String, icon: String) -> some View {
        Label(title, systemImage: icon)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white.opacity(0.6))
    }

    // MARK: - Logic

    private func loadUserData() {
        user = storage.loadProfile()
    }

    private func startEditing() {
        guard let user = user else { return }
        editName = user.displayName
        editBio = user.bio ?? ""
        editGender = user.gender
        editPrivacyMode = user.privacyMode
        editInterests = Set(PredefinedInterest.allCases.filter { user.interests?.contains($0.rawValue) == true })

        // birthDate'den doğum tarihi al
        editBirthDate = user.birthDate

        isEditing = true
    }

    private func saveEdits() {
        guard var updated = user else { return }
        updated.displayName = editName.trimmingCharacters(in: .whitespaces)
        updated.bio = editBio.trimmingCharacters(in: .whitespaces)
        updated.gender = editGender
        updated.interests = editInterests.map(\.rawValue)
        updated.privacyMode = editPrivacyMode

        updated.birthDate = editBirthDate

        storage.saveProfile(updated)
        user = updated
        isEditing = false
    }

    private func deleteProfile() async {
        isDeleting = true
        do {
            try await authService.deleteAccount()
            // Yerele kaydettiğimiz önbelleği de temizliyoruz
            storage.clearProfile()
            
            await MainActor.run {
                user = nil
                isDeleting = false
                onProfileDeleted?()
            }
        } catch {
            print("Hesap silinirken hata oldu: \(error)")
            await MainActor.run {
                isDeleting = false
            }
        }
    }

    private func initials(from name: String) -> String {
        let parts = name.split(separator: " ")
        return parts.compactMap { $0.first }.map(String.init).prefix(2).joined()
    }
}
