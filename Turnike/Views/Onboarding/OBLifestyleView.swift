import SwiftUI

// MARK: - OBLifestyleView

struct OBLifestyleView: View {

    @Bindable var viewModel: ProfileOnboardingViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Ya\u{015F}am tarz\u{0131}n,")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                    Text(viewModel.firstName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(.white)
                }
                .padding(.top, 32)

                Text("Al\u{0131}\u{015F}kanl\u{0131}klar\u{0131}n uyu\u{015F}uyor mu? \u{00D6}nce sen ba\u{015F}la.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.top, 6)

                VStack(alignment: .leading, spacing: 28) {
                    ForEach(Array(lifestyleOptions.enumerated()), id: \.offset) { _, category in
                        chipCategory(
                            title: category.category,
                            icon: category.icon,
                            options: category.options,
                            selected: viewModel.lifestyle[keyPath: category.key],
                            onSelect: { viewModel.lifestyle[keyPath: category.key] = $0 }
                        )
                    }
                }
                .padding(.top, 24)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 120)
        }
        .environment(\.locale, Locale(identifier: "tr_TR"))
    }

    // MARK: - Chip Category

    private func chipCategory(title: String, icon: String, options: [String], selected: String, onSelect: @escaping (String) -> Void) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Text(icon)
                    .font(.body)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
            }

            FlowLayout(spacing: 8) {
                ForEach(options, id: \.self) { option in
                    chipButton(option, isSelected: selected == option) {
                        withAnimation(.spring(response: 0.25)) {
                            onSelect(option)
                        }
                    }
                }
            }
        }
    }

    private func chipButton(_ text: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.7))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background {
                    Capsule()
                        .fill(isSelected
                            ? Color(red: 215/255, green: 130/255, blue: 165/255).opacity(0.25)
                            : .white.opacity(0.08))
                        .overlay {
                            Capsule()
                                .stroke(isSelected
                                    ? Color(red: 215/255, green: 130/255, blue: 165/255)
                                    : .white.opacity(0.15),
                                    lineWidth: 1)
                        }
                }
        }
        .buttonStyle(.plain)
    }
}
