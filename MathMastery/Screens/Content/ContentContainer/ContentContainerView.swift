import SwiftUI

struct ContentContainerView: View {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject var serviceContainer: ServiceContainer

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)

        //        UITabBar.appearance().unselectedItemTintColor = UIColor(AppColor.commonBlack.opacity(0.6))
    }

    var body: some View {
        TabView(selection: $viewModel.contentViewType) {
            HomeView(viewModel: .init(serviceContainer: serviceContainer))
                .tabItem {
                    Label {
                        Text("Home")
                    } icon: {
                        Image("ic_tab_home")
                            .renderingMode(.template)
                    }
                }
                .tag(ContentViewType.home)

            LearnView(viewModel: .init(serviceContainer: serviceContainer))
                .tabItem {
                    Label {
                        Text("Learn")
                    } icon: {
                        Image("ic_tab_learn")
                            .renderingMode(.template)
                    }
                }
                .tag(ContentViewType.learn)

            PracticeView(viewModel: .init(serviceContainer: serviceContainer))
                .tabItem {
                    Label {
                        Text("Practice")
                    } icon: {
                        Image("ic_tab_practice")
                            .renderingMode(.template)
                    }
                }
                .tag(ContentViewType.practice)

            ProfileView(viewModel: .init(serviceContainer: serviceContainer))
                .tabItem {
                    Label {
                        Text("Profile")
                    } icon: {
                        Image("ic_tab_profile")
                            .renderingMode(.template)
                    }
                }
                .tag(ContentViewType.profile)
        }
        .tint(AppColor.commonAccentBlue)
//        .preferredColorScheme(.light)
//        .toast(serviceContainer: serviceContainer)
//        .progressIndicator(serviceContainer: serviceContainer)
    }
}

struct MainScreen_Preview: PreviewProvider {
    static let serviceContainer = PreviewServiceContainer()

    static var previews: some View {
        ContentContainerView(viewModel: .init(serviceContainer: serviceContainer))
            .environmentObject(serviceContainer as ServiceContainer)
    }
}
