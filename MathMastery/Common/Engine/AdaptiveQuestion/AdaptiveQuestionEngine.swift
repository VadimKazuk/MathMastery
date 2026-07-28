import Foundation

final class AdaptiveQuestionEngine {

    private let masteryEngine = FactMasteryEngine()

    private let questionRange = 2...9

    private var allFacts: [MultiplicationFact] {
        var facts: [MultiplicationFact] = []

        for left in questionRange {
            for right in questionRange where left <= right {
                facts.append(
                    MultiplicationFact(
                        left: left,
                        right: right
                    )
                )
            }
        }

        return facts
    }

    func nextQuestion(
        from answers: [PracticeAnswer]
    ) -> MultiplicationFact {

        let weightedFacts = weightedFacts(
            from: answers
        )

        return pickFact(
            from: weightedFacts
        )
    }

    func nextPracticeQuestion(
        from answers: [PracticeAnswer]
    ) -> PracticeQuestion {

        let fact = nextQuestion(
            from: answers
        )

        let shouldSwap = Bool.random()

        return PracticeQuestion(
            left: shouldSwap ? fact.right : fact.left,
            right: shouldSwap ? fact.left : fact.right
        )
    }

    func nextQuestions(
        from answers: [PracticeAnswer],
        count: Int
    ) -> [MultiplicationFact] {

        var weightedFacts = weightedFacts(
            from: answers
        )

        var selected: [MultiplicationFact] = []

        while selected.count < count && !weightedFacts.isEmpty {

            let fact = pickFact(
                from: weightedFacts
            )

            selected.append(fact)

            weightedFacts.removeAll {
                $0.value == fact
            }
        }

        while selected.count < count {
            selected.append(
                randomFact()
            )
        }

        return selected
    }

    private func weightedFacts(
        from answers: [PracticeAnswer]
    ) -> [Weighted<MultiplicationFact>] {

        let masteries = masteryEngine.masteries(
            from: answers
        )

        return allFacts.map { fact in

            let mastery =
                masteries[fact]?.score ?? 0

            return Weighted(
                value: fact,
                weight: weight(
                    from: mastery
                )
            )
        }
    }

    private func weight(
        from mastery: Int
    ) -> Int {

        max(
            5,
            100 - mastery
        )
    }

    private func pickFact(
        from weightedFacts: [Weighted<MultiplicationFact>]
    ) -> MultiplicationFact {

        let totalWeight = weightedFacts.reduce(0) {
            $0 + $1.weight
        }

        guard totalWeight > 0 else {
            return randomFact()
        }

        var randomPoint = Int.random(
            in: 1...totalWeight
        )

        for item in weightedFacts {

            randomPoint -= item.weight

            if randomPoint <= 0 {
                return item.value
            }
        }

        return randomFact()
    }

    private func randomFact() -> MultiplicationFact {

        let left = questionRange.randomElement() ?? 2
        let right = questionRange.randomElement() ?? 2

        return MultiplicationFact(
            left: min(left, right),
            right: max(left, right)
        )
    }
}
