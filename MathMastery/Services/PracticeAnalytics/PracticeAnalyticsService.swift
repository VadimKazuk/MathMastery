import Foundation

protocol PracticeAnalyticsService {
    func calculateStreak(from sessions: [PracticeSession]) -> Int
    func weeklyDays(from sessions: [PracticeSession]) -> [WeeklyDay]
}

final class PracticeAnalyticsManager: PracticeAnalyticsService {

    private var calendar: Calendar {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        return calendar
    }

    func calculateStreak(
        from sessions: [PracticeSession]
    ) -> Int {

        let practiceDays = Set(
            sessions.map {
                calendar.startOfDay(for: $0.date)
            }
        )

        var streak = 0
        var day = calendar.startOfDay(for: Date())

        while practiceDays.contains(day) {
            streak += 1

            guard let previousDay = calendar.date(
                byAdding: .day,
                value: -1,
                to: day
            ) else {
                break
            }

            day = previousDay
        }

        return streak
    }

    func weeklyDays(
        from sessions: [PracticeSession]
    ) -> [WeeklyDay] {

        let today = calendar.startOfDay(for: Date())

        guard let interval = calendar.dateInterval(
            of: .weekOfYear,
            for: today
        ) else {
            return []
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEE"

        let firstPracticeDay = sessions
            .map {
                calendar.startOfDay(for: $0.date)
            }
            .min()

        return (0..<7).map { index in

            let date = calendar.date(
                byAdding: .day,
                value: index,
                to: interval.start
            )!

            let day = calendar.startOfDay(for: date)

            let hasPractice = sessions.contains {
                calendar.isDate(
                    $0.date,
                    inSameDayAs: day
                )
            }

            let status: DayStatus

            // Пользователь ещё не начинал обучение
            if sessions.isEmpty {

                if calendar.isDateInToday(day) {
                    status = .current
                } else if day < today {
                    status = .notStarted
                } else {
                    status = index == 6 ? .reward : .locked
                }

            // Дни до первой тренировки
            } else if let firstPracticeDay,
                      day < firstPracticeDay {

                status = .notStarted

            // Прошедшие дни после старта
            } else if day < today {

                status = hasPractice ? .completed : .missed

            // Сегодня
            } else if calendar.isDateInToday(day) {

                status = hasPractice ? .completed : .current

            // Будущие дни
            } else {

                status = index == 6 ? .reward : .locked
            }

            return WeeklyDay(
                date: day,
                day: formatter.string(from: day).uppercased(),
                status: status
            )
        }
    }
}
