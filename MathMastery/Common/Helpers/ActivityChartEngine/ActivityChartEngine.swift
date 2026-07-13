import Foundation

final class ActivityChartEngine {

    func chart(
        sessions: [PracticeSession],
        mode: ActivityModeFilter,
        metric: ActivityMetric,
        range: ActivityRange
    ) -> [ActivityPoint] {

        let filtered = filter(
            sessions: sessions,
            mode: mode
        )

        switch range {

        case .last7Days:
            return last7Days(
                sessions: filtered,
                metric: metric
            )

        case .last30Days:
            return last30Days(
                sessions: filtered,
                metric: metric
            )

        case .last3Months:
            return last3Months(
                sessions: filtered,
                metric: metric
            )

        case .lastYear:
            return lastYear(
                sessions: filtered,
                metric: metric
            )

        case .allTime:
            return allTime(
                sessions: filtered,
                metric: metric
            )
        }
    }

    func summary(
        sessions: [PracticeSession],
        mode: ActivityModeFilter,
        metric: ActivityMetric,
        range: ActivityRange
    ) -> ActivitySummary {

        let filteredMode = filter(
            sessions: sessions,
            mode: mode
        )

        let filtered = filterRange(
            sessions: filteredMode,
            range: range
        )

        let value = metricValue(
            sessions: filtered,
            metric: metric
        )

        return ActivitySummary(

            primary: ActivityStat(
                title: title(for: metric),
                value: value,
                format: format(for: metric)
            ),

            secondary: ActivityStat(
                title: "Sessions",
                value: Double(filtered.count),
                format: .number
            ),

            tertiary: ActivityStat(
                title: "XP",
                value: Double(
                    XPSystem.total(
                        sessions: filtered
                    )
                ),
                format: .xp
            )
        )
    }
}

// MARK: - Filtering

private extension ActivityChartEngine {

    func filter(
        sessions: [PracticeSession],
        mode: ActivityModeFilter
    ) -> [PracticeSession] {

        switch mode {

        case .all:
            return sessions

        default:
            guard let practiceMode = mode.practiceMode else {
                return sessions
            }

            return sessions.filter {
                $0.mode == practiceMode
            }
        }
    }

    func filterRange(
        sessions: [PracticeSession],
        range: ActivityRange
    ) -> [PracticeSession] {

        let calendar = Calendar.current
        let now = Date()

        switch range {

        case .last7Days:
            return sessions.filter {
                $0.date >= calendar.date(
                    byAdding: .day,
                    value: -7,
                    to: now
                )!
            }

        case .last30Days:
            return sessions.filter {
                $0.date >= calendar.date(
                    byAdding: .day,
                    value: -30,
                    to: now
                )!
            }

        case .last3Months:
            return sessions.filter {
                $0.date >= calendar.date(
                    byAdding: .month,
                    value: -3,
                    to: now
                )!
            }

        case .lastYear:
            return sessions.filter {
                $0.date >= calendar.date(
                    byAdding: .year,
                    value: -1,
                    to: now
                )!
            }

        case .allTime:
            return sessions
        }
    }
}

// MARK: - Grouping

private extension ActivityChartEngine {

    func makePoints(
        sessions: [PracticeSession],
        metric: ActivityMetric,
        component: Calendar.Component,
        count: Int
    ) -> [ActivityPoint] {

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (0..<count)
            .reversed()
            .map { offset in

                let date = calendar.date(
                    byAdding: component,
                    value: -offset,
                    to: today
                )!

                let nextDate = calendar.date(
                    byAdding: component,
                    value: 1,
                    to: date
                )!

                let periodSessions = sessions.filter {
                    $0.date >= date &&
                    $0.date < nextDate
                }

                return ActivityPoint(
                    date: date,
                    value: metricValue(
                        sessions: periodSessions,
                        metric: metric
                    ),
                    sessionsCount: periodSessions.count,
                    sessions: periodSessions
                )
            }
    }

    private func last7Days(
        sessions: [PracticeSession],
        metric: ActivityMetric
    ) -> [ActivityPoint] {

        makePoints(
            sessions: sessions,
            metric: metric,
            component: .day,
            count: 7
        )
    }

    private func last30Days(
        sessions: [PracticeSession],
        metric: ActivityMetric
    ) -> [ActivityPoint] {

        makePoints(
            sessions: sessions,
            metric: metric,
            component: .day,
            count: 30
        )
    }

    private func last3Months(
        sessions: [PracticeSession],
        metric: ActivityMetric
    ) -> [ActivityPoint] {

        makePoints(
            sessions: sessions,
            metric: metric,
            component: .weekOfYear,
            count: 12
        )
    }

    private func lastYear(
        sessions: [PracticeSession],
        metric: ActivityMetric
    ) -> [ActivityPoint] {

        makePoints(
            sessions: sessions,
            metric: metric,
            component: .month,
            count: 12
        )
    }

    private func allTime(
        sessions: [PracticeSession],
        metric: ActivityMetric
    ) -> [ActivityPoint] {

        let calendar = Calendar.current

        let months = max(
            12,
            calendar.dateComponents(
                [.month],
                from: sessions.min(by: {
                    $0.date < $1.date
                })?.date ?? Date(),
                to: Date()
            ).month ?? 12
        )

        return makePoints(
            sessions: sessions,
            metric: metric,
            component: .month,
            count: months
        )
    }
}


// MARK: - Metrics

private extension ActivityChartEngine {

    func metricValue(
        sessions: [PracticeSession],
        metric: ActivityMetric
    ) -> Double {

        switch metric {

        case .solved:
            return Double(
                sessions.reduce(0) {
                    $0 + $1.correctAnswers
                }
            )

        case .accuracy:

            let correct = sessions.reduce(0) {
                $0 + $1.correctAnswers
            }

            let total = sessions.reduce(0) {
                $0 + $1.questionsCount
            }

            guard total > 0 else {
                return 0
            }

            return Double(correct)
            /
            Double(total)
            *
            100


        case .responseTime:

            let values = sessions.compactMap {
                $0.averageResponseTime
            }

            guard !values.isEmpty else {
                return 0
            }

            return values.reduce(0,+) / Double(values.count)


        case .sessions:
            return Double(sessions.count)


        case .xp:

            return Double(
                XPSystem.total(
                    sessions: sessions
                )
            )
        }
    }
}


// MARK: - UI Helpers

private extension ActivityChartEngine {

    func title(
        for metric: ActivityMetric
    ) -> String {

        switch metric {

        case .solved:
            return "Solved"

        case .accuracy:
            return "Accuracy"

        case .responseTime:
            return "Time"

        case .sessions:
            return "Sessions"

        case .xp:
            return "XP"
        }
    }


    func format(
        for metric: ActivityMetric
    ) -> ActivityValueFormat {

        switch metric {

        case .accuracy:
            return .percent

        case .responseTime:
            return .time

        case .xp:
            return .xp

        default:
            return .number
        }
    }
}
