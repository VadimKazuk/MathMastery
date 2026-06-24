import SwiftUI

struct ContentContainerView: View {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject var serviceContainer: ServiceContainer

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)

        //        UITabBar.appearance().unselectedItemTintColor = UIColor(AppColor.commonBlack.opacity(0.6))
    }

    var body: some View {
        NavigationView {
            TabView(selection: $viewModel.contentViewType) {
                LearnView(viewModel: .init(serviceContainer: serviceContainer))
                    .tabItem {
                        Label {
                            Text("Learn")
                        } icon: {
                            Image("ic_tab_learn_black")
                                .renderingMode(.template)
                        }
                    }
                    .tag(ContentViewType.home)

                PracticeView(viewModel: .init(serviceContainer: serviceContainer))
                    .tabItem {
                        Label {
                            Text("Practice")
                        } icon: {
                            Image("ic_tab_practice_black")
                                .renderingMode(.template)
                        }
                    }
                    .tag(ContentViewType.practice)
            }
            .tint(AppColor.commonAccentBlue)
            .onOpenURL(perform: { url in

            })
        }
        .preferredColorScheme(.light)
        .toast(serviceContainer: serviceContainer)
        .progressIndicator(serviceContainer: serviceContainer)
    }
}

struct MainScreen_Preview: PreviewProvider {
    static let serviceContainer = PreviewServiceContainer()

    static var previews: some View {
        ContentContainerView(viewModel: .init(serviceContainer: serviceContainer))
            .environmentObject(serviceContainer as ServiceContainer)
    }
}
