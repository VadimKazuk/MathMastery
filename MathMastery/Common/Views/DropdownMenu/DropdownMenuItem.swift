import Foundation

protocol DropdownMenuItem {
    var title: String { get }
}

extension ActivityModeFilter: DropdownMenuItem {}
extension ActivityMetric: DropdownMenuItem {}
extension ActivityRange: DropdownMenuItem {}
