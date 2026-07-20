import SwiftUI
import Charts
import Combine

struct HomeView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel
    @Binding var selectedTab: ContentContainerView.ContentViewType

    init(viewModel: ViewModel, selectedTab: Binding<ContentContainerView.ContentViewType>) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self._selectedTab = selectedTab
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    weeklyMilestoneCard
                    dailyChallengeCard
                    currentTargetCard
                }
                .background(ScrollViewConfigurator())
                .padding(.horizontal, 16)
                .padding(.top, 22)
                .padding(.bottom, 100)
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .onAppear {
                viewModel.loadProgressData()
            }
        }
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

                Text("24h REMAINING")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColor.commonAccentBlue)
            }

            ForEach(viewModel.challenges) { challenge in
                ChallengeRow(challenge: challenge)
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(24)
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
                HStack {
                    Image(challenge.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15, height: 15)
                    Text("\(challenge.title)")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }

                Text(
                    challenge.isCompleted
                    ? "Completed!"
                    : "\(challenge.remaining) remaining"
                )
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(.secondary)
            }

            Spacer()
            if challenge.isCompleted {
                Text("\(challenge.current)/\(challenge.target)")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundColor(.secondary)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
        .padding(3)
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}

