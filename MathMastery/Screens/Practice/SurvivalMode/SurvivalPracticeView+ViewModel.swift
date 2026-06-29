import Combine
import SwiftUI

extension SurvivalPracticeView {
    final class ViewModel: ObservableObject {
        @Published private(set) var lives = 3
        @Published private(set) var survivedCount = 0
        @Published private(set) var correctCount = 0
        @Published private(set) var currentStreak = 14
        @Published private(set) var longestStreak = 14
        @Published private(set) var questionIndex = 0

        let questions: [PracticeQuestion] = [
            .init(left: 7, right: 6),
            .init(left: 9, right: 8),
            .init(left: 6, right: 7),
            .init(left: 8, right: 4)
        ]

        var currentQuestion: PracticeQuestion {
            questions[questionIndex % questions.count]
        }

        var answerOptions: [Int] {
            let answer = currentQuestion.answer
            return [answer - 6, answer, answer + 6, answer + 12].shuffled()
        }

        func selectAnswer(_ answer: Int) -> PracticeResult? {
            survivedCount += 1

            if answer == currentQuestion.answer {
                correctCount += 1
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
                questionIndex += 1
                return nil
            }

            lives -= 1
            currentStreak = 0
            questionIndex += 1

            return lives == 0 ? makeResult() : nil
        }

        func makeResult() -> PracticeResult {
            let accuracy = survivedCount == 0 ? 0 : Int((Double(correctCount) / Double(survivedCount)) * 100)

            return PracticeResult(
                mode: .survival,
                title: "Survival Results",
                summary: "Accuracy under pressure.",
                metrics: [
                    .init(title: "Survived", value: "\(survivedCount)"),
                    .init(title: "Accuracy", value: "\(accuracy)%"),
                    .init(title: "Longest Streak", value: "\(longestStreak)")
                ],
                mistakes: [],
                bossTable: nil
            )
        }
    }
}
