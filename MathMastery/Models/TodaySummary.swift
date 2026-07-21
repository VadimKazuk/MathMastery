import SwiftUI

struct TodaySummary {
    let questions: Int
    let accuracy: Int
    let practiceTime: TimeInterval
    let xp: Int

    var formattedTime: String {
        let minutes = Int(practiceTime) / 60
        let seconds = Int(practiceTime) % 60

        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }

        return "\(seconds)s"
    }
}
