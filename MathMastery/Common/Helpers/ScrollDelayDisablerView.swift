import SwiftUI

// MARK: - Disable ScrollView touch delay
final class ScrollDelayDisablerView: UIView {

    override func didMoveToWindow() {
        super.didMoveToWindow()
        disableScrollDelay()
    }

    private func disableScrollDelay() {
        var currentView: UIView? = self

        while let view = currentView {
            if let scrollView = view as? UIScrollView {
                scrollView.delaysContentTouches = false
                scrollView.canCancelContentTouches = true
                return
            }

            currentView = view.superview
        }
    }
}

struct ScrollViewConfigurator: UIViewRepresentable {

    func makeUIView(context: Context) -> ScrollDelayDisablerView {
        let view = ScrollDelayDisablerView()

        // не блокируем жесты
        view.isUserInteractionEnabled = false
        view.backgroundColor = .clear

        return view
    }

    func updateUIView(_ uiView: ScrollDelayDisablerView, context: Context) {}
}
