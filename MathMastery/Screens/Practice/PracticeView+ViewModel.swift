import Combine
import SwiftUI

extension PracticeView {
    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private var cancellables = Set<AnyCancellable>()

        let currentStreak = 12
        let bestScore = 2_450
        let modes = PracticeMode.allCases

        @Published var selectedMode: PracticeMode? = nil
        @Published var path: [PracticeRoute] = []

        @Published var showStartButton = false

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
        }

        func selectMode(_ mode: PracticeMode) {
            selectedMode = mode
        }

        func startSelectedMode() {
            guard let mode = selectedMode else { return }
            startMode(mode)
        }

        func startMode(_ mode: PracticeMode) {
            selectedMode = mode

            switch mode {
            case .speed:
                path = [.speed]
            case .classic:
                path = [.classic]
            case .survival:
                path = [.survival]
            case .boss:
                path = [.boss]
            }
        }

        func showResult(_ result: PracticeResult) {
            path.append(.result(result))
        }

        func retry(_ mode: PracticeMode) {
            startMode(mode)
        }

        func returnToHub() {
            path = []
        }
    }
}
