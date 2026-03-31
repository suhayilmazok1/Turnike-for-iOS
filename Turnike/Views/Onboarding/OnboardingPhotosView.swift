import SwiftUI
import PhotosUI

// MARK: - OnboardingPhotosView

/// 2×3 fotoğraf yükleme grid'i.
struct OnboardingPhotosView: View {

    @Bindable var viewModel: ProfileOnboardingViewModel
    @State private var activePickerIndex: Int?
    @State private var showPicker = false
    @State private var selectedItem: PhotosPickerItem?

    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Bilgi kartı
                HStack(spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.cyan)
                    Text("En az 1 fotoğraf ekle. İlk fotoğrafın profil fotoğrafın olacak.")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(14)
                .glass(cornerRadius: 14, opacity: 0.1)
                .padding(.horizontal, 20)

                // MARK: - Photo Grid
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(0..<6, id: \.self) { index in
                        photoSlot(at: index)
                    }
                }
                .padding(.horizontal, 20)

                // Fotoğraf sayacı
                HStack {
                    Text("\(viewModel.photoCount)/6 fotoğraf")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.5))

                    if viewModel.photoCount >= 1 {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.caption)
                    }
                }
                .padding(.top, 4)
            }
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Photo Slot

    @ViewBuilder
    private func photoSlot(at index: Int) -> some View {
        let isPrimary = index == 0

        ZStack {
            if let image = viewModel.photoImages[index] {
                // Fotoğraf var
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: isPrimary ? 220 : 160)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(alignment: .topTrailing) {
                        // Sil butonu
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                viewModel.removePhoto(at: index)
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                                .shadow(color: .black.opacity(0.5), radius: 4)
                                .padding(8)
                        }
                    }
                    .overlay(alignment: .bottomLeading) {
                        if isPrimary {
                            Text("Ana Fotoğraf")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background {
                                    Capsule()
                                        .fill(.cyan.opacity(0.8))
                                }
                                .padding(8)
                        }
                    }
            } else {
                // Boş slot
                PhotosPicker(selection: Binding(
                    get: { selectedItem },
                    set: { newItem in
                        selectedItem = newItem
                        if let item = newItem {
                            Task {
                                await viewModel.loadPhoto(from: item, at: index)
                                selectedItem = nil
                            }
                        }
                    }
                ), matching: .images) {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.cyan.opacity(0.6))

                        Text(isPrimary ? "Ana Fotoğraf" : "Ekle")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: isPrimary ? 220 : 160)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(0.05))
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .strokeBorder(
                                        style: StrokeStyle(lineWidth: 2, dash: [8, 6])
                                    )
                                    .foregroundStyle(.white.opacity(0.15))
                            }
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
