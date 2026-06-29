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
        @Published private(set) var wrongFacts: [String] = []

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
            wrongFacts = []
        }

        func selectAnswer(_ answer: Int) -> PracticeResult? {
            if answer == currentQuestion.answer {
                correctCount += 1
            } else {
                wrongFacts.append(currentQuestion.fact)
            }

            if questionIndex == questions.count - 1 {
                return makeResult()
            }

            questionIndex += 1
            return nil
        }

        func makeResult() -> PracticeResult {
            let accuracy = Int((Double(correctCount) / Double(questions.count)) * 100)

            return PracticeResult(
                mode: .boss,
                title: "×\(selectedTable) Mastery",
                summary: "Table-specific mastery check complete.",
                metrics: [
                    .init(title: "Accuracy", value: "\(accuracy)%"),
                    .init(title: "Weak Facts", value: "\(wrongFacts.count)"),
                    .init(title: "Mastery Score", value: "\(accuracy)")
                ],
                mistakes: wrongFacts,
                bossTable: selectedTable
            )
        }
    }
}
