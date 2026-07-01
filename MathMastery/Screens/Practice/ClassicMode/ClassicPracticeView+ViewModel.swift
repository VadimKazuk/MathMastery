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
        @Published private(set) var mistakes: [PracticeMistake] = []

        private(set) var questions: [PracticeQuestion] = []

        private let questionsAmount: Int = 5

        init(serviceContainer: ServiceContainer) {
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
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

        func generateQuestions() -> [PracticeQuestion] {
            (2...9)
                .flatMap { left in
                    (2...9).map { right in
                        PracticeQuestion(left: left, right: right)
                    }
                }
                .shuffled()
                .prefix(questionsAmount)
                .map { $0 }
        }

        func reset() {
            questionIndex = 0
            completedQuestions = 0
            correctCount = 0
            answerText = ""
            feedback = nil
            isAnswered = false
            mistakes.removeAll()

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
                let mistake = PracticeMistake(
                    left: currentQuestion.left,
                    right: currentQuestion.right,
                    correctAnswer: currentQuestion.answer,
                    userAnswer: answer,
                    mode: .classic
                )

                mistakes.append(mistake)
                feedback = "Incorrect. Correct answer: \(currentQuestion.answer)"
            }

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
            let accuracy = Int((Double(correctCount) / Double(questions.count)) * 100)

            let session = PracticeSession(
                mode: .classic,
                duration: nil,
                difficulty: nil,
                accuracy: accuracy,
                correctAnswers: correctCount,
                questionsCount: questions.count,
                longestStreak: 0,
                averageResponseTime: nil,
                mistakes: mistakes
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
