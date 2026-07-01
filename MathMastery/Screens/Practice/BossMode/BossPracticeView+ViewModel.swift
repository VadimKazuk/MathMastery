import Combine
import SwiftUI

extension BossPracticeView {
    final class ViewModel: ObservableObject {
        enum Phase {
            case tableSelection
            case active
        }

        @Published var phase: Phase = .tableSelection
        @Published var selectedTable = 7
        @Published private(set) var questionIndex = 0
        @Published private(set) var correctCount = 0
        @Published private(set) var mistakes: [PracticeMistake] = []

        let tables = Array(2...12)

        var questions: [PracticeQuestion] {
            (1...10).map { PracticeQuestion(left: selectedTable, right: $0) }
        }

        var currentQuestion: PracticeQuestion {
            questions[questionIndex]
        }

        var progress: Double {
            Double(questionIndex + 1) / Double(questions.count)
        }

        var answerOptions: [Int] {
            let answer = currentQuestion.answer
            return [answer, answer + selectedTable, max(answer - selectedTable, selectedTable), answer + 2].shuffled()
        }

        func selectTable(_ table: Int) {
            selectedTable = table
        }

        func startTable() {
            phase = .active
            questionIndex = 0
            correctCount = 0
            mistakes = []
        }

        func selectAnswer(_ answer: Int) -> PracticeSession? {
            if answer == currentQuestion.answer {
                correctCount += 1
            } else {
                mistakes.append(
                    PracticeMistake(
                        left: currentQuestion.left,
                        right: currentQuestion.right,
                        correctAnswer: currentQuestion.answer,
                        userAnswer: answer,
                        mode: .boss
                    )
                )
            }

            if questionIndex == questions.count - 1 {
                return makeResult()
            }

            questionIndex += 1
            return nil
        }

        func makeResult() -> PracticeSession {
            let accuracy = Int((Double(correctCount) / Double(questions.count)) * 100)

            return PracticeSession(
                mode: .boss,
                duration: 0,
                accuracy: accuracy,
                correctAnswers: correctCount,
                questionsCount: 0,
                longestStreak: 0,
                mistakes: []
            )

        }
    }
}
