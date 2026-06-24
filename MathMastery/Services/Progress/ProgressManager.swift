import SwiftUI
import Combine

class ProgressManager: ObservableObject {
    @Published var isShowing: Bool = false

    func showProgressIndicator() {
        isShowing = true
    }

    func hideProgressIndicator() {
        isShowing = false
    }
}
