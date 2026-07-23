extension ContentContainerView {
    enum ContentViewType: Hashable {
        case home
        case learn
        case practice
        case profile
    }
}

import Foundation

enum PracticeLaunch: Identifiable {
    case focus(table: Int, canChangeTable: Bool)
    case mode(PracticeMode)

    var id: String {
        switch self {
        case .focus(let table, _):
            return "focus_\(table)"

        case .mode(let mode):
            return mode.rawValue
        }
    }
}
