import Combine
import Foundation

final class CountdownTimer: ObservableObject {

    @Published private(set) var text: String?

    private var cancellable: AnyCancellable?

    func start(
        from value: Int = 3,
        completion: @escaping () -> Void
    ) {
        stop()

        var current = value
        text = "\(current)"

        cancellable = Timer
            .publish(
                every: 1,
                on: .main,
                in: .common
            )
            .autoconnect()
            .sink { [weak self] _ in

                guard let self else {
                    return
                }

                if current > 1 {
                    current -= 1
                    self.text = "\(current)"
                } else {
                    self.text = "GO!"
                    self.stop()

                    DispatchQueue.main.asyncAfter(
                        deadline: .now() + 0.7
                    ) {
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
