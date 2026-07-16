import Combine
import Foundation


final class AccountService {
    @Published var user: User?
    @Published var uuid: String?
    @Published var profile: UserProfile = UserProfile()

    private let storageService: StorageService

    private let userDataKey = "AccountService:User"
    private let uuidDataKey = "AccountService:UUID"
    private let profileDataKey = "AccountService:Profile"

    private var subscriptions = Set<AnyCancellable>()

    var forceLogout: (() -> Void)?

    init(storageService: StorageService) {
        self.storageService = storageService

        if let data = storageService.read(key: userDataKey) as? Data,
           let user = try? JSONDecoder().decode(User.self, from: data) {
            self.user = user
        }

        if let data = storageService.read(key: uuidDataKey) as? Data,
           let uuid = try? JSONDecoder().decode(String.self, from: data) {
            self.uuid = uuid
        }

        if let data = storageService.read(key: profileDataKey) as? Data,
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = profile
        }

        $user
            .sink { [weak self] user in
                guard let self else { return }
                self.save(object: user, key: userDataKey)
            }
            .store(in: &subscriptions)

        $uuid
            .sink { [weak self] uuid in
                guard let self else { return }
                self.save(object: uuid, key: uuidDataKey)
            }
            .store(in: &subscriptions)

        $profile
            .sink { [weak self] profile in
                guard let self else { return }
                self.save(object: profile, key: profileDataKey)
            }
            .store(in: &subscriptions)
    }

    private func save(object: Codable?, key: String) {
        if let object = object {
            let data = try? JSONEncoder().encode(object)
            storageService.write(data: data, key: key)
        } else {
            storageService.clear(key: key)
        }
    }

    func addXP(_ xp: Int) {
        profile.totalXP += xp
    }

    func resetXP() {
        profile.totalXP = 0
    }
}

struct UserProfile: Codable {
    var name: String = ""
    var email: String = ""
    var age: String = ""
    var grade: String = ""
    var avatarId: Int = 1
    var totalXP: Int = 0
}

import Foundation

struct User {
    let id: String
    let email: String
    let name: String
}

// MARK: - Codable
extension User: Codable {
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case email = "Email"
        case name = "Name"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.email = try container.decode(String.self, forKey: .email)
        self.name = try container.decode(String.self, forKey: .name)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.email, forKey: .email)
        try container.encode(self.name, forKey: .name)
    }
}

// MARK: - MockProvider
extension User: MockProvider {
    static func mockObject() -> User {
        return User(
            id: UUID().uuidString,
            email: "john.doe@someemail.org",
            name: "John"
        )
    }

    static func mockObjects(count: Int) -> [User] {
        return []
    }
}

protocol MockProvider<T> {
    associatedtype T

    static func mockObject() -> T
    static func mockObjects(count: Int) -> [T]
}

extension MockProvider {
    static func mockObjects() -> [T] {
        return mockObjects(count: 10)
    }
}
