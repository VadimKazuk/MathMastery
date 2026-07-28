import Combine
import SwiftUI

extension SurvivalPracticeView {
    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService
        private let swiftDB: SwiftDataService

        private let adaptiveQuestionEngine = AdaptiveQuestionEngine()
        private let answerOptionEngine = AnswerOptionEngine()
        private let questionDifficultyEngine = QuestionDifficultyEngine()
        private let factMasteryEngine = FactMasteryEngine()

        private var sessionStartTime: Date?
        private var sessionEndTime: Date?

        private var questionStartTime = Date()

        private var allAnswers: [PracticeAnswer] = []

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

        @Published private(set) var showGameOver = false

        private var didFinish = false

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
            self.accountService = serviceContainer.resolve(AccountService.self)

            allAnswers = swiftDB.fetchSessions().flatMap(\.answers)

            currentQuestion = generateQuestion()
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
            guard !answers.isEmpty else {
                return 0
            }

            return answers.reduce(0) {
                $0 + $1.responseTime
            }
            / Double(answers.count)
        }

        private var fastestResponseTimeValue: Double {
            answers.map(\.responseTime).min() ?? 0
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

            questionStartTime = Date()

            allAnswers = swiftDB.fetchSessions().flatMap(\.answers)
            currentQuestion = generateQuestion()
            updateAnswerOptions()
        }

        // MARK: - Finish

        func finish() {
            guard !didFinish else { return }

            didFinish = true

            sessionEndTime = Date()

            isFinished = true
            isAcceptingAnswers = false

            withAnimation(.spring()) {
                showGameOver = true
            }
        }

        // MARK: - Answer

        @MainActor
        func selectAnswer(_ answer: Int) {
            guard isAcceptingAnswers, !isFinished else { return }

            isAcceptingAnswers = false

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

        private func generateQuestion() -> PracticeQuestion {
            adaptiveQuestionEngine.nextPracticeQuestion(
                from: allAnswers + answers
            )
        }

        private func updateAnswerOptions() {
            let mastery = factMasteryEngine.mastery(
                for: currentQuestion,
                answers: allAnswers
            )

            let difficulty = questionDifficultyEngine.difficulty(
                for: mastery
            )

            answerOptions = answerOptionEngine.generate(
                for: currentQuestion,
                difficulty: difficulty
            )
        }

        @MainActor
        private func advance(isCorrect: Bool, userAnswer: Int) {
            let currentAnswer = PracticeAnswer(
                left: currentQuestion.left,
                right: currentQuestion.right,
                correctAnswer: currentQuestion.answer,
                userAnswer: userAnswer,
                mode: .survival,
                responseTime: Date().timeIntervalSince(questionStartTime)
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
                finish()
            } else {
                currentQuestion = generateQuestion()
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

            allAnswers.append(contentsOf: answers)

            return session
        }

        // MARK: - Result

        func makeResult() -> PracticeSession {
            let session = saveSession()
            return session
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
