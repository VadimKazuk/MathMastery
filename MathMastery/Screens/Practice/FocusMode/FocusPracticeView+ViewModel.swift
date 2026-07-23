import Combine
import SwiftUI

extension FocusPracticeView {
    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService
        private let swiftDB: SwiftDataService

        let mode: FocusPracticeMode
        let focusTable: Int?

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

        private let questionsAmount: Int = 10
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

            self.questions = generateQuestions()

            self.sessionStartTime = Date()
            self.questionStartTime = Date()
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
            sessionEndTime = sessionEndTime ?? Date()

            guard
                let start = sessionStartTime,
                let end = sessionEndTime
            else {
                return 0
            }

            return Int(end.timeIntervalSince(start))
        }

        private var averageResponseTimeValue: Double {
            guard !responseTimes.isEmpty else { return 0 }
            return responseTimes.reduce(0,+) / Double(responseTimes.count)
        }

        private var fastestResponseTimeValue: Double {
            responseTimes.min() ?? 0
        }

        private var answersPerMinuteValue: Double {
            guard sessionDuration > 0 else { return 0 }
            return Double(completedQuestions) / Double(sessionDuration) * 60
        }

        var currentQuestion: PracticeQuestion {
            questions[questionIndex]
        }

        var progressText: String {
            "\(questionIndex + 1) of \(questions.count)"
        }

        var progress: Double {
            Double(completedQuestions) / Double(questions.count)
        }

        // MARK: - QUESTIONS

        func generateQuestions() -> [PracticeQuestion] {
            let allAnswers = swiftDB.fetchSessions().flatMap { $0.answers }

            let selectedCells = SmartQuestionGenerator.generateSessionCells(
                allAnswers: allAnswers,
                amount: questionsAmount
            )

            switch mode {
            case .all:
                return selectedCells
                    .map { PracticeQuestion(left: $0.left, right: $0.right) }
                    .shuffled()

            case .table(let table):
                let generated = selectedCells.map { cell in
                    let shouldSwap = Bool.random()
                    let left = shouldSwap ? cell.right : table
                    let right = shouldSwap ? table : cell.right
                    return PracticeQuestion(left: left, right: right)
                }
                return generated.shuffled()
            }
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

            answers.removeAll()

            sessionStartTime = Date()
            sessionEndTime = nil

            responseTimes.removeAll()
            questionStartTime = Date()

            questions = generateQuestions()
        }

        func pause() { isPaused = true }
        func resume() { isPaused = false }
        func restart() {
            isPaused = false
            reset()
        }

        // MARK: - INPUT

        func appendDigit(_ digit: Int) {
            guard !isPaused, !isWaitingForNext, !isCorrectAnswer else { return }

            if shouldClearOnNextInput {
                answerText = ""
                shouldClearOnNextInput = false
            }

            guard answerText.count < 2 else { return }
            answerText.append("\(digit)")
        }

        func deleteDigit() {
            guard !isPaused, !isWaitingForNext, !isCorrectAnswer, !answerText.isEmpty else { return }
            answerText.removeLast()
        }

        // MARK: - ANSWER

        func submitAnswer(completion: @escaping (PracticeSession?) -> Void) {
            // Если горит режим "NEXT" (после клика на Show Answer)
            if isWaitingForNext {
                let result = moveNextOrResult()
                completion(result)
                return
            }

            guard !isPaused,
                  !isCorrectAnswer,
                  let answer = Int(answerText)
            else { return }

            let isCorrect = answer == currentQuestion.answer
            currentUserAnswer = answer

            if isCorrect {
                // 1. Включаем подсвечивание зеленым
                isCorrectAnswer = true
                correctCount += 1
                saveCurrentAnswer(userAnswer: answer)

                // 2. Короткая пауза (350мс), чтобы пользователь успел увидеть зеленый цвет
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

            // Берем последний введенный пользователем ответ
            let wrongInput = currentUserAnswer ?? (Int(answerText) ?? 0)

            answerText = "\(currentQuestion.answer)"

            // Сохраняем неверный ответ
            saveCurrentAnswer(userAnswer: wrongInput)
        }

        private func saveCurrentAnswer(userAnswer: Int) {
            answers.append(
                PracticeAnswer(
                    left: currentQuestion.left,
                    right: currentQuestion.right,
                    correctAnswer: currentQuestion.answer,
                    userAnswer: userAnswer,
                    mode: .focus
                )
            )
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

            return nil
        }

        // MARK: - SAVE

        private func saveSession() -> PracticeSession {
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
