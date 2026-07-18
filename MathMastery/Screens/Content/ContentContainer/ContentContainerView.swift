import SwiftUI

struct ContentContainerView: View {
    @StateObject var viewModel: ViewModel
    @StateObject private var tabBarVisibility = TabBarVisibility()
    @EnvironmentObject var serviceContainer: ServiceContainer

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $viewModel.contentViewType) {
                HomeView(viewModel: .init(serviceContainer: serviceContainer))
                    .toolbar(.hidden, for: .tabBar)
                    .tag(ContentViewType.home)
                LearnView(viewModel: .init(serviceContainer: serviceContainer))
                    .toolbar(.hidden, for: .tabBar)
                    .tag(ContentViewType.learn)
                PracticeView(viewModel: .init(serviceContainer: serviceContainer))
                    .toolbar(.hidden, for: .tabBar)
                    .tag(ContentViewType.practice)
                ProfileView(viewModel: .init(serviceContainer: serviceContainer))
                    .toolbar(.hidden, for: .tabBar)
                    .tag(ContentViewType.profile)
            }
            CustomTabBar(selection: $viewModel.contentViewType)
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: TabBarHeightKey.self, value: geo.size.height)
                    }
                )
                .offset(y: tabBarVisibility.isHidden ? 150 : 0)
                .opacity(tabBarVisibility.isHidden ? 0 : 1)
                .allowsHitTesting(!tabBarVisibility.isHidden)
        }
        .onPreferenceChange(TabBarHeightKey.self) { newHeight in
            tabBarVisibility.measuredHeight = newHeight
        }
        .environmentObject(tabBarVisibility)
    }
}

struct MainScreen_Preview: PreviewProvider {
    static let serviceContainer = PreviewServiceContainer()
    static var previews: some View {
        ContentContainerView(viewModel: .init(serviceContainer: serviceContainer))
            .environmentObject(serviceContainer as ServiceContainer)
    }
}
