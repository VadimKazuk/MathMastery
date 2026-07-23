import Foundation

final class ImprovementEngine {

    private let targetAccuracy = 0.6
    private let learnEngine = LearnEngine()
    private let storage: ImprovementStorage

    init(
        storage: ImprovementStorage = ImprovementStorage()
    ) {
        self.storage = storage
    }

    func clearPreviousTable() {
        storage.previousTable = nil
    }

    func recommendation(
        sessions: [PracticeSession]
    ) -> ImprovementRecommendation? {

        let state = learnEngine.makeState(
            from: sessions
        )

        let tables = (2...9).compactMap { table -> TableScore? in

            guard let stats = learnEngine.tableStats(
                table: table,
                index: state.answersIndex
            ) else {
                return nil
            }

            guard stats.total >= 10 else {
                return nil
            }

            return TableScore(
                table: table,
                correct: stats.correct,
                total: stats.total
            )
        }


        guard let currentTable = storage.table,
              let current = tables.first(where: {
                  $0.table == currentTable
              }) else {

            guard let first = tables
                .filter({ $0.accuracy < targetAccuracy })
                .min(
                    by: {
                        $0.accuracy < $1.accuracy
                    }
                ) else {
                return nil
            }

            storage.table = first.table

            return makeRecommendation(
                first
            )
        }


        if current.accuracy >= targetAccuracy {
            guard let next = makeNextTable(
                from: tables,
                excluding: current.table
            ) else {
                storage.table = nil
                return nil
            }

            storage.previousTable = current.table
            storage.completedTable = current.table
            storage.table = next.table

            return makeRecommendation(
                next,
                previousTable: current.table
            )
        }

        return makeRecommendation(current)
    }

    /// Builds a snapshot for a specific table without changing the saved goal.
    /// Home uses this to animate the just-completed goal before showing the next one.
    func recommendation(
        sessions: [PracticeSession],
        forTable table: Int
    ) -> ImprovementRecommendation? {
        let state = learnEngine.makeState(from: sessions)

        guard let stats = learnEngine.tableStats(
            table: table,
            index: state.answersIndex
        ), stats.total >= 10 else {
            return nil
        }

        return makeRecommendation(
            TableScore(
                table: table,
                correct: stats.correct,
                total: stats.total
            )
        )
    }
}

private extension ImprovementEngine {

    func makeRecommendation(
        _ score: TableScore,
        previousTable: Int? = nil
    ) -> ImprovementRecommendation {

        ImprovementRecommendation(
            type: .multiplicationTable,
            state: .improving,
            focusTitle: "Focus ×\(score.table)",
            metricTitle: "Accuracy",
            currentValue: score.accuracy,
            targetValue: targetAccuracy,
            attempts: score.total,
            progress: min(
                score.accuracy / targetAccuracy,
                1
            ),
            previousTable: previousTable ?? storage.previousTable,
            action: .focusTable(score.table)
        )
    }

    func makeNextTable(
        from tables: [TableScore],
        excluding table: Int
    ) -> TableScore? {

        tables
            .filter {
                $0.table != table && $0.accuracy < targetAccuracy
            }
            .min {
                $0.accuracy < $1.accuracy
            }
    }
}
