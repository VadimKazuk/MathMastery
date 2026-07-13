import SwiftUI
import Charts

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
                    currentTargetCard
                    dailyChallengeCard
                    quickStartSection
                    activitySection
                }
                .padding(.horizontal, 16)
                .padding(.top, 22)
                .padding(.bottom, 24)
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Text("MathMastery")
//                        .font(.system(size: 28, weight: .bold, design: .rounded))
//                        .foregroundColor(AppColor.commonAccentBlue)
//                        .fixedSize()
//                }
//                .sharedBackgroundVisibility(.hidden)
//
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button {
//                        print("Profile tapped")
//                    } label: {
//                        Image(viewModel.avatarName)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 35, height: 35)
//                            .clipShape(Circle())
//                    }
//                }
//            }
//            .toolbarBackground(Color.white, for: .navigationBar)
        }
    }

    // MARK: - Subviews

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

            Button(action: viewModel.resumeSession) {
                HStack {
                    Spacer()
                    Image(systemName: "play.fill")
                    Text("Resume Session")
                    Spacer()
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding()
                .background(AppColor.commonAccentBlue)
                .cornerRadius(12)
            }
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

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity")
                .font(.system(size: 16, weight: .bold, design: .rounded))

            VStack(alignment: .leading, spacing: 16) {

                HStack {
                    Spacer()
                    Text("LAST 7 DAYS")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)
                        .tracking(0.5)
                }

                Chart(viewModel.weeklyActivity) { item in
                    BarMark(
                        x: .value("Day", item.date),
                        y: .value("Solved", item.value),
                        width: .fixed(12)
                    )
                    .foregroundStyle(
                        item.isCurrent
                            ? AppColor.commonAccentBlue
                            : Color(.systemGray5)
                    )
                }
                .chartXAxis {
                    AxisMarks(values: viewModel.weeklyActivity.map(\.date)) { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date.formatted(.dateTime.weekday(.narrow)))
                            }
                        }
                    }
                }
                .chartYAxis(.hidden)
                .frame(height: 140)
                .padding(.vertical, 8)

                Divider()
                    .background(Color(.systemGray6))

                HStack(alignment: .center) {
                    statItem(value: viewModel.solvedCount, label: "SOLVED")
                    Spacer()
                    statItem(value: viewModel.avgAccuracy, label: "AVG ACC")
                    Spacer()
                    statItem(value: viewModel.timePerDay, label: "TIME/DAY")
                }
                .padding(.top, 4)
            }
            .padding(20)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
        }
    }

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
            Text(label)
                .font(.system(size: 10, weight: .heavy))
                .foregroundColor(.secondary)
                .tracking(0.5)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    HomeView(viewModel: .init(serviceContainer: PreviewServiceContainer()))
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
                    .symbolEffect(.variableColor.iterative.reversing, options: .repeating)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 0.7)
                                .repeatForever(autoreverses: true)
                            ) {
                                scale = 1.08
                            }
                        }
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

#Preview {
    HomeView(viewModel: .init(serviceContainer: PreviewServiceContainer()))
}
