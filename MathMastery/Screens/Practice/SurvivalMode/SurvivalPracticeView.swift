import SwiftUI

struct SurvivalPracticeView: View {

    @StateObject var viewModel: ViewModel
    let onComplete: (PracticeSession) -> Void
    let onExit: () -> Void

    init(
        viewModel: ViewModel,
        onComplete: @escaping (PracticeSession) -> Void,
        onExit: @escaping () -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onComplete = onComplete
        self.onExit = onExit
    }

    var body: some View {
        PracticeModeScreen(
            title: "Survival Mode",
            headerAction: .exitConfirm,

            onBack: {
                onExit()
            }
        ) {
            VStack(spacing: 28) {

                HStack {
                    VStack(spacing: 2) {
                        Text("\(viewModel.currentStreak)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.green)

                        Text("STREAK")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    VStack(spacing: 2) {
                        Text("\(viewModel.survivedCount)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(AppColor.commonAccentBlue)

                        Text("QUESTION")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)

                HStack {
                    livesBadge
                    Spacer()
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
            HStack(spacing: 2) {
                Text(viewModel.questionExpression)

                ZStack {
                    Text("00")
                        .hidden()
                        .overlay(alignment: .bottom) {
                            Rectangle()
                                .fill(AppColor.commonAccentBlue.opacity(0.16))
                                .frame(height: 3)
                                .offset(y: 8)
                        }

                    VStack {
//                        ZStack {
//                            if viewModel.answerResult == .wrong {
//                                Text("\(viewModel.currentQuestion.answer)")
//                                    .font(.system(size: 18, weight: .bold, design: .rounded))
//                                    .foregroundStyle(.green)
//                                    .padding(.bottom, 45)
//                            }

                            Text(viewModel.selectedAnswerText)
                                .foregroundStyle(viewModel.answerTextColor)
//                        }
                    }
                }
            }
            .font(.system(size: 36, weight: .bold, design: .rounded))

//                        ProgressView(value: viewModel.progress)
            //                .tint(AppColor.commonAccentBlue)
            //                .frame(width: 120)
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
                        .animation(
                            .easeInOut(duration: 0.2),
                            value: option.state
                        )

                }
                .buttonStyle(
                    DepthButtonStyle(
                        backgroundColor: .white,
                        borderColor: viewModel.backgroundColor(for: option),
                        borderOpacity: 0.6,
                        cornerRadius: 14,
                        depth: 5,
                        borderWidth: 3
                    )
                )
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
