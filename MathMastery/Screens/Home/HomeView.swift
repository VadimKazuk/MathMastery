import SwiftUI

struct HomeView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {
        NavigationStack {
            ScrollView {

            }
            .background(Color(uiColor: .systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("MathMastery")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.commonAccentBlue)
                        .fixedSize()
                }
                .sharedBackgroundVisibility(.hidden)

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        print("Profile tapped")
                    } label: {
                        Image(viewModel.avatarName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 35, height: 35)
                            .clipShape(Circle())
                    }
                }
            }

            .toolbarBackground(Color.white, for: .navigationBar)
        }
    }

}

#Preview {
    HomeView(viewModel: .init(serviceContainer: PreviewServiceContainer()))
}
