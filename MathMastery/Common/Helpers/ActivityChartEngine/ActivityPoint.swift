import Foundation

struct ActivityPoint: Identifiable {

    let id = UUID()

    let date: Date
    let value: Double

    let sessionsCount: Int

    let sessions: [PracticeSession]

    var isCurrent: Bool {
        Calendar.current.isDateInToday(date)
    }
}
