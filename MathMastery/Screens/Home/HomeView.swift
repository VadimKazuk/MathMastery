import SwiftUI

struct HomeView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer

    @StateObject var viewModel: ViewModel

    @State private var isSheetPresented: Bool = {
        let hasBeenPresented = UserDefaults.standard.bool(forKey: "hasPresentedSheet")
        return !hasBeenPresented
    }()

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
//            Color(red: 250/255, green: 249/255, blue: 254/255)
            Color.red
                .ignoresSafeArea()

        }
    }
}


#Preview {
    HomeView(viewModel: .init(serviceContainer: PreviewServiceContainer()))
}



