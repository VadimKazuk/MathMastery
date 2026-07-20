import Combine
import Foundation

protocol CountdownService: AnyObject {
    var text: String? { get }
    var objectWillChange: ObservableObjectPublisher { get }

    func start(
        from value: Int,
        completion: @escaping () -> Void
    )

    func stop()
}

final class CountdownManager: CountdownService, ObservableObject {

    let objectWillChange = ObservableObjectPublisher()

    private var cancellable: AnyCancellable?

    private(set) var text: String? {
        didSet {
            objectWillChange.send()
        }
    }

    func start(
        from value: Int = 3,
        completion: @escaping () -> Void
    ) {
        cancellable?.cancel()

        var current = value
        text = "\(current)"

        cancellable = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self else { return }

                if current > 1 {
                    current -= 1
                    self.text = "\(current)"
                } else {
                    self.text = "GO!"

                    self.cancellable?.cancel()
                    self.cancellable = nil

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                        self.text = nil
                        completion()
                    }
                }
            }
    }

    func stop() {
        cancellable?.cancel()
        cancellable = nil
        text = nil
    }
}
