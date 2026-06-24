import Foundation

final class MemoryStorageService {
    private var cache: [String: Any?] = [:]
}

// MARK: - Storage
extension MemoryStorageService: StorageService {
    func write(data: Any?, key: String) {
        cache[key] = data
    }

    func read(key: String) -> Any? {
        return cache[key] ?? nil
    }

    func clear(key: String) {
        cache.removeValue(forKey: key)
    }
}
