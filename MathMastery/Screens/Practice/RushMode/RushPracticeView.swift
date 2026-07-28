import SwiftUI

struct RushPracticeView: View {
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
            title: "Rush Mode",
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

                    ZStack(alignment: .topTrailing) {
                        timerBadge

                        if let text = viewModel.timeChangeText {
                            Text(text)
                                .font(.system(size: 18, weight: .black, design: .rounded))
                                .foregroundColor(
                                    viewModel.timeChangeIsPositive
                                    ? .green
                                    : .red
                                )
                                .offset(y: -35)
                                .transition(
                                    .scale(scale: 0.2)
                                    .combined(with: .opacity)
                                )
                        }
                    }
                }

                questionCard
                answerGrid
            }
        }
        .overlay {
            if let value = viewModel.countdownValue {
                CountdownOverlay(
                    text: value
                )
            }
        }
        .overlay {
            if viewModel.showGameOver {
                GameOverOverlay(
                    title: "Time's Up!",
                    subtitle: "Nice run!",
                    icon: "Alarm",
                    streak: viewModel.longestStreak,
                    onResult: {
                        completeSession()
                    }
                )
            }
        }
        .animation(
            .spring(response: 0.35, dampingFraction: 0.55),
            value: viewModel.timeChangeText
        )
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stopTimer()
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
                .allowsHitTesting(
                    viewModel.isAcceptingAnswers &&
                    !viewModel.showGameOver
                )
            }
        }
    }

    private var timerBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "timer")
            Text(viewModel.formattedTime)
        }
        .foregroundColor(viewModel.secondsRemaining <= 5 ? .red : AppColor.commonAccentBlue)
        .font(.system(size: 15, weight: .bold, design: .rounded))
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background {
            Capsule()
                .fill(Color.white)
        }
        .overlay {
            Capsule()
                .stroke(
                    viewModel.secondsRemaining <= 5 ? .red : .white,
                    lineWidth: 1.5
                )
        }
    }

    private func completeSession() {
        onComplete(viewModel.makeResult())
    }
}
