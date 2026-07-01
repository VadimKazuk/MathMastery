import Combine
import SwiftUI

extension SurvivalPracticeView {
    final class ViewModel: ObservableObject {

        private let swiftDB: SwiftDataService

        @Published private(set) var lives = 3
        @Published private(set) var correctCount = 0
        @Published private(set) var survivedCount = 0

        @Published private(set) var currentStreak = 0
        @Published private(set) var longestStreak = 0

        @Published private(set) var currentQuestion = ViewModel.makeRandomQuestion()
        @Published private(set) var answerOptions: [AnswerOption] = []

        @Published private(set) var isFinished = false
        @Published private(set) var isAcceptingAnswers = true

        @Published private(set) var mistakes: [PracticeMistake] = []

        private var didFinish = false

        private static let questionRange = 2...9

        init(serviceContainer: ServiceContainer) {
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
            updateAnswerOptions()
        }

        // MARK: - Reset

        func resetSession() {
            lives = 3
            correctCount = 0
            survivedCount = 0

            currentStreak = 0
            longestStreak = 0

            mistakes.removeAll()

            isFinished = false
            isAcceptingAnswers = true
            didFinish = false

            currentQuestion = Self.makeRandomQuestion()
            updateAnswerOptions()
        }

        // MARK: - Finish

        func finish() {
            guard !didFinish else { return }
            didFinish = true

            isFinished = true
            isAcceptingAnswers = false
        }

        // MARK: - Answer

        @MainActor
        func selectAnswer(_ answer: Int) {
            guard isAcceptingAnswers, !isFinished else { return }

            isAcceptingAnswers = false
            survivedCount += 1

            let isCorrect = answer == currentQuestion.answer

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

        private func advance(isCorrect: Bool, userAnswer: Int) {

            if isCorrect {
                correctCount += 1
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                lives -= 1
                currentStreak = 0

                mistakes.append(
                    PracticeMistake(
                        left: currentQuestion.left,
                        right: currentQuestion.right,
                        correctAnswer: currentQuestion.answer,
                        userAnswer: userAnswer,
                        mode: .survival
                    )
                )
            }

            if lives <= 0 {
                finish()
                return
            }

            currentQuestion = Self.makeRandomQuestion()
            updateAnswerOptions()
            isAcceptingAnswers = true
        }

        // MARK: - SwiftData

        private func saveSession() -> PracticeSession {
            let accuracy = survivedCount == 0
                ? 0
                : Int(Double(correctCount) / Double(survivedCount) * 100)

            let session = PracticeSession(
                mode: .survival,
                duration: nil,
                difficulty: nil,
                accuracy: accuracy,
                correctAnswers: correctCount,
                questionsCount: survivedCount,
                longestStreak: longestStreak,
                averageResponseTime: nil,
                mistakes: mistakes
            )

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

        private static func makeRandomQuestion() -> PracticeQuestion {
            PracticeQuestion(
                left: questionRange.randomElement()!,
                right: questionRange.randomElement()!
            )
        }

        func backgroundColor(for option: AnswerOption) -> Color {
            switch option.state {
            case .normal: return .white
            case .correct: return .green.opacity(0.25)
            case .wrong: return .red.opacity(0.25)
            }
        }
    }
}
