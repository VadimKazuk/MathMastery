import Combine
import SwiftUI

extension HomeView {
    final class ViewModel: ObservableObject {
        private let swiftDB: SwiftDataService
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService

        private var cancellables = Set<AnyCancellable>()

        @Published var greetingName: String = "Alex"
        @Published private(set) var streakCount: Int = 0
        @Published var currentTargetTitle: String = "Focus Mode: x7"
        @Published var currentTargetSubtitle: String = "Mastering the 7 times table with speed drills."
        @Published var progressPercent: Double = 0.65
        @Published var drillsCompleted: Int = 13
        @Published var totalDrills: Int = 20

        @Published private(set) var days: [WeeklyDay] = []

        private var calendar: Calendar {
            var calendar = Calendar.current
            calendar.firstWeekday = 2 // Monday
            return calendar
        }

        var streakLevel: StreakLevel {
            StreakLevel(days: streakCount)
        }

        var avatarName: String {
            "img_profile_\(accountService.profile.avatarId)"
        }

        var hasCompletedToday: Bool {
            days.contains {
                $0.status == .completed &&
                Calendar.current.isDateInToday($0.date)
            }
        }

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.accountService = serviceContainer.resolve(AccountService.self)
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)

            loadWeeklyMilestone()
            loadStreak()
        }

        func resumeSession() {
            print("Resuming session...")
        }

        func loadStreak() {
            let sessions = swiftDB.fetchSessions()
            streakCount = calculateStreak(from: sessions)
        }

        func loadWeeklyMilestone() {
            let sessions = swiftDB.fetchSessions()
            days = buildWeek(from: sessions)
        }

        private func calculateStreak(from sessions: [PracticeSession]) -> Int {
            let calendar = Calendar.current

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

        private func buildWeek(from sessions: [PracticeSession]) -> [WeeklyDay] {
            var calendar = Calendar.current
            calendar.firstWeekday = 2

            let today = calendar.startOfDay(for: Date())

            guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
                return []
            }

            let weekStart = weekInterval.start

            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.dateFormat = "EEE"

            var result: [WeeklyDay] = []

            let hasHistory = !sessions.isEmpty

            for index in 0..<7 {

                guard let day = calendar.date(
                    byAdding: .day,
                    value: index,
                    to: weekStart
                ) else {
                    continue
                }

                let dayStart = calendar.startOfDay(for: day)

                let hasPractice = sessions.contains {
                    calendar.isDate($0.date, inSameDayAs: dayStart)
                }

                let status: DayStatus

                if !hasHistory {
                    // новый пользователь
                    if calendar.isDate(dayStart, inSameDayAs: today) {
                        status = .current
                    } else if dayStart > today {
                        status = index == 6 ? .reward : .locked
                    } else {
                        status = .empty
                    }

                } else {
                    // пользователь уже имеет историю
                    if dayStart < today {
                        status = hasPractice ? .completed : .missed

                    } else if calendar.isDate(dayStart, inSameDayAs: today) {
                        status = hasPractice ? .completed : .current

                    } else {
                        status = index == 6 ? .reward : .locked
                    }
                }

                result.append(
                    WeeklyDay(
                        date: dayStart,
                        day: formatter.string(from: dayStart).uppercased(),
                        status: status
                    )
                )
            }

            return result
        }

    }
}

import SwiftUI

struct WeeklyDay: Identifiable {
    let id = UUID()
    let date: Date
    let day: String
    let status: DayStatus
}

import SwiftUI

enum DayStatus {
    case completed
    case missed
    case current
    case locked
    case reward
    case empty

    var textColor: Color {
        switch self {
        case .completed:
            return .green
        case .current:
            return AppColor.commonAccentBlue
        case .missed:
            return .red
        case .locked, .reward, .empty:
            return .secondary
        }
    }

    var pillBackground: Color {
        switch self {
        case .completed:
            return Color.green.opacity(0.06)
        case .current:
            return AppColor.colorTodayBlue
        case .missed:
            return Color.red.opacity(0.06)
        case .locked, .reward, .empty:
            return Color(.systemGray6).opacity(0.5)
        }
    }

    var pillBorder: Color {
        switch self {
        case .completed:
            return Color.green.opacity(0.15)
        case .current:
            return AppColor.commonAccentBlue.opacity(0.2)
        default:
            return Color(.systemGray4).opacity(0.3)
        }
    }

    var iconName: String {
        switch self {
        case .completed:
            return "ic_check_milestone"

        case .current:
            return "ic_star_milestone"

        case .missed:
            return "ic_xmark_milestone"

        case .locked:
            return "ic_lock_grey"

        case .reward:
            return "ic_trophy_grey"

        case .empty:
            return "ic_circle_empty"
        }
    }

    var iconColor: Color {
        switch self {
        case .completed, .missed:
            return .white

        case .current:
            return AppColor.commonAccentBlue

        case .locked, .reward, .empty:
            return .secondary
        }
    }
}

enum StreakLevel {
    case beginner
    case active
    case hot
    case legendary

    init(days: Int) {
        switch days {
        case 0...6:
            self = .beginner
        case 7...29:
            self = .active
        case 30...99:
            self = .hot
        default:
            self = .legendary
        }
    }

    var imageName: String {
        switch self {
        case .beginner:
            return "ic_flame_1"
        case .active:
            return "ic_flame_2"
        case .hot:
            return "ic_flame_3"
        case .legendary:
            return "ic_flame_4"
        }
    }

    var color: Color {
        switch self {
        case .beginner:
            return AppColor.colorFlameYellow_1
        case .active:
            return AppColor.colorFlameOrange_2
        case .hot:
            return AppColor.colorFlameRed_3
        case .legendary:
            return AppColor.colorFlamePurple_4
        }
    }

    var title: String {
        switch self {
        case .beginner: return "Starting"
        case .active: return "On Fire"
        case .hot: return "Unstoppable"
        case .legendary: return "Legend"
        }
    }
}
