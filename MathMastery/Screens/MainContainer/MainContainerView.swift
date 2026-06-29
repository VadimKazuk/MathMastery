import SwiftUI

struct MainContainerView: View {
    @StateObject var viewModel: ViewModel
    @EnvironmentObject var serviceContainer: ServiceContainer

    var body: some View {
        Group {
            switch viewModel.contentViewType {
            case .splash:
                SplashView()
                    .transition(.opacity)
            case .initial:
                SplashView()
//                InitialView(viewModel: .init(
//                    mainContentBinding: $viewModel.contentViewType
//                ))
//                .transition(.opacity)
//            case .signIn:
//                NavigationView {
//                    SignInView(viewModel: .init(serviceContainer: serviceContainer), goSignIn: .constant(false))
//                    .navigationBarTitleDisplayMode(.inline)
//                    .navigationBarBackButtonHidden(true)
//                }
//
//            case .signUp:
//                NavigationView {
//                    SignUpView(viewModel: .init(serviceContainer: serviceContainer), goSignUp: .constant(false))
//                    .navigationBarTitleDisplayMode(.inline)
//                    .navigationBarBackButtonHidden(true)
//                }
            case .home:
                ContentContainerView(viewModel: .init(serviceContainer: serviceContainer))
            }
        }
//        .preferredColorScheme(.light)
        
//        .alert(isPresented: $viewModel.showAlert) {
//            Alert(
//                title: Text("Are you still in the store?"),
//                primaryButton: .cancel(
//                    Text("No"),
//                    action: viewModel.checkOut
//                ),
//                secondaryButton: .default(
//                    Text("Yes"),
//                    action: viewModel.scheduleNotification
//                )
//            )
//        }
//        .animation(.easeInOut, value: viewModel.contentViewType)
    }
}


struct MainContainerView_Preview: PreviewProvider {
    static let previewServiceContainer = PreviewServiceContainer()

    static var previews: some View {
        MainContainerView(viewModel: .init(
            serviceContainer: previewServiceContainer
        ))
        .environmentObject(previewServiceContainer as ServiceContainer)
    }
}
