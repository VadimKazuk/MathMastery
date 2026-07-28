import SwiftUI

struct ImprovementRecommendation: Identifiable {

    let id = UUID()

    let type: ImprovementType
    let state: ImprovementState

    let focusTitle: String
    let metricTitle: String

    let currentValue: Double
    let targetValue: Double

    let attempts: Int
    let progress: Double

    let previousTable: Int?

    let action: ImprovementAction
}

enum ImprovementType {
    case multiplicationTable
    case accuracy
    case speed
    case streak
}

enum ImprovementAction {
    case focusTable(Int)
    case practiceMode(PracticeMode)
}

enum ImprovementState {
    case improving
    case completed(table: Int, nextTable: Int)
}

extension ImprovementType {
    var icon: String {
        switch self {
        case .multiplicationTable:
            return "ic_focus_improvement_animated"
        case .accuracy:
            return "ic_focus_improvement_animated"
        case .speed:
            return "ic_focus_improvement_animated"
        case .streak:
            return "ic_focus_improvement_animated"
        }
    }
}

enum ImprovementCardState {
    case improving
    case improved(previousTable: Int)
    case normal
}
