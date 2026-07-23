import SwiftUI
import Combine

enum LearningRange: String, CaseIterable, Identifiable {
    case x2_x5 = "x2-x5"
    case x2_x10 = "x2-x10"

    var id: String { rawValue }
}


extension SettingsView {

    final class ViewModel: ObservableObject {

        private let swiftDB: SwiftDataService
        private let appSettings: AppSettingsManager

        // Learning
        @Published var selectedRange: LearningRange = .x2_x10
        @Published var showCorrectAnswer = true

        // Practice

        @Published var soundEffects = false
        @Published var autoStartPractice = true

        // Daily goal
        @Published var dailyGoal = 20

        private var cancellables = Set<AnyCancellable>()


        init(serviceContainer: ServiceContainer) {
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
            self.appSettings = serviceContainer.resolve(AppSettingsManager.self)

            appSettings.objectWillChange
                .sink { [weak self] _ in
                    self?.objectWillChange.send()
                }
                .store(in: &cancellables)
        }
// dev
        func setDeveloperMode(_ value: Bool) {
            appSettings.developerMode = value
        }

        var developerMode: Binding<Bool> {
            Binding(
                get: {
                    self.appSettings.developerMode
                },
                set: {
                    self.appSettings.developerMode = $0
                }
            )
        }

        func hapticFeedbackBinding() -> Binding<Bool> {
            Binding(
                get: {
                    self.appSettings.hapticFeedback
                },
                set: {
                    self.appSettings.hapticFeedback = $0
                }
            )
        }

        func clearProgress() {
            swiftDB.clearSessions()
        }

        func restoreDefaults() {

            appSettings.restoreDefaults()
        }
    }
}
