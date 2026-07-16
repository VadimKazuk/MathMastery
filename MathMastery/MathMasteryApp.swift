import SwiftUI
import SwiftData

@main
struct MathMasteryApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var serviceContainer: ServiceContainer = DefaultServiceContainer()

    var body: some Scene {
        WindowGroup {
            MainContainerView(
                viewModel: MainContainerView.ViewModel(
                    serviceContainer: serviceContainer
                )
            )
            .environmentObject(serviceContainer)
            .onAppear {
                self.delegate.serviceContainer = serviceContainer

                serviceContainer
                    .resolve(GameCenterServiceProtocol.self)
                    .authenticate()
            }
            .preferredColorScheme(.light)
        }
    }
}

