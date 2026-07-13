import Combine
import SwiftUI

extension PracticeView {
    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService

        private var cancellables = Set<AnyCancellable>()

        let currentStreak = 12
        let bestScore = 2_450
        let modes = PracticeMode.allCases

        @Published var selectedMode: PracticeMode? = nil
        @Published var path: [PracticeRoute] = []

        @Published var showStartButton = false

        var avatarName: String {
            "img_profile_\(accountService.profile.avatarId)"
        }

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.accountService = serviceContainer.resolve(AccountService.self)
        }

        func selectMode(_ mode: PracticeMode) {
            if selectedMode == mode {
                selectedMode = nil
            } else {
                selectedMode = mode
            }
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
            case .focus:
                path = [.focusTableSelection] // Изменено: сначала идем на выбор таблицы
            case .survival:
                path = [.survival]
            case .rush:
                path = [.rush]
            }
        }

        func showResult(_ result: PracticeSession) {
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
