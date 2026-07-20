import SwiftUI

struct SpeedPracticeView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel: ViewModel
    @EnvironmentObject var serviceContainer: ServiceContainer

    let onComplete: (PracticeSession) -> Void

    init(viewModel: ViewModel, onComplete: @escaping (PracticeSession) -> Void) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onComplete = onComplete
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
                dismiss()
            },

            onComplete: completeSession
        ) {
            VStack(spacing: 28) {
                HStack {
                    Spacer()
                    timerBadge
                }
                VStack(spacing: 4) {
                    Text("QUESTIONS")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(1.4)
                        .foregroundColor(.secondary)
                    Text("\(viewModel.solvedCount)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.commonAccentBlue)
                    Text("Race against time")
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
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
            Text(viewModel.currentQuestion.title)
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(.primary)

            ProgressView(value: viewModel.progress)
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
}

private extension SpeedPracticeView {

    func completeSession() {
        onComplete(viewModel.makeResult())
    }

}
