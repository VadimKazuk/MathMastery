import Combine
import SwiftUI

extension FocusPracticeView {
    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService
        private let swiftDB: SwiftDataService

        private let adaptiveQuestionEngine = AdaptiveQuestionEngine()

        let mode: FocusPracticeMode
        let focusTable: Int?

        private var historyAnswers: [PracticeAnswer] = []

        @Published private(set) var questionIndex = 0
        @Published var answerText = ""

        @Published private(set) var isCorrectAnswer = false
        @Published private(set) var showAnswerButton = false
        @Published private(set) var showingCorrectAnswer = false

        private var wrongAttempts = 0
        private var currentUserAnswer: Int?

        private var shouldClearOnNextInput = false

        @Published var shakeTrigger = 0

        @Published private(set) var isWaitingForNext = false
        @Published private(set) var correctCount = 0
        @Published private(set) var completedQuestions = 0
        @Published private(set) var answers: [PracticeAnswer] = []

        private(set) var questions: [PracticeQuestion] = []

        private let questionsAmount = 10

        private var isPaused = false

        private var sessionStartTime: Date?
        private var sessionEndTime: Date?

        private var questionStartTime = Date()
        private var responseTimes: [TimeInterval] = []

        init(
            serviceContainer: ServiceContainer,
            mode: FocusPracticeMode,
            focusTable: Int?
        ) {
            self.serviceContainer = serviceContainer
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
            self.accountService = serviceContainer.resolve(AccountService.self)

            self.mode = mode
            self.focusTable = focusTable

            historyAnswers = swiftDB.fetchSessions().flatMap(\.answers)
            questions = generateQuestions()

            sessionStartTime = Date()
            questionStartTime = Date()
        }

        var currentQuestion: PracticeQuestion {
            questions[questionIndex]
        }

        var answerColor: Color {
            if showingCorrectAnswer || isCorrectAnswer {
                return .green
            }

            if !answerText.isEmpty && wrongAttempts > 0 {
                return .red
            }

            return AppColor.commonAccentBlue
        }

        private var sessionDuration: Int {
            guard let start = sessionStartTime else { return 0 }
            let end = sessionEndTime ?? Date()
            return Int(end.timeIntervalSince(start))
        }

        private var averageResponseTimeValue: Double {
            guard !responseTimes.isEmpty else { return 0 }
            return responseTimes.reduce(0, +) / Double(responseTimes.count)
        }

        private var fastestResponseTimeValue: Double {
            responseTimes.min() ?? 0
        }

        private var answersPerMinuteValue: Double {
            guard sessionDuration > 0 else { return 0 }
            return (Double(completedQuestions) / Double(sessionDuration)) * 60
        }

        var progressText: String {
            "\(questionIndex + 1) of \(questions.count)"
        }

        var progress: Double {
            guard !questions.isEmpty else { return 0 }
            return Double(completedQuestions) / Double(questions.count)
        }

        // MARK: - QUESTIONS

        private func generateQuestions() -> [PracticeQuestion] {

            let facts = adaptiveQuestionEngine.nextQuestions(
                from: historyAnswers,
                count: questionsAmount
            )

            let questions: [PracticeQuestion]

            switch mode {

            case .all:

                questions = facts.map { fact in

                    let swap = Bool.random()

                    return PracticeQuestion(
                        left: swap ? fact.right : fact.left,
                        right: swap ? fact.left : fact.right
                    )
                }

            case .table(let table):

                questions = facts.map { fact in

                    let swap = Bool.random()

                    return PracticeQuestion(
                        left: swap ? fact.right : table,
                        right: swap ? table : fact.right
                    )
                }
            }

            return questions.shuffled()
        }

        // MARK: - RESET

        func reset() {
            questionIndex = 0
            completedQuestions = 0
            correctCount = 0

            answerText = ""

            isCorrectAnswer = false
            showAnswerButton = false
            showingCorrectAnswer = false
            isWaitingForNext = false

            shouldClearOnNextInput = false
            wrongAttempts = 0

            currentUserAnswer = nil

            answers.removeAll()
            responseTimes.removeAll()

            sessionStartTime = Date()
            sessionEndTime = nil

            questionStartTime = Date()

            questions = generateQuestions()
        }

        func pause() {
            isPaused = true
        }

        func resume() {
            isPaused = false
        }

        func restart() {
            isPaused = false
            historyAnswers = swiftDB.fetchSessions().flatMap(\.answers)
            reset()
        }

        // MARK: - INPUT

        func appendDigit(_ digit: Int) {
            guard !isPaused, !isWaitingForNext, !isCorrectAnswer else {
                return
            }

            if shouldClearOnNextInput {
                answerText = ""
                shouldClearOnNextInput = false
            }

            guard answerText.count < 2 else {
                return
            }

            answerText.append("\(digit)")
        }

        func deleteDigit() {
            guard !isPaused, !isWaitingForNext, !isCorrectAnswer, !answerText.isEmpty else {
                return
            }

            answerText.removeLast()
        }

        // MARK: - ANSWER

        func submitAnswer(completion: @escaping (PracticeSession?) -> Void) {
            if isWaitingForNext {
                let result = moveNextOrResult()
                completion(result)
                return
            }

            guard !isPaused, !isCorrectAnswer, let answer = Int(answerText) else {
                return
            }

            let responseTime = Date().timeIntervalSince(questionStartTime)
            responseTimes.append(responseTime)

            currentUserAnswer = answer

            if answer == currentQuestion.answer {
                isCorrectAnswer = true
                correctCount += 1

                saveCurrentAnswer(userAnswer: answer)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                    let result = self.moveNextOrResult()
                    completion(result)
                }
            } else {
                wrongAttempts += 1
                shakeTrigger += 1
                shouldClearOnNextInput = true

                if wrongAttempts >= 2 {
                    showAnswerButton = true
                }
            }
        }

        func showAnswer() {
            guard showAnswerButton else { return }

            showingCorrectAnswer = true
            isCorrectAnswer = true
            isWaitingForNext = true
            showAnswerButton = false

            let wrongInput = currentUserAnswer ?? Int(answerText) ?? 0

            answerText = "\(currentQuestion.answer)"

            saveCurrentAnswer(userAnswer: wrongInput)
        }

        private func saveCurrentAnswer(userAnswer: Int) {
            let answer = PracticeAnswer(
                left: currentQuestion.left,
                right: currentQuestion.right,
                correctAnswer: currentQuestion.answer,
                userAnswer: userAnswer,
                mode: .focus,
                responseTime: Date().timeIntervalSince(questionStartTime)
            )

            answers.append(answer)
            completedQuestions += 1
        }

        // MARK: - NAVIGATION

        func moveNextOrResult() -> PracticeSession? {
            if questionIndex == questions.count - 1 {
                let result = makeResult()
                reset()
                return result
            }

            questionIndex += 1
            questionStartTime = Date()

            answerText = ""

            isCorrectAnswer = false
            showAnswerButton = false
            showingCorrectAnswer = false
            isWaitingForNext = false

            shouldClearOnNextInput = false
            wrongAttempts = 0

            currentUserAnswer = nil

            return nil
        }

        // MARK: - SAVE

        private func saveSession() -> PracticeSession {
            sessionEndTime = Date()

            let session = PracticeSession(
                mode: .focus,
                focusTable: focusTable,
                duration: sessionDuration,
                difficulty: nil,
                correctAnswers: correctCount,
                questionsCount: questions.count,
                longestStreak: 0,
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

        func makeResult() -> PracticeSession {
            saveSession()
        }
    }
}
