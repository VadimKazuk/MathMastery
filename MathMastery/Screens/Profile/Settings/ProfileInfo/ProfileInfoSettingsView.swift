import SwiftUI

struct ProfileInfoSettingsView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    var body: some View {

    }

}

#Preview {
    ProfileInfoSettingsView(viewModel: .init(serviceContainer: PreviewServiceContainer()))
}

import Combine
import SwiftUI

extension ProfileInfoSettingsView {
    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private var cancellables = Set<AnyCancellable>()

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer

        }

    }
}
