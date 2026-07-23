import SwiftUI

struct WeeklyDay: Identifiable {
    let id = UUID()
    let date: Date
    let day: String
    let status: DayStatus
}
