import SwiftUI

// MARK: - OBInterestsView

struct OBInterestsView: View {

    @Bindable var viewModel: ProfileOnboardingViewModel
    @State private var expandedCategories: Set<String> = []

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Text("İlgi alanların\nneler?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.top, 32)

                Text("Benzer şeyleri seven insanlarla eşleşmek için en az 3 seç.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 6)

                // Seçim sayacı
                HStack {
                    Spacer()
                    Text("\(viewModel.selectedInterests.count) / 10")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.cyan)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(.cyan.opacity(0.15)))
                }
                .padding(.top, 12)

                VStack(spacing: 20) {
                    ForEach(interestCategories) { category in
                        interestCategorySection(category)
                    }
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 120)
        }
    }

    // MARK: - Category Section

    private func interestCategorySection(_ category: InterestCategory) -> some View {
        let isExpanded = expandedCategories.contains(category.name)
        let visibleItems = isExpanded ? category.items : Array(category.items.prefix(6))

        return VStack(alignment: .leading, spacing: 12) {
            // Category header
            HStack(spacing: 8) {
                Text(category.emoji)
                    .font(.title3)
                Text(category.name)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.white)
            }

            // Chips
            FlowLayout(spacing: 8) {
                ForEach(visibleItems, id: \.self) { item in
                    interestChip(item)
                }
            }

            // Show more / Show less
            if category.items.count > 6 {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        if isExpanded {
                            expandedCategories.remove(category.name)
                        } else {
                            expandedCategories.insert(category.name)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(isExpanded ? "Daha az göster" : "Daha fazla göster")
                            .font(.caption.weight(.medium))
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundStyle(.white.opacity(0.5))
                }
            }

            // Divider
            Rectangle()
                .fill(.white.opacity(0.06))
                .frame(height: 1)
        }
    }

    // MARK: - Chip

    private func interestChip(_ text: String) -> some View {
        let isSelected = viewModel.selectedInterests.contains(text)
        return Button {
            withAnimation(.spring(response: 0.25)) {
                viewModel.toggleInterest(text)
            }
        } label: {
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(isSelected
                            ? LinearGradient(
                                colors: [Color(red: 215/255, green: 130/255, blue: 165/255).opacity(0.3),
                                         Color(red: 110/255, green: 155/255, blue: 200/255).opacity(0.3)],
                                startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [.white.opacity(0.08)], startPoint: .leading, endPoint: .trailing))
                        .overlay {
                            Capsule()
                                .stroke(isSelected
                                    ? LinearGradient(
                                        colors: [Color(red: 215/255, green: 130/255, blue: 165/255),
                                                 Color(red: 110/255, green: 155/255, blue: 200/255)],
                                        startPoint: .leading, endPoint: .trailing)
                                    : LinearGradient(colors: [.white.opacity(0.15)], startPoint: .leading, endPoint: .trailing),
                                    lineWidth: 1)
                        }
                }
        }
        .buttonStyle(.plain)
    }
}
