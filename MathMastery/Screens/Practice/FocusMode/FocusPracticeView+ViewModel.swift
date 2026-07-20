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
        @Published private(set) var feedback: String?
        @Published private(set) var isAnswered = false
        @Published private(set) var correctCount = 0
        @Published private(set) var completedQuestions = 0
        @Published private(set) var answers: [PracticeAnswer] = []

        private(set) var questions: [PracticeQuestion] = []

        private let questionsAmount: Int = 5
        private var isPaused = false

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
            feedback = nil
            isAnswered = false

            answers.removeAll()
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
            reset()
        }

        // MARK: - INPUT

        func appendDigit(_ digit: Int) {
            guard !isPaused,
                  !isAnswered,
                  answerText.count < 3
            else { return }
            answerText.append("\(digit)")
        }

        func deleteDigit() {
            guard !isPaused,
                  !isAnswered,
                  !answerText.isEmpty
            else { return }
            answerText.removeLast()
        }

        // MARK: - ANSWER

        func submitAnswer() {
            guard !isPaused,
                  !isAnswered,
                  let answer = Int(answerText)
            else { return }

            isAnswered = true

            let isCorrect = answer == currentQuestion.answer

            if isCorrect {
                correctCount += 1
                feedback = "Correct"
            } else {
                feedback = "Incorrect. Correct answer: \(currentQuestion.answer)"
            }

            answers.append(
                PracticeAnswer(
                    left: currentQuestion.left,
                    right: currentQuestion.right,
                    correctAnswer: currentQuestion.answer,
                    userAnswer: answer,
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
            answerText = ""
            feedback = nil
            isAnswered = false

            return nil
        }

        // MARK: - SAVE

        private func saveSession() -> PracticeSession {
            let session = PracticeSession(
                mode: .focus,
                focusTable: focusTable,
                duration: nil,
                difficulty: nil,
                correctAnswers: correctCount,
                questionsCount: questions.count,
                longestStreak: 0,
                averageResponseTime: nil,
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
