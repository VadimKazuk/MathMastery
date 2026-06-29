import Combine
import SwiftUI

extension ClassicPracticeView {
    final class ViewModel: ObservableObject {
        @Published private(set) var questionIndex = 0
        @Published var answerText = ""
        @Published private(set) var feedback: String?
        @Published private(set) var isAnswered = false
        @Published private(set) var correctCount = 0
        @Published private(set) var mistakes: [String] = []

        let questions: [PracticeQuestion] = [
            .init(left: 9, right: 4),
            .init(left: 7, right: 8),
            .init(left: 6, right: 6),
            .init(left: 8, right: 3),
            .init(left: 12, right: 5)
        ]

        var currentQuestion: PracticeQuestion {
            questions[questionIndex]
        }

        var progressText: String {
            "\(questionIndex + 1) of \(questions.count)"
        }

        var progress: Double {
            Double(questionIndex + 1) / Double(questions.count)
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

            if answer == currentQuestion.answer {
                correctCount += 1
                feedback = "Correct"
            } else {
                mistakes.append("\(currentQuestion.fact), your answer: \(answer)")
                feedback = "Incorrect. Correct answer: \(currentQuestion.answer)"
            }
        }

        func moveNextOrResult() -> PracticeResult? {
            if questionIndex == questions.count - 1 {
                return makeResult()
            }

            questionIndex += 1
            answerText = ""
            feedback = nil
            isAnswered = false
            return nil
        }

        func makeResult() -> PracticeResult {
            let accuracy = Int((Double(correctCount) / Double(questions.count)) * 100)

            return PracticeResult(
                mode: .classic,
                title: "Classic Summary",
                summary: "Correctness practice without time pressure.",
                metrics: [
                    .init(title: "Questions", value: "\(questions.count)"),
                    .init(title: "Correct", value: "\(correctCount)"),
                    .init(title: "Accuracy", value: "\(accuracy)%")
                ],
                mistakes: mistakes,
                bossTable: nil
            )
        }
    }
}
