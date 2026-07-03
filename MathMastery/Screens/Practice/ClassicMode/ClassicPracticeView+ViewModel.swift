import Combine
import SwiftUI

extension ClassicPracticeView {
    final class ViewModel: ObservableObject {

        private let swiftDB: SwiftDataService

        @Published private(set) var questionIndex = 0
        @Published var answerText = ""
        @Published private(set) var feedback: String?
        @Published private(set) var isAnswered = false
        @Published private(set) var correctCount = 0
        @Published private(set) var completedQuestions = 0
        @Published private(set) var answers: [PracticeAnswer] = []

        private(set) var questions: [PracticeQuestion] = []

        private let questionsAmount: Int = 5

        init(serviceContainer: ServiceContainer) {
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
            // Инициализируем пул вопросов по умной системе весов
            questions = generateQuestions()
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

        // MARK: - Smart Question Generation Integration

        func generateQuestions() -> [PracticeQuestion] {
            // 1. Извлекаем историю всех прошлых ответов из SwiftData
            let allAnswers = swiftDB.fetchSessions().flatMap { $0.answers }

            // 2. Запрашиваем у генератора уникальный набор ячеек для текущей сессии
            let selectedCells = SmartQuestionGenerator.generateSessionCells(
                allAnswers: allAnswers,
                amount: questionsAmount
            )

            // 3. Превращаем выбранные ячейки в массив PracticeQuestion с визуальным перемешиванием множителей
            let generatedQuestions = selectedCells.map { cell -> PracticeQuestion in
                let shouldSwap = Bool.random()
                return PracticeQuestion(
                    left: shouldSwap ? cell.right : cell.left,
                    right: shouldSwap ? cell.left : cell.right
                )
            }

            // Перемешиваем готовый набор, чтобы новые/сложные примеры не шли подряд кучей
            return generatedQuestions.shuffled()
        }

        func reset() {
            questionIndex = 0
            completedQuestions = 0
            correctCount = 0
            answerText = ""
            feedback = nil
            isAnswered = false

            answers.removeAll()

            // Перегенерируем пул по умной схеме
            questions = generateQuestions()
        }

        func appendDigit(_ digit: Int) {
            guard !isAnswered, answerText.count < 3 else { return }
            answerText.append("\(digit)")
        }

        func deleteDigit() {
            guard !isAnswered, !answerText.isEmpty else { return }
            answerText.removeLast()
        }

        func submitAnswer() {
            guard !isAnswered, let answer = Int(answerText) else { return }

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
                    mode: .classic
                )
            )

            completedQuestions += 1
        }

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

        // MARK: - SwiftData

        private func saveSession() -> PracticeSession {
            let session = PracticeSession(
                mode: .classic,
                duration: nil,
                difficulty: nil,
                correctAnswers: correctCount,
                questionsCount: questions.count,
                longestStreak: 0,
                averageResponseTime: nil,
                answers: answers
            )

            swiftDB.saveSession(session)
            return session
        }

        func makeResult() -> PracticeSession {
            let session = saveSession()
            return session
        }
    }
}
