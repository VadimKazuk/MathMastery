final class LearnEngine {

    struct State {
        let answersIndex: [SelectedCell: [PracticeAnswer]]
        let gridState: [[CellViewState]]
    }

    let numbers = Array(2...9)

    func makeState(from sessions: [PracticeSession]) -> State {
        let index = buildIndex(from: sessions)
        let grid = buildGrid(from: index)
        return State(answersIndex: index, gridState: grid)
    }

    // MARK: - PUBLIC STATS API

    func selectedStats(
        row: Int?,
        column: Int?,
        index: [SelectedCell: [PracticeAnswer]]
    ) -> (correct: Int, total: Int)? {

        guard let row, let column else { return nil }

        let key = SelectedCell(
            row: min(row, column),
            column: max(row, column)
        )

        let answers = index[key] ?? []
        let sliced = answers.prefix(10)

        guard sliced.count >= 3 else {
            return (correct: 0, total: 0)
        }
        let correct = sliced.filter { $0.isCorrect }.count

        return (correct, sliced.count)
    }

    // MARK: - INDEX

    private func buildIndex(from sessions: [PracticeSession])
    -> [SelectedCell: [PracticeAnswer]] {

        var result: [SelectedCell: [PracticeAnswer]] = [:]

        for session in sessions {
            for answer in session.answers {

                let key = SelectedCell(
                    row: min(answer.left, answer.right),
                    column: max(answer.left, answer.right)
                )

                result[key, default: []].append(answer)
            }
        }

        for key in result.keys {
            result[key]?.sort { $0.date > $1.date }
        }

        return result
    }

    // MARK: - GRID

    private func buildGrid(from index: [SelectedCell: [PracticeAnswer]])
    -> [[CellViewState]] {

        numbers.map { row in
            numbers.map { col in

                let key = SelectedCell(
                    row: min(row, col),
                    column: max(row, col)
                )

                let answers = index[key] ?? []
                let stats = computeStats(from: answers, limit: 5)

                return CellViewState(
                    row: row,
                    column: col,
                    value: row * col,
                    level: CellEngine.level(
                        correct: stats.correct,
                        total: stats.total
                    )
                )
            }
        }
    }

    private func computeStats(
        from answers: [PracticeAnswer],
        limit: Int
    ) -> (correct: Int, total: Int) {

        let sliced = answers.prefix(limit)
        return (
            correct: sliced.filter { $0.isCorrect }.count,
            total: sliced.count
        )
    }
}

enum CellEngine {
    static func level(correct: Int, total: Int) -> MistakeLevel {
        guard total > 0 else { return .none }

        let accuracy = Int(((Double(correct) / Double(total)) * 100).rounded())

        switch accuracy {
        case 90...100:
            return .perfect
        case 70..<90:
            return .medium
        case 50..<70:
            return .high
        default:
            return .hard
        }
    }
}
