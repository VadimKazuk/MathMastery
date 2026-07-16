import Combine
import SwiftUI

extension RushPracticeView {

    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService
        private let swiftDB: SwiftDataService

        private let sessionDuration = 30

        private let maxTime = 45
        private let correctTimeBonus = 2
        private let wrongTimePenalty = 5

        @Published private(set) var secondsRemaining = 30
        @Published private(set) var lives = 3
        @Published private(set) var correctCount = 0
        @Published private(set) var solvedCount = 0
        @Published private(set) var currentStreak = 0
        @Published private(set) var longestStreak = 0
        

        @Published private(set) var currentQuestion = PracticeQuestion(left: 2, right: 2)
        @Published private(set) var answerOptions: [AnswerOption] = []
        @Published private(set) var answers: [PracticeAnswer] = []
        @Published private(set) var isFinished = false

        @Published private(set) var countdownValue: Int?

        private var countdownCancellable: AnyCancellable?
        private var timer: AnyCancellable?

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
            self.accountService = serviceContainer.resolve(AccountService.self)
            
            currentQuestion = makeSmartQuestion()
            updateAnswerOptions()
        }

        func start() {
            countdownValue = 3
            countdownCancellable =
            Timer.publish(
                every: 1,
                on: .main,
                in: .common
            )
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }
                if let value = countdownValue,
                   value > 1 {
                    countdownValue = value - 1
                } else {
                    countdownValue = nil
                    countdownCancellable?.cancel()
                    countdownCancellable = nil

                    startTimer()
                }
            }
        }

        private func startTimer() {
            timer =
            Timer.publish(
                every: 1,
                on: .main,
                in: .common
            )
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
        }

        func stopTimer() {
            timer?.cancel()
            timer = nil
        }

        private func tick() {
            guard !isFinished else {
                return
            }

            secondsRemaining -= 1

            if secondsRemaining <= 0 {
                secondsRemaining = 0
                finish()
            }
        }

        @MainActor
        func selectAnswer(_ answer: Int) {
            guard !isFinished else { return }

            let isCorrect = answer == currentQuestion.answer

            if let index = answerOptions.firstIndex(where: { $0.value == currentQuestion.answer }) {
                answerOptions[index].state = .correct
            }

            if !isCorrect,
               let index = answerOptions.firstIndex(where: { $0.value == answer }) {
                answerOptions[index].state = .wrong
            }

            answers.append(
                PracticeAnswer(
                    left: currentQuestion.left,
                    right: currentQuestion.right,
                    correctAnswer: currentQuestion.answer,
                    userAnswer: answer,
                    mode: .rush
                )
            )

            solvedCount += 1

            if isCorrect {
                correctCount += 1
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)

                secondsRemaining = min(
                    secondsRemaining + correctTimeBonus,
                    maxTime
                )
            } else {
                lives -= 1
                currentStreak = 0
                secondsRemaining -= wrongTimePenalty

                if secondsRemaining <= 0 {
                    secondsRemaining = 0
                    finish()
                    return
                }
            }

            if lives <= 0 {
                finish()
                return
            }

            Task {
                try? await Task.sleep(for: .milliseconds(400))

                guard !isFinished else { return }

                currentQuestion = makeSmartQuestion()
                updateAnswerOptions()
            }
        }

        func finish() {
            guard !isFinished else { return }

            isFinished = true
            stopTimer()
        }

        private func makeSmartQuestion() -> PracticeQuestion {
            let history = swiftDB.fetchSessions().flatMap { $0.answers }
            let cell = SmartQuestionGenerator.generateSingleCell(allAnswers: history)
            let swap = Bool.random()

            return PracticeQuestion(
                left: swap ? cell.right : cell.left,
                right: swap ? cell.left : cell.right
            )
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

            var options = Array(distractors.prefix(3))
            options.append(answer)

            answerOptions = options.shuffled().map { AnswerOption(value: $0) }
        }

        func makeResult() -> PracticeSession {
            let session = PracticeSession(
                mode: .rush,
                duration: sessionDuration,
                difficulty: nil,
                correctAnswers: correctCount,
                questionsCount: solvedCount,
                longestStreak: longestStreak,
                averageResponseTime: nil,
                answers: answers
            )

            let xp = XPSystem.xp(for: session)
            accountService.addXP(xp)

            swiftDB.saveSession(session)
            
            return session
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
    }
}
