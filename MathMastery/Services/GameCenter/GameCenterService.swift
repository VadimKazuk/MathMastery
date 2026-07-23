import GameKit
import UIKit
import Combine

protocol GameCenterServiceProtocol: AnyObject {
    var isAuthenticated: Bool { get }
    var playerName: String? { get }
    var avatar: UIImage? { get }

    var playerNamePublisher: AnyPublisher<String?, Never> { get }
    var avatarPublisher: AnyPublisher<UIImage?, Never> { get }

    func authenticate()
    func showGameCenter()
}

final class GameCenterService: NSObject, GameCenterServiceProtocol, ObservableObject {

    @Published private(set) var isAuthenticated = false
    @Published private(set) var playerName: String?
    @Published private(set) var avatar: UIImage?

    private var isAuthenticating = false

    var playerNamePublisher: AnyPublisher<String?, Never> {
        $playerName.eraseToAnyPublisher()
    }

    var avatarPublisher: AnyPublisher<UIImage?, Never> {
        $avatar.eraseToAnyPublisher()
    }

    func authenticate() {
        guard !isAuthenticating else {
            return
        }

        if GKLocalPlayer.local.isAuthenticated {
            updatePlayer()
            return
        }

        isAuthenticating = true

        GKLocalPlayer.local.authenticateHandler = { [weak self] viewController, error in
            self?.isAuthenticating = false

            if let viewController {
                DispatchQueue.main.async {
                    guard let scene = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .first,
                        let root = scene.windows.first?.rootViewController
                    else {
                        return
                    }

                    root.present(viewController, animated: true)
                }
                return
            }

            if let error {
                print("Game Center error:", error.localizedDescription)
                return
            }

            self?.updatePlayer()
        }
    }

    private func updatePlayer() {
        DispatchQueue.main.async {
            self.isAuthenticated = true
            self.playerName = GKLocalPlayer.local.displayName
        }

        loadAvatar()
    }

    private func loadAvatar() {
        GKLocalPlayer.local.loadPhoto(for: .normal) { [weak self] image, error in
            if let error {
                print("Avatar error:", error.localizedDescription)
                return
            }

            DispatchQueue.main.async {
                self?.avatar = image
            }
        }
    }

    func showGameCenter() {
        guard GKLocalPlayer.local.isAuthenticated else {
            authenticate()
            return
        }

        GKAccessPoint.shared.trigger {
        }
    }
}
