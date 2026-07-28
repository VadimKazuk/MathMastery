import SwiftUI

struct PracticeView: View {

    @EnvironmentObject var serviceContainer: ServiceContainer

    @StateObject var viewModel: ViewModel
    let onStartMode: (PracticeMode) -> Void

    init(
        viewModel: ViewModel,
        onStartMode: @escaping (PracticeMode) -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onStartMode = onStartMode
    }

    var body: some View {
        ScrollView {
            contentView
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 24)
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }
}


// MARK: - Content

private extension PracticeView {

    var contentView: some View {
        VStack(alignment: .leading, spacing: 24) {
            modesList
        }
        .background(
            ScrollViewConfigurator()
        )
    }

    var modesList: some View {
        VStack(spacing: 16) {
            ForEach(viewModel.modes) { mode in
                practiceModeCard(mode)
            }
        }
    }

    func practiceModeCard(_ mode: PracticeMode) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {

                    Text(mode.title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))

                    Text(mode.subtitle)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                HStack(spacing: 4) {

                    LottieView(name: mode.lottieImage, loop: true)
                        .id(mode.lottieImage)
                        .frame(width: 30, height: 30)

                    Text("Skill: \(mode.trainingFocus)")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                }
                .foregroundColor(mode.accentColor)
            }

            Spacer()

            VStack(alignment: .trailing) {

                Text(mode.timeTag)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray6))
                    .cornerRadius(6)

                Spacer()

                Button {
                    onStartMode(mode)
                } label: {
                    Image("ic_play")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .frame(width: 60, height: 42)
                }
                .buttonStyle(
                    DepthButtonStyle(
                        backgroundColor: AppColor.commonAccentBlue,
                        cornerRadius: 14,
                        depth: 5,
                        borderWidth: 1
                    )
                )
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
    }
}
