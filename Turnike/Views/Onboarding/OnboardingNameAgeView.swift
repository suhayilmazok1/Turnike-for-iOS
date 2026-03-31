import SwiftUI

// MARK: - OnboardingNameAgeView

/// İsim, doğum tarihi ve cinsiyet girişi.
struct OnboardingNameAgeView: View {

    @Bindable var viewModel: ProfileOnboardingViewModel
    @FocusState private var isNameFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - İsim
                VStack(alignment: .leading, spacing: 10) {
                    Label("İsmin", systemImage: "person.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))

                    TextField("İsmini gir", text: $viewModel.displayName)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .focused($isNameFocused)
                        .autocorrectionDisabled()
                        #if canImport(UIKit)
                        .textInputAutocapitalization(.words)
                        #endif
                        .padding(16)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.08))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(isNameFocused ? 0.3 : 0.1), lineWidth: 1)
                                }
                        }
                }
                .padding(.horizontal, 20)

                // MARK: - Doğum Tarihi
                VStack(alignment: .leading, spacing: 10) {
                    Label("Doğum Tarihin", systemImage: "calendar")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))

                    VStack(spacing: 8) {
                        DatePicker(
                            "Doğum Tarihi",
                            selection: $viewModel.birthDate,
                            in: ...Calendar.current.date(byAdding: .year, value: -18, to: .now)!,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .colorScheme(.dark)
                        .frame(height: 150)
                        .clipped()

                        // Yaş göstergesi
                        HStack(spacing: 6) {
                            Text("Yaşın:")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.5))
                            Text("\(viewModel.age)")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(.cyan)

                            Spacer()

                            HStack(spacing: 4) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.caption2)
                                Text("18+")
                                    .font(.caption.weight(.bold))
                            }
                            .foregroundStyle(.white.opacity(0.4))
                        }
                    }
                    .padding(16)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.white.opacity(0.08))
                    }
                }
                .padding(.horizontal, 20)

                // MARK: - Cinsiyet
                VStack(alignment: .leading, spacing: 10) {
                    Label("Cinsiyetin", systemImage: "person.2")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.7))

                    // Chip Grid
                    FlowLayout(spacing: 8) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            genderChip(gender)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
        .onAppear {
            isNameFocused = true
        }
    }

    private func genderChip(_ gender: Gender) -> some View {
        let isSelected = viewModel.selectedGender == gender
        return Button {
            withAnimation(.spring(response: 0.3)) {
                viewModel.selectedGender = gender
            }
        } label: {
            Text(gender.displayName)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? .black : .white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background {
                    Capsule()
                        .fill(isSelected ? Color.cyan : Color.white.opacity(0.1))
                }
                .overlay {
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color.white.opacity(0.15), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - FlowLayout

/// Dinamik satır atlamalı düzen — chip'leri otomatik sırayla yerleştirir.
struct FlowLayout: Layout {

    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            guard index < subviews.count else { break }
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var maxX: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            maxX = max(maxX, x)
        }

        return (CGSize(width: maxX, height: y + rowHeight), positions)
    }
}
