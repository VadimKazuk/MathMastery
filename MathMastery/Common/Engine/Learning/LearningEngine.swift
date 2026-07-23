import SwiftUI

final class LearnEngine {

    struct State {
        let answersIndex: [SelectedCell: [PracticeAnswer]]
        let gridState: [[CellViewState]]
    }

    struct TableStats {
        let correct: Int
        let total: Int
        let accuracy: Int
        let level: MistakeLevel
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
            result[key]?.sort {
                if $0.date == $1.date {
                    return $0.id > $1.id
                }
                return $0.date > $1.date
            }
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
                    level: CellLevelCalculator.level(
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

    func tableAccuracy(
        table: Int,
        index: [SelectedCell: [PracticeAnswer]]
    ) -> Int? {

        var correct = 0
        var total = 0

        for multiplier in numbers {

            let key = SelectedCell(
                row: min(table, multiplier),
                column: max(table, multiplier)
            )

            guard let answers = index[key] else {
                continue
            }

            let recent = answers.prefix(5)

            correct += recent.filter(\.isCorrect).count
            total += recent.count
        }

        guard total > 0 else {
            return nil
        }

        return Int((Double(correct) / Double(total) * 100).rounded())
    }

    func tableStats(
        table: Int,
        index: [SelectedCell: [PracticeAnswer]]
    ) -> TableStats? {

        var correct = 0
        var total = 0

        for multiplier in numbers {

            let key = SelectedCell(
                row: min(table, multiplier),
                column: max(table, multiplier)
            )

            let answers = index[key] ?? []

            let stats = computeStats(
                from: answers,
                limit: 5
            )

            correct += stats.correct
            total += stats.total
        }

        guard total > 0 else {
            return nil
        }

        let accuracy = Int(
            (Double(correct) / Double(total) * 100).rounded()
        )

        return TableStats(
            correct: correct,
            total: total,
            accuracy: accuracy,
            level: CellLevelCalculator.level(
                correct: correct,
                total: total
            )
        )
    }

    func overallStats(
        index: [SelectedCell: [PracticeAnswer]]
    ) -> (accuracy: Int, level: OverallLevel)? {

        var correct = 0
        var total = 0

        for answers in index.values {
            let sliced = answers.prefix(5)

            correct += sliced.filter { $0.isCorrect }.count
            total += sliced.count
        }

        guard total > 0 else { return nil }

        let accuracy = Int((Double(correct) / Double(total) * 100).rounded())

        return (
            accuracy: accuracy,
            level: overallLevel(from: accuracy)
        )
    }

    func overallLevel(from accuracy: Int) -> OverallLevel {
        switch accuracy {
        case 90...100:
            return .excellent
        case 70..<90:
            return .good
        case 50..<70:
            return .improving
        default:
            return .weak
        }
    }

}

extension LearnEngine {

    struct ActivityStats {
        let solved: Int
        let avgAccuracy: Int
        let totalTime: Int // seconds
    }

    func activityStats(from sessions: [PracticeSession]) -> ActivityStats {

        let solved = sessions.reduce(0) { $0 + $1.questionsCount }

        let avgAccuracy = sessions.isEmpty
            ? 0
            : sessions.map { $0.accuracy }.reduce(0, +) / sessions.count

        let totalTime = sessions.reduce(0) { $0 + ($1.duration ?? 0) }

        return ActivityStats(
            solved: solved,
            avgAccuracy: avgAccuracy,
            totalTime: totalTime
        )
    }

    func weeklyActivity(from sessions: [PracticeSession]) -> [DailyActivity] {

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        let days = (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -6 + offset, to: today)
        }

        return days.map { date in

            let end = calendar.date(byAdding: .day, value: 1, to: date)!

            let solved = sessions
                .filter { $0.date >= date && $0.date < end }
                .reduce(0) { $0 + $1.questionsCount }

            return DailyActivity(
                date: date,
                value: Double(solved),
                isCurrent: calendar.isDateInToday(date)
            )
        }
    }
}

