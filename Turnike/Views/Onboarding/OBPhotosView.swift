import SwiftUI
import PhotosUI

// MARK: - OBPhotosView

struct OBPhotosView: View {

    @Bindable var viewModel: ProfileOnboardingViewModel
    @State private var selectedItem: PhotosPickerItem?
    @State private var targetSlotIndex: Int = 0

    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Fotoğraflarını ekle")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 32)

            // Photo Grid
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<6, id: \.self) { index in
                    photoSlot(at: index)
                }
            }
            .padding(.top, 20)

            Spacer()

            // Hint
            HStack(spacing: 12) {
                Text("\(viewModel.photoCount) / 6")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(.white.opacity(0.1)))

                Text("En az 2 fotoğraf ekle. Yüzünün göründüğü bir fotoğraf öneriyoruz.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 24)
        .onChange(of: selectedItem) { _, newItem in
            guard let item = newItem else { return }
            Task {
                await viewModel.loadPhoto(from: item, at: targetSlotIndex)
                selectedItem = nil
            }
        }
        .sheet(item: Binding(
            get: { viewModel.imageForCropping.map { CropImage(image: $0) } },
            set: { _ in viewModel.imageForCropping = nil }
        )) { cropImage in
            ImageCropView(image: cropImage.image) { croppedImage in
                if let idx = viewModel.cropTargetIndex {
                    viewModel.addPhoto(croppedImage, at: idx)
                }
                viewModel.imageForCropping = nil
                viewModel.cropTargetIndex = nil
            }
        }
    }

    // MARK: - Photo Slot

    @ViewBuilder
    private func photoSlot(at index: Int) -> some View {
        if let image = viewModel.photoImages[index] {
            // Dolu slot
            ZStack(alignment: .bottomTrailing) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(9/16, contentMode: .fill)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.removePhoto(at: index)
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white, .red)
                        .shadow(radius: 4)
                }
                .offset(x: 6, y: 6)
            }
        } else {
            // Boş slot
            PhotosPicker(selection: Binding(
                get: { nil },
                set: { item in
                    if let item = item {
                        targetSlotIndex = index
                        selectedItem = item
                    }
                }
            ), matching: .images) {
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
                    .foregroundStyle(.white.opacity(0.15))
                    .frame(height: 160)
                    .overlay {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(red: 215/255, green: 130/255, blue: 165/255),
                                             Color(red: 110/255, green: 155/255, blue: 200/255)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                    }
            }
        }
    }
}

// MARK: - CropImage Wrapper (for .sheet Identifiable)
struct CropImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

// MARK: - ImageCropView

struct ImageCropView: View {

    let image: UIImage
    var onCrop: (UIImage) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    // Hedef oran: 9:16 (dikey profil kartı - TikTok/Tinder tarzı)
    private let targetAspect: CGFloat = 9.0 / 16.0

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                GeometryReader { geo in
                    let cropWidth = geo.size.width * 0.85
                    let cropHeight = cropWidth / targetAspect

                    ZStack {
                        // Fotoğraf (kaydırılabilir & zoomlanabilir)
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.height)
                            .scaleEffect(scale)
                            .offset(offset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        )
                                    }
                                    .onEnded { _ in
                                        lastOffset = offset
                                    }
                            )
                            .gesture(
                                MagnifyGesture()
                                    .onChanged { value in
                                        scale = max(0.5, lastScale * value.magnification)
                                    }
                                    .onEnded { _ in
                                        lastScale = scale
                                    }
                            )

                        // Karartma maskesi (crop alanı dışı)
                        cropOverlay(geo: geo, cropWidth: cropWidth, cropHeight: cropHeight)

                        // Grid çizgileri
                        cropGrid(cropWidth: cropWidth, cropHeight: cropHeight)
                    }
                }

                // "Tamamını Kullan" butonu alt kısımda
                VStack {
                    Spacer()
                    Button {
                        onCrop(image)
                        dismiss()
                    } label: {
                        Text("Tamam\u{0131}n\u{0131} Kullan")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Capsule().fill(.white.opacity(0.15)))
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("Foto\u{011F}raf\u{0131} Ayarla")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        onCrop(image)
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.cyan)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Crop Overlay

    private func cropOverlay(geo: GeometryProxy, cropWidth: CGFloat, cropHeight: CGFloat) -> some View {
        let centerX = geo.size.width / 2
        let centerY = geo.size.height / 2

        return Color.black.opacity(0.6)
            .mask {
                Rectangle()
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: cropWidth, height: cropHeight)
                            .position(x: centerX, y: centerY)
                            .blendMode(.destinationOut)
                    }
            }
            .allowsHitTesting(false)
    }

    // MARK: - Grid Lines

    private func cropGrid(cropWidth: CGFloat, cropHeight: CGFloat) -> some View {
        ZStack {
            // Dikey çizgiler
            HStack(spacing: cropWidth / 3 - 0.5) {
                ForEach(0..<2, id: \.self) { _ in
                    Rectangle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 0.5)
                }
            }
            .frame(width: cropWidth, height: cropHeight)

            // Yatay çizgiler
            VStack(spacing: cropHeight / 3 - 0.5) {
                ForEach(0..<2, id: \.self) { _ in
                    Rectangle()
                        .fill(.white.opacity(0.3))
                        .frame(height: 0.5)
                }
            }
            .frame(width: cropWidth, height: cropHeight)

            // Çerçeve
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white.opacity(0.5), lineWidth: 1)
                .frame(width: cropWidth, height: cropHeight)
        }
        .allowsHitTesting(false)
    }
}
