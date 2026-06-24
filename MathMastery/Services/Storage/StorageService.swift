protocol StorageService {
    func write(data: Any?, key: String)
    func read(key: String) -> Any?
    func clear(key: String)
}
