import SwiftUI
import Combine

class ToastManager: ObservableObject {
    @Published var isShowing: Bool = false
    @Published var title: String = ""
    @Published var message: String = ""
    @Published var duration: Double = 3.0
    @Published var alwaysShow: Bool = false

    private var timer: Timer?

    func showToast(title: String, message: String, duration: Double = 5.0, alwaysShow: Bool = false) {
        self.title = title
        self.message = message
        self.duration = duration
        self.isShowing = true
        self.alwaysShow = alwaysShow

        if !alwaysShow {
            startTimer()
        }
    }

    func hideToast() {
        self.isShowing = false
    }

    func startTimer() {
        timer?.invalidate()

        timer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.isShowing = false
        }
    }

    func pauseTimer() {
        timer?.invalidate()
        timer = nil
    }

    func dismissTimer() {
        timer?.invalidate()
    }

}
