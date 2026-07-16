import SwiftUI

struct RushPracticeView: View {
    @StateObject var viewModel: ViewModel
    let onComplete: (PracticeSession) -> Void

    init(viewModel: ViewModel, onComplete: @escaping (PracticeSession) -> Void) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onComplete = onComplete
    }

    var body: some View {
        PracticeModeScreen(
            title: "Rush Mode",
            trailing: timerBadge,
            onComplete: completeSession
        ) {
            VStack(spacing: 28) {
                HStack {
                    livesBadge
                    Spacer()

                    VStack(spacing: 2) {
                        Text("\(viewModel.currentStreak)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.green)

                        Text("STREAK")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 30)

                questionCard
                answerGrid
            }
        }
        .overlay {
            countdownOverlay
        }
        .onAppear {
            viewModel.start()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
        .onChange(of: viewModel.isFinished) { _, finished in
            if finished {
                completeSession()
            }
        }
    }

    private var questionCard: some View {
        VStack(spacing: 20) {
            Text(viewModel.currentQuestion.title)
                .font(.system(size: 36, weight: .bold, design: .rounded))

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
                        }
                        .animation(
                            .easeInOut(duration: 0.2),
                            value: option.state
                        )
                }
                .buttonStyle(.plain)
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
        .font(.system(size: 16))
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background {
            Capsule()
                .fill(Color.white)
        }
    }

    private var timerBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "timer")
            Text("0:\(String(format: "%02d", viewModel.secondsRemaining))")
        }
        .foregroundColor(viewModel.secondsRemaining <= 10 ? .red : AppColor.commonAccentBlue)
        .font(.system(size: 15, weight: .bold, design: .rounded))
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background {
            Capsule()
                .fill(Color.white)
        }
    }

    @ViewBuilder
    private var countdownOverlay: some View {
        if let countdownValue = viewModel.countdownValue {
            ZStack {
                Color.black.opacity(0.32)
                    .ignoresSafeArea()

                VStack(spacing: 10) {
                    Text("Get ready")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)

                    Text("\(countdownValue)")
                        .font(.system(size: 64, weight: .heavy, design: .rounded))
                        .foregroundColor(AppColor.commonAccentBlue)
                        .monospacedDigit()
                }
                .frame(width: 180, height: 150)
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.94))
                        .shadow(color: Color.black.opacity(0.14), radius: 18, x: 0, y: 10)
                }
            }
        }
    }

    private func completeSession() {
        viewModel.finish()
        onComplete(viewModel.makeResult())
    }
}
