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

        // Learning
        @Published var selectedRange: LearningRange = .x2_x10
        @Published var showCorrectAnswer = true

        // Practice
        @Published var hapticFeedback = true
        @Published var soundEffects = false
        @Published var autoStartPractice = true

        // Daily goal
        @Published var dailyGoal = 20


        init(serviceContainer: ServiceContainer) {
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
        }


        func clearProgress() {
            swiftDB.clearSessions()
        }


        func restoreDefaults() {

            selectedRange = .x2_x10
            showCorrectAnswer = true

            hapticFeedback = true
            soundEffects = false
            autoStartPractice = true

            dailyGoal = 20
        }
    }
}
