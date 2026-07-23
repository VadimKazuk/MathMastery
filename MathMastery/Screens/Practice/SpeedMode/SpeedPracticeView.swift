import SwiftUI

struct SpeedPracticeView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel: ViewModel
    @EnvironmentObject var serviceContainer: ServiceContainer

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
            title: "Speed Mode",
            headerAction: .pause,

            onPause: {
                viewModel.pause()
            },

            onResume: {
                viewModel.resume()
            },

            onRestart: {
                viewModel.restart()
            },

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
                        Text("\(viewModel.solvedCount)")
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
                    Spacer()
                    timerBadge
                }
                
                questionCard
                answerGrid
            }
        }
        .overlay {
            if let value = viewModel.countdownValue {
                CountdownOverlayView(
                    text: value
                )
            }
        }
        .onAppear {
            viewModel.beginCountdown()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
        .onChange(of: viewModel.shouldShowResult) { _, show in
            if show {
                completeSession()
            }
        }
    }

    private var timerBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "timer")
                .foregroundColor(viewModel.timerForegroundColor)

            Text("0:\(String(format: "%02d", viewModel.secondsRemaining))")
                .foregroundColor(viewModel.timerForegroundColor)
        }
        .font(.system(size: 15, weight: .semibold, design: .rounded))
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background {
            Capsule()
                .fill(viewModel.badgeBackgroundColor)
                .animation(.easeInOut(duration: 1), value: viewModel.blinkToggle)
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
}

private extension SpeedPracticeView {

    func completeSession() {
        onComplete(viewModel.makeResult())
    }

}
