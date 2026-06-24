import SwiftUI
import Combine

extension ToastModifier {
    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer

        @Published var isShowing: Bool = false
        @Published var title: String = ""
        @Published var message: String = ""

        private var cancellables = Set<AnyCancellable>()

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer

            let toastManager = serviceContainer.resolve(ToastManager.self)
            toastManager.$isShowing
                .map{
                    $0
                }
                .assign(to: \.isShowing, on: self)
                .store(in: &cancellables)

            toastManager.$title
                .map{
                    $0
                }
                .assign(to: \.title, on: self)
                .store(in: &cancellables)

            toastManager.$message
                .map{
                    $0
                }
                .assign(to: \.message, on: self)
                .store(in: &cancellables)
        }

        func startTimer() {
            let toastManager = serviceContainer.resolve(ToastManager.self)
            toastManager.startTimer()
        }

        func dismissTimer() {
            let toastManager = serviceContainer.resolve(ToastManager.self)
            toastManager.dismissTimer()
        }

        func hideToast() {
            let toastManager = serviceContainer.resolve(ToastManager.self)
            toastManager.hideToast()
        }

    }
}
