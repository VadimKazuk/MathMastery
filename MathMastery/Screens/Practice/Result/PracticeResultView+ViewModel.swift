import Combine
import SwiftUI

extension PracticeResultView {
    final class ViewModel: ObservableObject {
        let result: PracticeResult

        init(result: PracticeResult) {
            self.result = result
        }

        var accuracyMetric: PracticeResultMetric? {
            result.metrics.first { $0.title == "Accuracy" }
        }

        var mistakeTitle: String {
            result.mode == .boss ? "Weak Points" : "Mistakes"
        }
    }
}
