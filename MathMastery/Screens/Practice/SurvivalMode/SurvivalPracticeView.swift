import SwiftUI

struct SurvivalPracticeView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel: ViewModel
    let onComplete: (PracticeSession) -> Void

    init(viewModel: ViewModel, onComplete: @escaping (PracticeSession) -> Void) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onComplete = onComplete
    }

    var body: some View {
        PracticeModeScreen(
            title: "Survival Mode",
            headerAction: .exitConfirm,

            onBack: {
                dismiss()
            },

            onComplete: {
                onComplete(viewModel.makeResult())
            }
        ) {
            VStack(spacing: 28) {
                HStack {
                    livesBadge
                    Spacer()
                }
                VStack(spacing: 8) {
                    Text("\(viewModel.currentStreak) Streak")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.green)

                    Text("Don't break the streak")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                questionCard
                answerGrid
            }
        }
        .onAppear {
            viewModel.resetSession()
        }
        .onChange(of: viewModel.shouldShowResult) { _, show in
            if show {
                completeSession()
            }
        }
    }

    private var questionCard: some View {
        VStack(spacing: 20) {
            Text(viewModel.currentQuestion.title)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            ProgressView(value: Double(viewModel.lives), total: 3)
                .tint(AppColor.commonAccentBlue)
                .frame(width: 120)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 138)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
        }
    }

    private var answerGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 14),
                GridItem(.flexible(), spacing: 14)
            ],
            spacing: 14
        ) {
            ForEach(viewModel.answerOptions) { option in
                Button {
                    viewModel.selectAnswer(option.value)
                } label: {
                    Text("\(option.value)")
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.commonAccentBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 76)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(viewModel.backgroundColor(for: option))
                                .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                        }.animation(
                            .easeInOut(duration: 0.2),
                            value: option.state
                        )
                }
                .buttonStyle(.plain)
                .allowsHitTesting(viewModel.isAcceptingAnswers)
            }
        }
    }

    private var livesBadge: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < viewModel.lives ? "heart.fill" : "heart")
                    .foregroundColor(index < viewModel.lives ? .red : .gray.opacity(0.5))
            }
        }
        .font(.system(size: 16, weight: .semibold))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background {
            Capsule()
                .fill(Color.white)
        }
    }
}

private extension SurvivalPracticeView {

    func completeSession() {
        viewModel.finish()
        onComplete(viewModel.makeResult())
    }

}
