import SwiftUI
import Charts
import Combine

struct HomeView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
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
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
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

                    VStack(alignment: .center, spacing: 0) {
                        HStack {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.orange)
                            Text("\(viewModel.streakCount)")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(.orange)
                        }
                        Text("DAY STREAK")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.secondary)
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

            CommonButton(
                title: "Complete Today's Goal",
                action: viewModel.resumeSession
            )

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
                    Text("\(viewModel.drillsCompleted)/\(viewModel.totalDrills) Drills")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
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
                action: viewModel.resumeSession
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
                Text("Daily Challenge")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                Spacer()
                Text("24h REMAINING")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(AppColor.commonAccentBlue)
            }

            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.green.opacity(0.1), lineWidth: 4)
                    Circle()
                        .trim(from: 0, to: 12/20)
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("12")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(.green)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Solve 20 questions")
                        .font(.system(size: 15, weight: .semibold))
                    Text("8 more to reach your daily goal!")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }

    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Start")
                .font(.system(size: 16, weight: .bold, design: .rounded))

            HStack(spacing: 12) {
                QuickStartButton(title: "1-MIN SPRINT", icon: "timer", color: AppColor.commonAccentBlue)
                QuickStartButton(title: "RANDOM DRILL", icon: "shuffle", color: .purple)
                QuickStartButton(title: "Rush MODE", icon: "flame.fill", color: .orange)
            }
        }
    }
}

// MARK: - Supporting Components

enum DayStatus {
    case completed, current, locked, reward
}

struct WeeklyDay: Identifiable {
    let id = UUID()
    let day: String
    let status: DayStatus
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
                Circle()
                    .fill(circleBgColor)
                    .frame(width: 34, height: 34)

                Image(systemName: iconName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(iconColor)
            }
        }
        .frame(width: 40)
        .padding(.vertical, 8)
        .background(pillBgColor)
        .clipShape(Capsule())
        .shadow(color: status == .current ? AppColor.commonAccentBlue.opacity(0.25) : .clear, radius: 8, x: 0, y: 4)
    }

    private var textColor: Color {
        switch status {
        case .completed: return .green
        case .current: return AppColor.commonAccentBlue
        case .locked, .reward: return .secondary
        }
    }

    private var pillBgColor: Color {
        switch status {
        case .completed: return Color.green.opacity(0.06)
        case .current: return AppColor.commonAccentBlue
        case .locked, .reward: return Color(.systemGray6).opacity(0.5)
        }
    }

    private var pillBorderColor: Color {
        switch status {
        case .completed: return Color.green.opacity(0.15)
        default: return Color(.systemGray4).opacity(0.3)
        }
    }

    private var circleBgColor: Color {
        switch status {
        case .completed: return .green
        case .current: return .white
        case .locked, .reward: return Color(.systemGray5)
        }
    }

    private var iconColor: Color {
        switch status {
        case .completed: return .white
        case .current: return AppColor.commonAccentBlue
        case .locked, .reward: return .secondary
        }
    }

    private var iconName: String {
        switch status {
        case .completed: return "checkmark"
        case .current: return "star.fill"
        case .locked: return "lock.fill"
        case .reward: return "trophy.fill"
        }
    }
}

struct QuickStartButton: View {
    let title: String
    let icon: String
    let color: Color
    var isBordered: Bool = false

    @State private var scale = 1.0

    var body: some View {
        Button(action: {}) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(isBordered ? Color.clear : color.opacity(0.1))
                    .clipShape(Circle())

                Text(title)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isBordered ? color.opacity(0.3) : Color.clear, lineWidth: 1)
            )
        }
    }
}

struct BounceOnTap: ViewModifier {
    @State private var scale: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        guard scale == 1 else { return }
                        withAnimation(.easeOut(duration: 0.08)) {
                            scale = 0.94
                        }
                    }
                    .onEnded { _ in
                        withAnimation(.spring(response: 0.22, dampingFraction: 0.45)) {
                            scale = 1.05
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            withAnimation(.spring(response: 0.2, dampingFraction: 0.75)) {
                                scale = 1
                            }
                        }
                    }
            )
    }
}
