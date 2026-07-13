import Combine
import SwiftUI

struct LearnView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                contentView
            }
            .background(Color(uiColor: .systemGroupedBackground))
//            .toolbar {
//                leadingToolbarItem
//                profileToolbarItem
//            }
//            .toolbarBackground(Color.white, for: .navigationBar)
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

            if viewModel.isFocusMode {
                focusTableSection
            }

            if viewModel.isFocusMode {
                equationCard
            }
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

    var focusTableSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Set Focus Table")
                    .font(.system(size: 16, weight: .bold, design: .rounded))

                Spacer()

                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                        viewModel.toggleFocusPanel()
                    }
                } label: {
                    Image(systemName: viewModel.isFocusPanelVisible
                          ? "chevron.up"
                          : "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
                }
            }

            if viewModel.isFocusPanelVisible {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Column")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(Color.primary.opacity(0.7))
                    columnControl
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Row")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(Color.primary.opacity(0.7))
                    rowControl
                }
            }
        }
    }

    var rowControl: some View {
        Picker("Row", selection: Binding(
            get: { viewModel.selectedRow },
            set: { viewModel.setFocusTable($0) }
        )) {
            Text("×")
                .tag(nil as Int?)

            ForEach(viewModel.numbers, id: \.self) { number in
                Text("\(number)")
                    .tag(Optional(number))
            }
        }
        .pickerStyle(.segmented)
    }

    var columnControl: some View {
        Picker("Column", selection: Binding(
            get: { viewModel.selectedColumn },
            set: { viewModel.setColumn($0) }
        )) {
            Text("×")
                .tag(nil as Int?)

            ForEach(viewModel.numbers, id: \.self) { number in
                Text("\(number)")
                    .tag(Optional(number))
            }
        }
        .pickerStyle(.segmented)
    }

    var tableCard: some View {
        MultiplicationGridView(viewModel: viewModel)
            .aspectRatio(1, contentMode: .fit)
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
            }
    }

    var focusProgressBar: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Capsule()
                    .fill(AppColor.commonAccentBlue)
                    .frame(width: geo.size.width * 0.5)

                Capsule()
                    .fill(AppColor.commonAccentBlue)
            }
        }
        .frame(height: 7)
    }

    var equationCard: some View {
        HStack(spacing: 16) {
            equationArrow(systemName: "chevron.left") {
                viewModel.moveSelection(offset: -1)
            }

            VStack(spacing: 12) {
                Text("CURRENT EQUATION")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .tracking(2)
                    .foregroundColor(Color.primary.opacity(0.7))

                Text(viewModel.equationTitle)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColor.commonAccentBlue)

                Text(viewModel.equationAccuracyText)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color.primary.opacity(0.7))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background {
                        Capsule()
                            .fill(viewModel.currentEquationLevel.opacityСolor)
                    }
            }
            .frame(maxWidth: .infinity)

            equationArrow(systemName: "chevron.right") {
                viewModel.moveSelection(offset: 1)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 34)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        }
    }

    func equationArrow(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .bold))
                .frame(width: 40, height: 40)
        }
        .buttonStyle(.glass)
        .tint(AppColor.commonAccentBlue)
    }
}

// MARK: - Toolbar

private extension LearnView {
    var leadingToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Text("MathMastery")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(AppColor.commonAccentBlue)
                .fixedSize()
        }
        .sharedBackgroundVisibility(.hidden)
    }

    var profileToolbarItem: some ToolbarContent {
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
}


#Preview {
    LearnView(
        viewModel: .init(
            serviceContainer: PreviewServiceContainer()
        )
    )
}
