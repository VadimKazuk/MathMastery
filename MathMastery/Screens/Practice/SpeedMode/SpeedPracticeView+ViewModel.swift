import Combine
import SwiftUI
import SwiftData

extension SpeedPracticeView {
    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer

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

        @Published private(set) var mistakes: [PracticeMistake] = []

        private static let sessionDuration = 17
        private static let questionRange = 2...9

        private var questionStartTime = Date()
        private var responseTimes: [TimeInterval] = []
        private var averageResponseTime: Double = 0.0

        private var timerCancellable: AnyCancellable?
        private var countdownCancellable: AnyCancellable?
        private var blinkCancellable: AnyCancellable?

        private let swiftDB: SwiftDataService

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
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

        var averageResponseTimeValue: Double {
            guard !responseTimes.isEmpty else { return 0 }
            return responseTimes.reduce(0, +) / Double(responseTimes.count)
        }

        var averageResponseTimeText: String {
            String(format: "%.1fs", averageResponseTimeValue)
        }

        var badgeBackgroundColor: Color {
            guard isWarningPhase else { return .white }

            return blinkToggle
                ? .red
                : .red.opacity(0.4)
        }

        func finish() {
            guard !didComplete else { return }
            didComplete = true

            countdownCancellable?.cancel()
            countdownCancellable = nil
            countdownValue = nil

            guard !isFinished else { return }

            isAcceptingAnswers = false
            isFinished = true
            stopTimer()
        }

        private func resetSession() {
            stopTimer()

            secondsRemaining = Self.sessionDuration
            solvedCount = 0
            correctCount = 0
            bestStreak = 0
            currentStreak = 0
            questionIndex = 0
            isFinished = false
            isAcceptingAnswers = false

            mistakes = []

            currentQuestion = Self.makeRandomQuestion()
            updateAnswerOptions()
        }

        private func startBlinking() {
            guard blinkCancellable == nil else { return }

            blinkCancellable = Timer
                .publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    guard let self else { return }
                    self.blinkToggle.toggle()
                }
        }

        private func stopBlinking() {
            blinkCancellable?.cancel()
            blinkCancellable = nil
        }

        private func startTimer() {
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

            timerCancellable?.cancel()
            timerCancellable = nil
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

            let isCorrect = answer == currentQuestion.answer

            if let index = answerOptions.firstIndex(where: { $0.value == currentQuestion.answer }) {
                answerOptions[index].state = .correct
            }

            if !isCorrect,
               let index = answerOptions.firstIndex(where: { $0.value == answer }) {
                answerOptions[index].state = .wrong
            }

            if !isCorrect {
                mistakes.append(
                    PracticeMistake(
                        left: currentQuestion.left,
                        right: currentQuestion.right,
                        correctAnswer: currentQuestion.answer,
                        userAnswer: answer,
                        mode: .speed
                    )
                )
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

            questionStartTime = Date()

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

        private func tick() {
            guard !isFinished else { return }

            secondsRemaining = max(secondsRemaining - 1, 0)

            if secondsRemaining <= 10 {
                if blinkCancellable == nil {
                    blinkToggle = false
                    startBlinking()
                }
            }

            if secondsRemaining > 10 {
                stopBlinking()
            }

            if secondsRemaining == 0 {
                finish()
            }
        }

        private func updateAnswerOptions() {
            let answer = currentQuestion.answer

            var distractors: Set<Int> = []

            func add(_ value: Int) {
                guard value > 0, value != answer else { return }
                distractors.insert(value)
            }

            let left = currentQuestion.left
            let right = currentQuestion.right

            for offset in 1...3 {
                add(answer + offset)
                add(answer - offset)
            }

            add((left + 1) * right)
            add((left - 1) * right)
            add(left * (right + 1))
            add(left * (right - 1))

            add(answer + left)
            add(answer - left)
            add(answer + right)
            add(answer - right)

            while distractors.count < 3 {
                let offset = Int.random(in: 1...10)
                let sign = Bool.random() ? 1 : -1
                add(answer + offset * sign)
            }
            
            var finalOptions = Array(distractors.prefix(3))
            finalOptions.append(answer)

            answerOptions = finalOptions.shuffled()
                .map { AnswerOption(value: $0) }
        }

        private static func makeRandomQuestion() -> PracticeQuestion {
            PracticeQuestion(
                left: questionRange.randomElement() ?? 2,
                right: questionRange.randomElement() ?? 2
            )
        }

        func saveSession() -> PracticeSession {
            let accuracy = solvedCount == 0
                ? 0
                : Int((Double(correctCount) / Double(solvedCount)) * 100)

            let session = PracticeSession(
                mode: .speed,
                duration: Self.sessionDuration,
                accuracy: accuracy,
                correctAnswers: correctCount,
                questionsCount: solvedCount,
                longestStreak: bestStreak,
                averageResponseTime: averageResponseTimeValue,
                mistakes: []
            )

            let mappedMistakes = mistakes.map {
                let m = PracticeMistake(
                    left: $0.left,
                    right: $0.right,
                    correctAnswer: $0.correctAnswer,
                    userAnswer: $0.userAnswer,
                    mode: .speed
                )
                m.session = session
                return m
            }

            session.mistakes = mappedMistakes

            swiftDB.saveSession(session)
            return session
        }

        func makeResult() -> PracticeSession {

            let session = saveSession()

            return session
        }
    }
}


