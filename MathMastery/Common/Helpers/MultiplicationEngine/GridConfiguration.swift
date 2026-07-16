import SwiftUI

struct GridConfiguration {

    var showsNumbers: Bool
    var showsHeader: Bool
    var interactive: Bool
    var showsCellValues: Bool
    var showsCellColors: Bool

    static let learning = GridConfiguration(
        showsNumbers: true,
        showsHeader: true,
        interactive: true,
        showsCellValues: true,
        showsCellColors: false
    )

    static let heatmap = GridConfiguration(
        showsNumbers: false,
        showsHeader: true,
        interactive: false,
        showsCellValues: false,
        showsCellColors: true
    )
}
