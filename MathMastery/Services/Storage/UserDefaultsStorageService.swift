import Foundation

final class UserDefaultsStorageService {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
}

// MARK: - Storage
extension UserDefaultsStorageService: StorageService {
    func write(data: Any?, key: String) {
        defaults.set(data, forKey: key)
    }

    func read(key: String) -> Any? {
        return defaults.object(forKey: key)
    }

    func clear(key: String) {
        defaults.removeObject(forKey: key)
    }
}
