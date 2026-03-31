import SwiftUI

// MARK: - OnboardingBioPromptsView

/// Bio ve prompt yanıtları.
struct OnboardingBioPromptsView: View {

    @Bindable var viewModel: ProfileOnboardingViewModel
    @FocusState private var isBioFocused: Bool
    @FocusState private var isPromptFocused: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - Bio
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("Hakkında", systemImage: "text.quote")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.7))

                        Spacer()

                        Text("\(viewModel.bio.count)/300")
                            .font(.caption)
                            .foregroundStyle(viewModel.bio.count > 300 ? .red : .white.opacity(0.4))
                    }

                    TextEditor(text: $viewModel.bio)
                        .font(.body)
                        .foregroundStyle(.white)
                        .focused($isBioFocused)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 100, maxHeight: 140)
                        .padding(14)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.white.opacity(0.08))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(isBioFocused ? 0.3 : 0.1), lineWidth: 1)
                                }
                        }
                        .onChange(of: viewModel.bio) { _, newValue in
                            if newValue.count > 300 {
                                viewModel.bio = String(newValue.prefix(300))
                            }
                        }


                }
                .padding(.horizontal, 20)

                // Ayırıcı
                Rectangle()
                    .fill(.white.opacity(0.1))
                    .frame(height: 1)
                    .padding(.horizontal, 20)

                // MARK: - Prompts
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Label("Prompt'lar", systemImage: "bubble.left.and.bubble.right.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.7))

                        Spacer()

                        Text("\(viewModel.prompts.count)/3")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }



                    // Mevcut prompt'lar
                    ForEach(Array(viewModel.prompts.enumerated()), id: \.element.id) { index, prompt in
                        promptCard(prompt, at: index)
                    }

                    // Yeni prompt ekleme
                    if viewModel.canAddMorePrompts {
                        addPromptSection
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }

    // MARK: - Prompt Card

    private func promptCard(_ prompt: ProfilePrompt, at index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(prompt.question)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.cyan)

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.removePrompt(at: index)
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.3))
                }
            }

            Text(prompt.answer)
                .font(.body)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(14)
        .glass(cornerRadius: 14, opacity: 0.12)
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Add Prompt Section

    private var addPromptSection: some View {
        VStack(spacing: 12) {
            // Soru seçici
            Menu {
                ForEach(viewModel.availablePromptQuestions, id: \.self) { question in
                    Button(question) {
                        viewModel.selectedPromptQuestion = question
                    }
                }
            } label: {
                HStack {
                    Text(viewModel.selectedPromptQuestion)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.cyan)
                        .lineLimit(1)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.cyan.opacity(0.6))
                }
                .padding(12)
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.cyan.opacity(0.1))
                }
            }

            // Cevap girişi
            HStack(spacing: 8) {
                TextField("Yanıtını yaz...", text: $viewModel.currentPromptAnswer)
                    .font(.body)
                    .foregroundStyle(.white)
                    .focused($isPromptFocused)
                    .padding(12)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.white.opacity(0.08))
                    }

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        viewModel.addPrompt()
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(viewModel.currentPromptAnswer.trimmingCharacters(in: .whitespaces).isEmpty ? .white.opacity(0.2) : .cyan)
                }
                .disabled(viewModel.currentPromptAnswer.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(14)
        .glass(cornerRadius: 14, opacity: 0.08)
    }
}
