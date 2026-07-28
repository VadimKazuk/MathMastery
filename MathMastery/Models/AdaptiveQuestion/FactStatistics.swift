import Foundation

struct FactStatistics {

    let attempts: Int
    let correct: Int
    let averageResponseTime: TimeInterval
    let lastAnsweredAt: Date?

    var accuracy: Double {
        guard attempts > 0 else {
            return 0
        }

        return Double(correct) / Double(attempts)
    }
}
