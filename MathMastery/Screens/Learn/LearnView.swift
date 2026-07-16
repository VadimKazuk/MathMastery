import Combine
import SwiftUI

struct LearnView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel

    @StateObject private var gridContext = GridContext()

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    private var selection: GridSelectionController {
        gridContext.selection
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                contentView
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
        .onAppear {
            viewModel.loadSessions()
        }
    }
}

// MARK: - Content

private extension LearnView {
    var contentView: some View {
        VStack(alignment: .leading, spacing: 24) {
            modeControl
            tableCard
            equationCard
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
    }

    var modeControl: some View {
        Picker("Learning Mode", selection: Binding(
            get: { viewModel.mode },
            set: { newMode in
                withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                    viewModel.selectMode(newMode)
                }
            }
        )) {
            ForEach(LearnMode.allCases) { mode in
                Text(mode.title)
                    .tag(mode)
            }
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 2)
    }
    
    var tableCard: some View {
        MultiplicationGridView(
            grid: viewModel.grid,
            configuration: .learning,
            selection: selection,
            interaction: gridContext.interaction
        )
            .aspectRatio(1, contentMode: .fit)
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
            }
    }

    var equationCard: some View {
        VStack(spacing: 12) {

            Text(viewModel.equationTitle(selection: selection))
                .font(.system(size: 30, weight: .semibold, design: .rounded))
                .foregroundColor(AppColor.commonAccentBlue)

        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        }
    }

}

#Preview {
    LearnView(
        viewModel: .init(
            serviceContainer: PreviewServiceContainer()
        )
    )
}
