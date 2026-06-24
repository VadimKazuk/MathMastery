import SwiftUI

struct ProgressViewModifier: ViewModifier {
    @StateObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    if viewModel.isShowing {
                        Color.black.opacity(0.5).edgesIgnoringSafeArea(.all)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1)
                            .tint(.blue)
                    }
                },
                alignment: .center
            )
    }
}

extension View {
    func progressIndicator(serviceContainer: ServiceContainer) -> some View {
        self.modifier(ProgressViewModifier(viewModel: .init(serviceContainer: serviceContainer)))
    }
}
