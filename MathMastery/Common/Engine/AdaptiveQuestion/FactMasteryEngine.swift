import Foundation

struct FactMastery {
    let score: Int
    let attempts: Int
    let accuracy: Double
    let averageResponseTime: TimeInterval
    let lastAnsweredAt: Date?
}

import Foundation

final class FactMasteryEngine {

    func mastery(
        for question: PracticeQuestion,
        answers: [PracticeAnswer]
    ) -> FactMastery {

        let relatedAnswers = answers.filter {
            matches(
                answer: $0,
                question: question
            )
        }

        return calculateMastery(
            from: relatedAnswers
        )
    }


    func mastery(
        for cell: (left: Int, right: Int),
        answers: [PracticeAnswer]
    ) -> FactMastery {

        let relatedAnswers = answers.filter {
            let minLeft = min($0.left, $0.right)
            let maxRight = max($0.left, $0.right)

            return minLeft == cell.left &&
                   maxRight == cell.right
        }

        return calculateMastery(
            from: relatedAnswers
        )
    }

    func masteries(
        from answers: [PracticeAnswer]
    ) -> [MultiplicationFact: FactMastery] {

        var result: [MultiplicationFact: FactMastery] = [:]

        for left in 2...9 {
            for right in left...9 {

                let fact = MultiplicationFact(
                    left: left,
                    right: right
                )

                result[fact] = mastery(
                    for: (
                        left: left,
                        right: right
                    ),
                    answers: answers
                )
            }
        }

        return result
    }

    private func matches(
        answer: PracticeAnswer,
        question: PracticeQuestion
    ) -> Bool {

        let answerMin = min(answer.left, answer.right)
        let answerMax = max(answer.left, answer.right)

        let questionMin = min(question.left, question.right)
        let questionMax = max(question.left, question.right)

        return answerMin == questionMin &&
               answerMax == questionMax
    }


    private func calculateMastery(
        from answers: [PracticeAnswer]
    ) -> FactMastery {

        guard !answers.isEmpty else {
            return FactMastery(
                score: 0,
                attempts: 0,
                accuracy: 0,
                averageResponseTime: 0,
                lastAnsweredAt: nil
            )
        }


        let attempts = answers.count


        let correct = answers.filter {
            $0.isCorrect
        }
        .count


        let accuracy =
            Double(correct) /
            Double(attempts)


        let averageResponseTime =
            answers.reduce(0) {
                $0 + $1.responseTime
            }
            /
            Double(attempts)


        let lastAnsweredAt =
            answers.max {
                $0.date < $1.date
            }?
            .date


        let score = calculateScore(
            accuracy: accuracy,
            attempts: attempts,
            averageResponseTime: averageResponseTime,
            lastAnsweredAt: lastAnsweredAt
        )


        return FactMastery(
            score: Int(score.rounded()),
            attempts: attempts,
            accuracy: accuracy,
            averageResponseTime: averageResponseTime,
            lastAnsweredAt: lastAnsweredAt
        )
    }


    private func calculateScore(
        accuracy: Double,
        attempts: Int,
        averageResponseTime: Double,
        lastAnsweredAt: Date?
    ) -> Double {


        var score = 0.0


        // Accuracy 0-60%
        score += accuracy * 60


        // Опыт
        let experienceBonus =
            min(Double(attempts) * 5, 20)

        score += experienceBonus


        // Скорость
        switch averageResponseTime {

        case 0..<1.5:
            score += 20

        case 1.5..<3:
            score += 10

        default:
            break
        }


        // Забывание со временем
        if let lastAnsweredAt {

            let days =
                Calendar.current
                    .dateComponents(
                        [.day],
                        from: lastAnsweredAt,
                        to: Date()
                    )
                    .day ?? 0


            if days > 7 {
                score -= Double(days - 7)
            }
        }


        return min(
            max(score, 0),
            100
        )
    }
}
