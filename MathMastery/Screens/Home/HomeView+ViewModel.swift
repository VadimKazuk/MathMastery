import Combine
import SwiftUI


extension HomeView {
    final class ViewModel: ObservableObject {
        private let swiftDB: SwiftDataService
        private let serviceContainer: ServiceContainer
        private let accountService: AccountService

        private var cancellables = Set<AnyCancellable>()

        @Published var greetingName: String = "Alex"
        @Published var streakCount: Int = 12
        @Published var currentTargetTitle: String = "Focus Mode: x7"
        @Published var currentTargetSubtitle: String = "Mastering the 7 times table with speed drills."
        @Published var progressPercent: Double = 0.65
        @Published var drillsCompleted: Int = 13
        @Published var totalDrills: Int = 20

        private(set) var days: [WeeklyDay] = [
            WeeklyDay(day: "MON", status: .completed),
            WeeklyDay(day: "TUE", status: .completed),
            WeeklyDay(day: "WED", status: .completed),
            WeeklyDay(day: "THU", status: .current),
            WeeklyDay(day: "FRI", status: .locked),
            WeeklyDay(day: "SAT", status: .locked),
            WeeklyDay(day: "SUN", status: .reward)
        ]

        var avatarName: String {
            "img_profile_\(accountService.profile.avatarId)"
        }

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
            self.accountService = serviceContainer.resolve(AccountService.self)
            self.swiftDB = serviceContainer.resolve(SwiftDataService.self)
        }

        func resumeSession() {
            print("Resuming session...")
        }
    }
}
