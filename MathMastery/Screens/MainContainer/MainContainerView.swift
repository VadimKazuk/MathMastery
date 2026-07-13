import SwiftUI

struct MainContainerView: View {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject var serviceContainer: ServiceContainer

    private var gameCenter: GameCenterServiceProtocol {
        serviceContainer.resolve(GameCenterServiceProtocol.self)
    }

    var body: some View {
        Group {
            switch viewModel.contentViewType {

            case .splash:
                SplashView(
                    state: viewModel.splashState
                ) {
                    withAnimation {
                        viewModel.contentViewType = .home
                    }
                }

            case .initial:
                VStack(spacing: 20) {

                    if let avatar = gameCenter.avatar {

                        Image(uiImage: avatar)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())

                    } else {

                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray)
                    }

                    Text(gameCenter.playerName ?? "No player")
                        .font(.title3.bold())

                    Text(
                        gameCenter.isAuthenticated
                        ? "Game Center Connected"
                        : "Not Connected"
                    )
                    .foregroundStyle(
                        gameCenter.isAuthenticated ? .green : .red
                    )
                }

            case .home:
                ContentContainerView(
                    viewModel: .init(
                        serviceContainer: serviceContainer
                    )
                )
            }
        }
    }
}


struct MainContainerView_Preview: PreviewProvider {

    static let previewServiceContainer = PreviewServiceContainer()

    static var previews: some View {

        MainContainerView(
            viewModel: MainContainerView.ViewModel(
                serviceContainer: previewServiceContainer
            )
        )
        .environmentObject(
            previewServiceContainer as ServiceContainer
        )
    }
}
