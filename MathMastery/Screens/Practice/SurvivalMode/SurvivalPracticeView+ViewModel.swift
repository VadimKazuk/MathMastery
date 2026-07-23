import Combine
import SwiftUI

extension SurvivalPracticeView {
    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService
        private let swiftDB: SwiftDataService

        private var sessionStartTime: Date?
        private var sessionEndTime: Date?

        private var responseTimes: [TimeInterval] = []
        private var questionStartTime = Date()

        @Published private(set) var lives = 3
        @Published private(set) var correctCount = 0
        @Published private(set) var survivedCount = 0

        @Published private(set) var currentStreak = 0
        @Published private(set) var longestStreak = 0

        @Published private(set) var selectedAnswer: Int?
        @Published private(set) var answerResult: AnswerResult?

        @Published private(set) var currentQuestion = PracticeQuestion(left: 2, right: 2)
        @Published private(set) var answerOptions: [AnswerOption] = []
        @Published private(set) var answers: [PracticeAnswer] = []

        @Published private(set) var isFinished = false
        @Published private(set) var isAcceptingAnswers = true
        @Published private(set) var shouldShowResult = false

        private var didFinish = false

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
            self.accountService = serviceContainer.resolve(AccountService.self)

            currentQuestion = makeSmartQuestion()
            updateAnswerOptions()
        }

        var questionExpression: String {
            "\(currentQuestion.left) × \(currentQuestion.right) = "
        }

        var selectedAnswerText: String {
            selectedAnswer.map(String.init) ?? "?"
        }

        var questionText: String {
            guard let selectedAnswer else {
                return "\(currentQuestion.left) × \(currentQuestion.right) = ?"
            }

            return "\(currentQuestion.left) × \(currentQuestion.right) = \(selectedAnswer)"
        }

        var answerTextColor: Color {
            switch answerResult {
            case .correct:
                return .green

            case .wrong:
                return .red

            case .none:
                return AppColor.commonAccentBlue
            }
        }

        private var sessionDuration: Int {
            guard
                let start = sessionStartTime,
                let end = sessionEndTime
            else {
                return 0
            }

            return Int(end.timeIntervalSince(start))
        }

        private var averageResponseTimeValue: Double {
            guard !responseTimes.isEmpty else {
                return 0
            }

            return responseTimes.reduce(0,+)
            / Double(responseTimes.count)
        }

        private var fastestResponseTimeValue: Double {
            responseTimes.min() ?? 0
        }

        private var answersPerMinuteValue: Double {
            guard sessionDuration > 0 else {
                return 0
            }

            return Double(survivedCount)
            / Double(sessionDuration)
            * 60
        }

        // MARK: - Reset

        func resetSession() {
            lives = 3
            correctCount = 0
            survivedCount = 0
            currentStreak = 0
            longestStreak = 0
            answers.removeAll()
            isFinished = false
            isAcceptingAnswers = true
            didFinish = false

            sessionStartTime = Date()
            sessionEndTime = nil
            responseTimes.removeAll()

            questionStartTime = Date()

            currentQuestion = makeSmartQuestion()
            updateAnswerOptions()
        }

        // MARK: - Finish

        func finish(showResult: Bool = false) {
            guard !didFinish else { return }

            didFinish = true

            sessionEndTime = Date()

            isFinished = true
            isAcceptingAnswers = false

            if showResult {
                shouldShowResult = true
            }
        }

        // MARK: - Answer

        @MainActor
        func selectAnswer(_ answer: Int) {
            guard isAcceptingAnswers, !isFinished else { return }

            isAcceptingAnswers = false

            let responseTime = Date()
                .timeIntervalSince(questionStartTime)

            responseTimes.append(responseTime)

            survivedCount += 1

            selectedAnswer = answer

            let isCorrect = answer == currentQuestion.answer

            answerResult = isCorrect
                ? .correct
                : .wrong

            if let correctIndex = answerOptions.firstIndex(where: { $0.value == currentQuestion.answer }) {
                answerOptions[correctIndex].state = .correct
            }

            if !isCorrect,
               let wrongIndex = answerOptions.firstIndex(where: { $0.value == answer }) {
                answerOptions[wrongIndex].state = .wrong
            }

            Task {
                try? await Task.sleep(for: .milliseconds(500))
                advance(isCorrect: isCorrect, userAnswer: answer)
            }
        }

        // MARK: - Smart Question Generator Integration

        private func makeSmartQuestion() -> PracticeQuestion {
            let allAnswers = swiftDB.fetchSessions().flatMap { $0.answers }

            let selectedCell = SmartQuestionGenerator.generateSingleCell(allAnswers: allAnswers)

            let shouldSwap = Bool.random()
            return PracticeQuestion(
                left: shouldSwap ? selectedCell.right : selectedCell.left,
                right: shouldSwap ? selectedCell.left : selectedCell.right
            )
        }

        @MainActor
        private func advance(isCorrect: Bool, userAnswer: Int) {
            let currentAnswer = PracticeAnswer(
                left: currentQuestion.left,
                right: currentQuestion.right,
                correctAnswer: currentQuestion.answer,
                userAnswer: userAnswer,
                mode: .survival
            )
            answers.append(currentAnswer)

            if isCorrect {
                correctCount += 1
                currentStreak += 1
                if currentStreak > longestStreak {
                    longestStreak = currentStreak
                }
            } else {
                lives -= 1
                currentStreak = 0
            }

            if lives <= 0 {
                finish(showResult: true)
            } else {
                currentQuestion = makeSmartQuestion()
                questionStartTime = Date()
                updateAnswerOptions()
                isAcceptingAnswers = true
            }

            selectedAnswer = nil
            answerResult = nil
        }

        // MARK: - SwiftData
        private func saveSession() -> PracticeSession {
            let session = PracticeSession(
                mode: .survival,
                duration: sessionDuration,
                difficulty: nil,
                correctAnswers: correctCount,
                questionsCount: survivedCount,
                longestStreak: longestStreak,
                averageResponseTime: averageResponseTimeValue,
                fastestResponseTime: fastestResponseTimeValue,
                answersPerMinute: answersPerMinuteValue,
                answers: answers
            )

            let xp = XPSystem.xp(for: session)
            accountService.addXP(xp)

            swiftDB.saveSession(session)
            
            return session
        }

        // MARK: - Result

        func makeResult() -> PracticeSession {
            let session = saveSession()
            return session
        }

        // MARK: - Helpers

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

        func backgroundColor(for option: AnswerOption) -> Color {
            switch option.state {
            case .normal: return .white
            case .correct: return .green
            case .wrong: return .red
            }
        }
    }
}
