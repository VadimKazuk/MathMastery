import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    let loop: Bool

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name)

        view.loopMode = loop ? .loop : .playOnce
        view.contentMode = .scaleAspectFit   // 🔥 ВАЖНО
        view.backgroundBehavior = .pauseAndRestore
        view.animationSpeed = 1
        view.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        view.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)

        view.play()
        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
