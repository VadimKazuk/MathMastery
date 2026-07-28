import Foundation

final class AnswerOptionEngine {

    func generate(
        for question: PracticeQuestion,
        difficulty: QuestionDifficulty = .normal
    ) -> [AnswerOption] {

        let distractors = makeDistractors(
            for: question,
            difficulty: difficulty
        )

        var options = Array(distractors.prefix(3))

        options.append(question.answer)

        return options.shuffled()
            .map {
                AnswerOption(value: $0)
            }
    }

    private func makeDistractors(
        for question: PracticeQuestion,
        difficulty: QuestionDifficulty
    ) -> Set<Int> {

        let answer = question.answer
        let left = question.left
        let right = question.right

        var distractors: Set<Int> = []

        func add(_ value: Int) {
            guard value > 0,
                  value != answer
            else {
                return
            }

            distractors.insert(value)
        }

        switch difficulty {

        case .easy:

            add(answer + 1)
            add(answer - 1)

            add(answer + 10)
            add(answer - 10)

        case .normal:

            add(answer + 1)
            add(answer - 1)

            add((left + 1) * right)
            add(left * (right + 1))

            add(answer + left)
            add(answer - right)

        case .hard:

            add((left + 1) * (right + 1))
            add((left - 1) * right)

            add(left * (right - 1))
            add(answer + left + right)

            add(answer - left - right)
        }

        var attempts = 0

        while distractors.count < 3 && attempts < 50 {

            add(
                Int.random(in: 1...100)
            )

            attempts += 1
        }

        return distractors
    }
}
