import Foundation

final class DailyChallengeGenerator {

    private let masteryHistory = MasteryChallengeHistory()

    func generate(
        from sessions: [PracticeSession],
        for date: Date = Date()
    ) -> [DailyChallengeDefinition] {

        let seed = Calendar.current.ordinality(
            of: .day,
            in: .year,
            for: date
        ) ?? 0

        var generator = SeededRandomNumberGenerator(seed: seed)

        var challenges = [
            DailyChallengeDefinition(
                type: .questions,
                target: [20, 30, 40, 50].random(using: &generator),
                mode: nil,
                metadata: nil
            ),

            DailyChallengeDefinition(
                type: .accuracy,
                target: 100,
                mode: nil,
                metadata: "10"
            ),

            DailyChallengeDefinition(
                type: .mode,
                target: 1,
                mode: [
                    .speed,
                    .focus,
                    .rush,
                    .survival
                ].random(using: &generator),
                metadata: nil
            ),

            DailyChallengeDefinition(
                type: .mastery,
                target: [20, 30, 40].random(using: &generator),
                mode: nil,
                metadata: "\(recommendedMasteryTable(sessions: sessions))"
            ),

            DailyChallengeDefinition(
                type: .xp,
                target: [100, 150, 200, 250].random(using: &generator),
                mode: nil,
                metadata: nil
            ),

            DailyChallengeDefinition(
                type: .survival,
                target: [60, 120, 180].random(using: &generator),
                mode: nil,
                metadata: nil
            ),

            DailyChallengeDefinition(
                type: .streak,
                target: [5, 10, 15, 20].random(using: &generator),
                mode: nil,
                metadata: nil
            ),

            DailyChallengeDefinition(
                type: .noMistakes,
                target: [10, 15, 20].random(using: &generator),
                mode: nil,
                metadata: nil
            ),

            DailyChallengeDefinition(
                type: .modeMaster,
                target: 4,
                mode: nil,
                metadata: nil
            ),

            DailyChallengeDefinition(
                type: .personalBest,
                target: 1,
                mode: [
                    .speed,
                    .rush,
                    .survival
                ].random(using: &generator),
                metadata: nil
            )
        ]

        challenges.shuffle(using: &generator)

        return Array(challenges.prefix(3))
    }

    private func recommendedMasteryTable(
        sessions: [PracticeSession]
    ) -> Int {

        let history = masteryHistory.load()

        let scores = masteryScores(
            sessions: sessions
        )
            .filter {
                !history.contains($0.table)
            }
            .sorted {
                $0.accuracy < $1.accuracy
            }

        let candidates = Array(scores.prefix(3))

        let selected =
        candidates.randomElement()?.table
        ?? Int.random(in: 2...9)


        masteryHistory.save(
            table: selected
        )

        return selected
    }

    private func masteryScores(
        sessions: [PracticeSession]
    ) -> [MasteryScore] {

        var stats: [Int:(correct:Int,total:Int)] = [:]

        sessions
            .flatMap(\.answers)
            .forEach { answer in

                let numbers = [
                    answer.left,
                    answer.right
                ]


                numbers.forEach { number in

                    guard number >= 2 && number <= 9 else {
                        return
                    }


                    if stats[number] == nil {
                        stats[number] = (0,0)
                    }


                    stats[number]?.total += 1


                    if answer.isCorrect {
                        stats[number]?.correct += 1
                    }
                }
            }

        return (2...9).map { table in

            let stat = stats[table] ?? (0,0)

            let accuracy =
            stat.total > 0
            ? Double(stat.correct) / Double(stat.total)
            : 1

            return MasteryScore(
                table: table,
                accuracy: accuracy,
                attempts: stat.total
            )
        }
    }
}

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: Int) {
        self.state = UInt64(seed)
    }

    mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }
}

extension Array {
    func random(
        using generator: inout SeededRandomNumberGenerator
    ) -> Element {
        self[Int.random(in: 0..<count, using: &generator)]
    }
}
