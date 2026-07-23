import SwiftUI
import Charts
import Combine

struct HomeView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel

    @Binding var selectedTab: ContentContainerView.ContentViewType

    let onStartPractice: (ImprovementAction) -> Void

    @State private var showChallengeRoulette = false

    init(
        viewModel: ViewModel,
        selectedTab: Binding<ContentContainerView.ContentViewType>,
        onStartPractice: @escaping (ImprovementAction) -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._selectedTab = selectedTab
        self.onStartPractice = onStartPractice
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    weeklyMilestoneCard
                    todaySummaryCard
                    dailyChallengeCard

                    if viewModel.improvement != nil {
                        improvementCard
                            .transition(
                                .opacity.combined(with: .move(edge: .bottom))
                            )
                    }
                }
                .animation(
                    .spring(response: 0.35, dampingFraction: 0.86),
                    value: viewModel.improvement != nil
                )
                .background(ScrollViewConfigurator())
                .padding(.horizontal, 16)
                .padding(.top, 22)
                .padding(.bottom, 100)
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .overlay {
                if showChallengeRoulette {
                    DailyChallengeRoulette(
                        isPresented: $showChallengeRoulette,
                        challenges: viewModel.pendingChallenges
                    )
                }
            }
            .onChange(of: showChallengeRoulette) { _, isPresented in
                if !isPresented {
                    viewModel.applyPendingChallenges()
                }
            }
            .onAppear {
                viewModel.loadProgressData()
            }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .practiceCompleted
                )
            ) { _ in
                viewModel.loadProgressData()
            }
        }
    }

    private func handleImprovement(
        _ action: ImprovementAction
    ) {
        viewModel.startImprovementPractice()
        onStartPractice(action)
    }

    // MARK: - Subviews

    private var weeklyMilestoneCard: some View {
        VStack(alignment: .leading, spacing: 20) {

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Weekly Milestone")
                        .font(.system(size: 22, weight: .bold, design: .rounded))

                    Text("Keep the momentum going!")
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 0) {

                    let streakLevel = viewModel.streakLevel

                    HStack(spacing: 4) {
                        Image(streakLevel.imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)

                        Text("\(viewModel.streakCount)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(streakLevel.color)
                    }
                }
            }

            HStack {
                ForEach(viewModel.days) { item in
                    WeeklyDayView(
                        day: item.day,
                        status: item.status
                    )
                }
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity)

            if !viewModel.hasCompletedToday {
                CommonButton(
                    title: "Complete Today's Goal",
                    action: {
                        selectedTab = .practice
                    }
                )
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
    }

    private var todaySummaryCard: some View {
        VStack(alignment: .center, spacing: 16) {
            HStack {
                Text("Today's Progress")
                    .font(.system(size: 16, weight: .bold, design: .rounded))

                Spacer()

                Text(viewModel.todayDateText)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(AppColor.commonAccentBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background {
                        Capsule()
                            .fill(AppColor.commonAccentBlue.opacity(0.1))
                    }
            }

            HStack(spacing: 12) {

                SummaryMetric(
                    value: "\(viewModel.todaySummary.questions)",
                    title: "Questions"
                )

                SummaryMetric(
                    value: "\(viewModel.todaySummary.accuracy)%",
                    title: "Accuracy"
                )

                SummaryMetric(
                    value: viewModel.todaySummary.formattedTime,
                    title: "Practice"
                )

                SummaryMetric(
                    value: "+\(viewModel.todaySummary.xp)",
                    title: "XP"
                )
            }

        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(24)
    }

    private var currentTargetCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("CURRENT TARGET")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(AppColor.commonAccentBlue)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(AppColor.commonAccentBlue.opacity(0.1))
                .cornerRadius(4)

            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.currentTargetTitle)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                Text(viewModel.currentTargetSubtitle)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 8) {
                HStack {
                    Text("\(Int(viewModel.progressPercent * 100))% Progress")
                        .font(.system(size: 13, weight: .medium))
                    Spacer()
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemGray5))
                        Capsule()
                            .fill(AppColor.commonAccentBlue)
                            .frame(width: geo.size.width * CGFloat(viewModel.progressPercent))
                    }
                }
                .frame(height: 8)
            }
            .padding(.vertical, 4)
            CommonButton(
                title: "Resume Session",
                action: {}
            )
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
    }

    private var dailyChallengeCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Daily Challenges")
                    .font(.system(size: 16, weight: .bold, design: .rounded))

                Spacer()

                Text(viewModel.challengeCountdown)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(AppColor.commonAccentBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background {
                        Capsule()
                            .fill(AppColor.commonAccentBlue.opacity(0.1))
                    }

            }

            ForEach(viewModel.challenges) { challenge in
                ChallengeRow(challenge: challenge)
            }

            if viewModel.shouldShowNewChallengesButton || viewModel.isDevMode() {
                CommonButton(
                    title: "Get New Challenges",
                    leftImage: "sparkles",
                    action: {
                        showChallengeRoulette = true
                    }
                )
            }

            if viewModel.isDevMode() {
                Button {
                    viewModel.generateNextDayChallengesForTest()
                } label: {
                    Text("Generate Next Day")
                        .font(.system(size: 14, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppColor.commonAccentBlue.opacity(0.15))
                        .foregroundColor(AppColor.commonAccentBlue)
                        .cornerRadius(12)
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(24)
    }

    private var improvementCard: some View {
        guard let improvement = viewModel.improvement else {
            return AnyView(EmptyView())
        }

        return AnyView(
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top) {
                    improvementHeader(for: improvement)

                    Spacer()

                    ZStack {
                        Image(improvementIconName(for: improvement))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .id(improvementIconName(for: improvement))
                            .transition(.scale.combined(with: .opacity))
                    }
                    .frame(width: 30, height: 30)
                    .animation(
                        .easeOut(duration: 0.25),
                        value: improvementIconName(for: improvement)
                    )
                }

                VStack(alignment: .leading, spacing: 8) {

                    HStack {
                        Text(improvement.metricTitle)

                        Spacer()

                        Text("\(viewModel.animatedImprovementPercentage)% / \(Int(improvement.targetValue * 100))%")
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 14, weight: .medium, design: .rounded))

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {

                            Capsule()
                                .fill(Color(.systemGray5))

                            Capsule()
                                .fill(AppColor.commonAccentBlue)
                                .frame(
                                    width: geo.size.width * viewModel.animatedImprovementProgress
                                )
                        }
                    }
                    .frame(height: 8)

                    Text("\(improvement.attempts) attempts • Goal \(Int(improvement.targetValue * 100))% accuracy")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(.secondary)
                }

                Group {
                    if isPracticeButtonVisible {
                        CommonButton(
                            title: "Practice \(improvement.focusTitle)",
                            action: {
                                handleImprovement(improvement.action)
                            }
                        )
                    }
                }
                .animation(
                    .spring(response: 0.45, dampingFraction: 0.82),
                    value: isPracticeButtonVisible
                )

            }
            .padding(20)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
        )
    }

    private func improvementHeader(
        for improvement: ImprovementRecommendation
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .leading) {
                Text(improvementHeaderTitle)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .id(improvementHeaderTitle)
                    .transition(.opacity)
            }
            .frame(height: 19, alignment: .leading)
            .animation(
                .easeInOut(duration: 0.2),
                value: improvementHeaderTitle
            )

            ZStack(alignment: .leading) {
                Text(improvementHeaderFocus(for: improvement))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .id(improvementHeaderFocus(for: improvement))
                    .transition(.opacity)
            }
            .frame(height: 33, alignment: .leading)
            .animation(
                .easeInOut(duration: 0.2),
                value: improvementHeaderFocus(for: improvement)
            )
        }
        .frame(height: 58, alignment: .topLeading)
    }

    private var improvementHeaderTitle: String {
        switch viewModel.improvementTransition {
        case .animatingCompletion, .none:
            return "Continue Improving"
        case .completed:
            return "Improved!"
        case .showingNext:
            return "New Goal!"
        }
    }

    private func improvementHeaderFocus(
        for improvement: ImprovementRecommendation
    ) -> String {
        switch viewModel.improvementTransition {
        case .animatingCompletion(let table), .completed(let table),
             .showingNext(let table):
            return "Focus ×\(table)"
        case .none:
            return improvement.focusTitle
        }
    }

    private func improvementIconName(
        for improvement: ImprovementRecommendation
    ) -> String {
        isCompletionReward ? "ic_check_milestone" : improvement.type.icon
    }

    private var isPracticeButtonVisible: Bool {
        if case .none = viewModel.improvementTransition {
            return true
        }
        return false
    }

    private var isCompletionReward: Bool {
        if case .completed = viewModel.improvementTransition {
            return true
        }
        return false
    }

}

struct WeeklyDayView: View {
    let day: String
    let status: DayStatus

    var body: some View {
        VStack(spacing: 10) {
            Text(day)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(textColor)

            ZStack {
                Image(iconName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
            }
        }
        .frame(width: 40)
        .padding(.vertical, 8)
        .background(pillBgColor)
        .clipShape(Capsule())
    }

    private var textColor: Color {
        status.textColor
    }

    private var pillBgColor: Color {
        status.pillBackground
    }

    private var pillBorderColor: Color {
        status.pillBorder
    }

    private var iconName: String {
        status.iconName
    }

    private var iconColor: Color {
        status.iconColor
    }
}

struct ChallengeRow: View {
    let challenge: DailyChallenge

    var body: some View {
        HStack(spacing: 16) {
            ProgressRing(
                progress: challenge.progress,
                color: challenge.color,
                lineWidth: 4,
                animated: challenge.shouldAnimate
            ) {
                if challenge.isCompleted {
                    Image(challenge.checkmark)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                } else {
                    Text("\(challenge.current)")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(challenge.color)
                }
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Image(challenge.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)

                    Text(challenge.title)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }

                Text(challenge.subtitle)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text("\(challenge.current)/\(challenge.target)")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.secondary)
        }
        .padding(3)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

struct SummaryMetric: View {

    let value: String
    let title: String

    var body: some View {
        VStack(spacing: 5) {

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))

            Text(title)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.secondary)

        }
        .frame(maxWidth: .infinity)
    }
}
