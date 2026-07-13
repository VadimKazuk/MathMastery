import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    let name: String
    let loop: Bool
    var completion: (() -> Void)? = nil

    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name)

        view.loopMode = loop ? .loop : .playOnce
        view.contentMode = .scaleAspectFit
        view.backgroundBehavior = .pauseAndRestore
        view.animationSpeed = 1

        view.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
        view.setContentCompressionResistancePriority(.fittingSizeLevel, for: .vertical)

        view.play { finished in
            if finished {
                completion?()
            }
        }

        return view
    }

    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}
//           use this
//LottieView(name: mode.lottieImage, loop: true)
//    .frame(width: 56, height: 56)
