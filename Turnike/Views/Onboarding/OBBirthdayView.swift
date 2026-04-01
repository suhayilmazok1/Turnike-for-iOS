import SwiftUI

// MARK: - OBBirthdayView

struct OBBirthdayView: View {

    @Bindable var viewModel: ProfileOnboardingViewModel
    @FocusState private var focusedField: BirthdayField?

    enum BirthdayField: Hashable {
        case day, month, year
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Doğum tarihin?")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .padding(.top, 32)

            // Rakam girişi: DD / MM / YYYY
            HStack(spacing: 0) {
                dateField(text: $viewModel.birthDay, placeholder: "GG", limit: 2, field: .day, next: .month)
                slashDivider
                dateField(text: $viewModel.birthMonth, placeholder: "AA", limit: 2, field: .month, next: .year)
                slashDivider
                dateField(text: $viewModel.birthYear, placeholder: "YYYY", limit: 4, field: .year, next: nil)
            }
            .padding(.top, 32)

            Text("Profilinde yaşın görünür, doğum tarihin değil.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .padding(.top, 16)

            if let bd = viewModel.birthDate {
                let age = viewModel.age
                if age < 18 {
                    Text("18 yaşından büyük olmalısın.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.red)
                        .padding(.top, 8)
                } else {
                    Text("\(age) yaşındasın")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.cyan)
                        .padding(.top, 8)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .onAppear { focusedField = .day }
    }

    // MARK: - Date Field

    private func dateField(text: Binding<String>, placeholder: String, limit: Int, field: BirthdayField, next: BirthdayField?) -> some View {
        TextField("", text: text)
            .font(.system(size: 32, weight: .light, design: .monospaced))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .keyboardType(.numberPad)
            .focused($focusedField, equals: field)
            .frame(width: limit == 4 ? 110 : 60)
            .overlay(alignment: .center) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 32, weight: .light, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.2))
                }
            }
            .onChange(of: text.wrappedValue) { _, newValue in
                // Sadece rakam
                let filtered = String(newValue.filter { $0.isNumber }.prefix(limit))
                text.wrappedValue = filtered
                // Otomatik sonraki alana geç
                if filtered.count == limit, let next = next {
                    focusedField = next
                }
            }
    }

    private var slashDivider: some View {
        Text("/")
            .font(.system(size: 28, weight: .ultraLight))
            .foregroundStyle(.white.opacity(0.3))
            .padding(.horizontal, 8)
    }
}
