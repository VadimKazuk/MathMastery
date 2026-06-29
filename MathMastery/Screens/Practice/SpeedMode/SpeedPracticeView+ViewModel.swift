import Combine
import SwiftUI

extension SpeedPracticeView {
    final class ViewModel: ObservableObject {
        private static let sessionDuration = 60
        private static let questionRange = 2...9
        private static let answerRange = 1...144

        private var questionStartTime = Date()
        private var responseTimes: [TimeInterval] = []

        @Published private(set) var secondsRemaining = sessionDuration
        @Published private(set) var solvedCount = 0
        @Published private(set) var correctCount = 0
        @Published private(set) var bestStreak = 0
        @Published private(set) var currentStreak = 0
        @Published private(set) var questionIndex = 0
        @Published private(set) var currentQuestion = ViewModel.makeRandomQuestion()
        @Published private(set) var answerOptions: [AnswerOption] = []
        @Published private(set) var isFinished = false
        @Published private(set) var isAcceptingAnswers = false

        @Published private(set) var blinkToggle = false

        @Published private(set) var didComplete = false
        @Published private(set) var countdownValue: Int?

        private var timerCancellable: AnyCancellable?
        private var countdownCancellable: AnyCancellable?
        private var blinkCancellable: AnyCancellable?

        init() {
            updateAnswerOptions()
        }

        var isWarningPhase: Bool {
            secondsRemaining <= 10
        }

        var timerColor: Color {
            secondsRemaining <= 15
                ? .red
                : AppColor.commonAccentBlue
        }

        var timerForegroundColor: Color {
            isWarningPhase ? .white : timerColor
        }

        var progress: Double {
            Double(secondsRemaining) / Double(Self.sessionDuration)
        }

        var averageResponseTime: String {
            guard !responseTimes.isEmpty else { return "0.0s" }

            let avg = responseTimes.reduce(0, +) / Double(responseTimes.count)
            return String(format: "%.1fs", avg)
        }

        var badgeBackgroundColor: Color {
            if isWarningPhase {
                return blinkToggle ? .red : .red.opacity(0.6)
            } else {
                return .white
            }
        }

        func resetSession() {
            stopTimer()

            blinkToggle = false

            secondsRemaining = Self.sessionDuration
            solvedCount = 0
            correctCount = 0
            bestStreak = 0
            currentStreak = 0
            questionIndex = 0
            isFinished = false
            isAcceptingAnswers = false
            currentQuestion = Self.makeRandomQuestion()
            updateAnswerOptions()
        }

        func startTimer() {
            guard timerCancellable == nil, !isFinished else { return }

            isAcceptingAnswers = true
            timerCancellable = Timer
                .publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.tick()
                }
        }

        func stopTimer() {
            countdownCancellable?.cancel()
            countdownCancellable = nil

            stopBlinking()

            timerCancellable?.cancel()
            timerCancellable = nil
        }

        func finish() {
            guard !didComplete else { return }
            didComplete = true

            countdownCancellable?.cancel()
            countdownCancellable = nil
            countdownValue = nil

            stopBlinking()

            guard !isFinished else { return }

            isAcceptingAnswers = false
            isFinished = true
            stopTimer()
        }

        func startBlinking() {
            guard blinkCancellable == nil else { return }

            blinkToggle = false

            blinkCancellable = Timer
                .publish(every: 0.5, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.blinkToggle.toggle()
                }
        }

        func stopBlinking() {
            blinkCancellable?.cancel()
            blinkCancellable = nil
            blinkToggle = false
        }

        func beginCountdown() {
            countdownCancellable?.cancel()
            countdownCancellable = nil

            if isFinished {
                didComplete = false
                resetSession()
            }

            guard !isAcceptingAnswers else { return }

            countdownValue = 3

            countdownCancellable = Timer
                .publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self else { return }

                    if let value = countdownValue, value > 1 {
                        countdownValue = value - 1
                    } else {
                        countdownValue = nil
                        countdownCancellable?.cancel()
                        countdownCancellable = nil
                        startTimer()
                    }
                }
        }

        @MainActor
        func selectAnswer(_ answer: Int) {
            guard isAcceptingAnswers, !isFinished else { return }

            let time = Date().timeIntervalSince(questionStartTime)
            responseTimes.append(time)

            isAcceptingAnswers = false

            if let index = answerOptions.firstIndex(where: { $0.value == currentQuestion.answer }) {
                answerOptions[index].state = .correct
            }

            if answer != currentQuestion.answer,
               let index = answerOptions.firstIndex(where: { $0.value == answer }) {
                answerOptions[index].state = .wrong
            }

            Task {
                try? await Task.sleep(for: .milliseconds(400))
                advance(answer)
            }
        }

        private func advance(_ answer: Int) {
            solvedCount += 1

            if answer == currentQuestion.answer {
                correctCount += 1
                currentStreak += 1
                bestStreak = max(bestStreak, currentStreak)
            } else {
                currentStreak = 0
            }

            questionIndex += 1
            currentQuestion = Self.makeRandomQuestion()

            questionStartTime = Date() // 👈 ДОБАВИТЬ СЮДА

            updateAnswerOptions()
            isAcceptingAnswers = true
        }

        func backgroundColor(for option: AnswerOption) -> Color {
            switch option.state {
            case .normal:
                return .white

            case .correct:
                return .green.opacity(0.25)

            case .wrong:
                return .red.opacity(0.25)
            }
        }

        func makeResult() -> PracticeResult {
            let accuracy = solvedCount == 0 ? 0 : Int((Double(correctCount) / Double(solvedCount)) * 100)

            return PracticeResult(
                mode: .speed,
                title: "Speed Results",
                summary: "Fast recall session complete.",
                metrics: [
                    .init(title: "Solved", value: "\(solvedCount)"),
                    .init(title: "Accuracy", value: "\(accuracy)%"),
                    .init(title: "Avg Time", value: averageResponseTime),
                    .init(title: "Best Streak", value: "\(bestStreak)")
                ],
                mistakes: [],
                bossTable: nil
            )
        }

        private func tick() {
            guard !isFinished else { return }

            secondsRemaining = max(secondsRemaining - 1, 0)

            if secondsRemaining == 10 {
                startBlinking()
            }

            if secondsRemaining == 0 {
                finish()
            }
        }

        private func updateAnswerOptions() {
            let answer = currentQuestion.answer

            var options: Set<Int> = [answer]

            while options.count < 4 {
                let offset = Int.random(in: 1...4)
                let candidate = answer + offset

                options.insert(candidate)
            }

            answerOptions = options
                .shuffled()
                .map { AnswerOption(value: $0) }
        }

        private static func makeRandomQuestion() -> PracticeQuestion {
            PracticeQuestion(
                left: questionRange.randomElement() ?? 2,
                right: questionRange.randomElement() ?? 2
            )
        }
    }
}

struct AnswerOption: Identifiable, Hashable {
    let id = UUID()
    let value: Int
    var state: AnswerState = .normal
}

enum AnswerState {
    case normal
    case correct
    case wrong
}

