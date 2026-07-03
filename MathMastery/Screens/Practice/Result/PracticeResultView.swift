import SwiftUI

struct PracticeResultView: View {
    @StateObject var viewModel: ViewModel

    let retryAction: (() -> Void)?
    let switchModeAction: (() -> Void)?
    let hubAction: (() -> Void)?

    init(
        viewModel: ViewModel,
        retryAction: (() -> Void)? = nil,
        switchModeAction: (() -> Void)? = nil,
        hubAction: (() -> Void)? = nil
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.retryAction = retryAction
        self.switchModeAction = switchModeAction
        self.hubAction = hubAction
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                hero
                metricsGrid
                mistakesSection
                actions
            }
            .padding(.horizontal, 22)
            .padding(.top, 26)
            .padding(.bottom, 28)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var hero: some View {
        VStack(spacing: 16) {
            Image(systemName: viewModel.session.mode.systemImage)
                .font(.system(size: 42, weight: .semibold))
                .foregroundColor(viewModel.session.mode.accentColor)
                .frame(width: 92, height: 92)
                .background {
                    Circle()
                        .fill(viewModel.session.mode.backgroundColor)
                }

            VStack(spacing: 8) {
                Text(viewModel.title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                Text(viewModel.summary)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(Color.primary.opacity(0.68))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 5)
        }
    }

    private var metricsGrid: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ],
            spacing: 12
        ) {
            ForEach(viewModel.metrics) { metric in
                VStack(spacing: 8) {
                    Text(metric.value)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.commonAccentBlue)
                    Text(metric.title)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .tracking(1.1)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 96)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                }
            }
        }
    }

    @ViewBuilder
    private var mistakesSection: some View {
        if !viewModel.mistakes.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text(viewModel.mistakeTitle)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                ForEach(viewModel.mistakes) { mistake in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(mistake.question)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundColor(.primary)

                        HStack(spacing: 6) {
                            Text("Your:")
                                .foregroundColor(.secondary)
                            Text("\(mistake.userAnswer)")
                                .foregroundColor(.red)
                            Spacer()
                            Text("Correct:")
                                .foregroundColor(.secondary)
                            Text("\(mistake.correctAnswer)")
                                .foregroundColor(.green)
                        }
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var actions: some View {
        VStack(spacing: 12) {

            if let retryAction {
                Button(action: retryAction) {
                    Text("Retry \(viewModel.session.mode.title)")
                        .font(.system(size: 19, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 58)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(AppColor.commonAccentBlue)
                        }
                }
                .buttonStyle(.plain)
            }

            if let switchModeAction {
                Button(action: switchModeAction) {
                    Text("Switch Mode")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.commonAccentBlue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        }
                }
                .buttonStyle(.plain)
            }

            if let hubAction {
                Button(action: hubAction) {
                    Text("Return to Practice Hub")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(Color.primary.opacity(0.68))
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
