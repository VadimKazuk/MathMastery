import Foundation
import Combine

final class AppSettingsManager: ObservableObject {

    @Published var developerMode: Bool {
        didSet {
            storage.set(
                developerMode,
                forKey: Keys.developerMode
            )
        }
    }

    @Published var hapticFeedback: Bool {
        didSet {
            storage.set(
                hapticFeedback,
                forKey: Keys.hapticFeedback
            )
        }
    }

    private let storage: UserDefaults

    init(storage: UserDefaults = .standard) {

        self.storage = storage

        self.developerMode =
            storage.object(forKey: Keys.developerMode) as? Bool ?? false

        self.hapticFeedback =
            storage.object(forKey: Keys.hapticFeedback) as? Bool ?? true
    }

    func restoreDefaults() {
        developerMode = false
        hapticFeedback = true
    }

    private enum Keys {
        static let developerMode = "developerMode"
        static let hapticFeedback = "hapticFeedback"
    }
}
