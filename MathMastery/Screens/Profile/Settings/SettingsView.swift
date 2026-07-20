import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel
    @State private var showExitModal = false

    @Environment(\.dismiss) private var dismiss

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {

            header

            ScrollView {
                VStack(spacing: 18) {
                    learningSection
                    practiceSection
                    dailyGoalSection
                    dataSection
                    aboutSection
                }
                .background(ScrollViewConfigurator())
                .padding()
                .padding(.bottom, 30)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .overlay {
            exitOverlay
                .animation(.easeInOut(duration: 0.2), value: showExitModal)
        }
    }

    private var header: some View {
        HStack {

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(width: 42, height: 42)
                    .background(
                        Circle()
                            .fill(Color.white)
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Settings")
                .font(.system(size: 22, weight: .bold, design: .rounded))

            Spacer()

            Color.clear
                .frame(width: 42, height: 42)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var learningSection: some View {
        SettingsCard(title: "Learning") {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Difficulty")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))

                    DepthSegmentedPicker(
                        items: LearningRange.allCases,
                        selection: $viewModel.selectedRange
                    ) {
                        $0.rawValue
                    }
                }

                toggleRow(
                    title: "Show correct answer",
                    value: $viewModel.showCorrectAnswer,
                    onImage: "ic_eye_on",
                    offImage: "ic_eye_off"
                )
            }
        }
    }

    private var practiceSection: some View {
        SettingsCard(title: "Practice") {
            VStack(spacing: 16) {
                toggleRow(
                    title: "Haptic Feedback",
                    value: $viewModel.hapticFeedback,
                    onImage: "ic_haptic_on",
                    offImage: "ic_haptic_off"
                )

                toggleRow(
                    title: "Sound Effects",
                    value: $viewModel.soundEffects,
                    onImage: "ic_sound_on",
                    offImage: "ic_sound_off"
                )

                toggleRow(
                    title: "Auto Start Practice",
                    value: $viewModel.autoStartPractice,
                    onImage: "ic_power_on",
                    offImage: "ic_power_off"
                )
            }
        }
    }

    private var dailyGoalSection: some View {
        SettingsCard(title: "Daily Goal") {
            VStack(alignment: .leading, spacing: 8) {
                Text("Questions per day")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))

                DepthSegmentedPicker(
                    items: [10,20,30,50],
                    selection: $viewModel.dailyGoal
                ) {
                    "\($0)"
                }
            }
        }
    }

    private var dataSection: some View {
        SettingsCard(title: "Data") {
            VStack(spacing: 14) {
                actionRow(
                    title: "Reset Progress",
                    icon: "ic_trash_bin",
                    color: .red
                ) {
                    showExitModal = true
                }

                actionRow(
                    title: "Restore Defaults",
                    icon: "ic_arrow_rotate",
                    color: AppColor.commonAccentBlue
                ) {
                    viewModel.restoreDefaults()
                }
            }
        }
    }

    private var aboutSection: some View {
        SettingsCard(title: "About") {
            VStack(alignment: .leading, spacing: 14) {
                NavigationLink {
                    Text("About MathMastery")
                } label: {
                    Text("About MathMastery")
                }

                NavigationLink {
                    Text("Privacy Policy")
                } label: {
                    Text("Privacy Policy")
                }

                NavigationLink {
                    Text("Contact Support")
                } label: {
                    Text("Contact Support")
                }

                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.2.0")
                        .foregroundColor(.secondary)
                }
            }
            .font(.system(size: 16, weight: .regular, design: .rounded))
        }
    }

    private func toggleRow(
        title: String,
        value: Binding<Bool>,
        onImage: String,
        offImage: String
    ) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))

            Spacer()

            DepthToggle(
                value: value,
                onImage: onImage,
                offImage: offImage
            )
        }
    }

    private func actionRow(
        title: String,
        icon: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold, design: .rounded))

            Spacer()

            Button {
                action()
            } label: {
                Image(icon)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .frame(width: 42, height: 36)
            }
            .buttonStyle(
                DepthButtonStyle(
                    backgroundColor: color,
                    cornerRadius: 12,
                    depth: 5
                )
            )
            .foregroundColor(.white)
        }
    }

    @ViewBuilder
    private var exitOverlay: some View {
        if showExitModal {
            ZStack {
                Color.black.opacity(0.32)
                    .ignoresSafeArea()
                    .onTapGesture {
                        showExitModal = false
                    }

                VStack(spacing: 20) {
                    Text("Reset Progress?")
                        .font(.system(size: 22, weight: .bold, design: .rounded))

                    Text("All practice history, statistics and achievements will be deleted.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 12) {
                        Button {
                            showExitModal = false
                        } label: {
                            Text("Cancel")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                        .buttonStyle(
                            DepthButtonStyle(
                                backgroundColor: Color(.systemGray5),
                                cornerRadius: 14,
                                depth: 5
                            )
                        )
                        .foregroundColor(AppColor.commonAccentBlue)

                        Button {
                            showExitModal = false
                            viewModel.clearProgress()
                        } label: {
                            Text("Reset")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                        .buttonStyle(
                            DepthButtonStyle(
                                backgroundColor: .red,
                                cornerRadius: 14,
                                depth: 5
                            )
                        )
                        .foregroundColor(.white)
                    }
                }
                .padding(24)
                .frame(width: 320)
                .background {
                    RoundedRectangle(
                        cornerRadius: 24,
                        style: .continuous
                    )
                    .fill(Color(.systemBackground))
                }
            }
        }
    }
}

struct SettingsCard<Content: View>: View {
    let title: String
    let content: Content

    init(
        title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 16, weight: .bold, design: .rounded))


            VStack(spacing: 14) {
                content
            }
            .padding(16)
            .background {
                RoundedRectangle(
                    cornerRadius: 22,
                    style: .continuous
                )
                .fill(Color.white)
            }
        }
    }
}

#Preview {
    SettingsView(
        viewModel: .init(
            serviceContainer: PreviewServiceContainer()
        )
    )
}
