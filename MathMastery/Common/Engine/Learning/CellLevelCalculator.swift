import Foundation

enum CellLevelCalculator {
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
