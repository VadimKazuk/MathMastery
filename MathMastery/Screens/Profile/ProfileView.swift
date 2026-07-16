import SwiftUI
import Charts

struct ProfileView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel

    @State private var selectedSession: PracticeSession?

    @AppStorage("lastShownXP") private var lastXP = 0
    @State private var animatedProgress: Double = 0
    @State private var displayedXP = 0

    @State private var animateXP = false

    @StateObject private var heatmapSelection = GridSelectionController()
    @StateObject private var heatmapInteraction = GridInteractionController()

    @State private var expandedMenu: ProfileMenu?

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    profileHeader
                    personalBestsSection
                    activitySection
                    learningHeatmapSection
                    recentSessionsPreview


                    NavigationLink {
                        HistoryListView(
                            viewModel: .init(serviceContainer: serviceContainer)
                        )
                        .toolbar(.hidden, for: .tabBar)
                    } label: {
                        HStack {
                            Text("View Full History")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                        }
                        .foregroundColor(.white)
                        .frame(height: 42)
                        .padding(.horizontal, 20)
                    }
                    .buttonStyle(DeptButtonStyle())
                }
                .background(ScrollViewConfigurator())
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .sheet(item: $selectedSession) { session in
                PracticeResultView(
                    viewModel: .init(
                        serviceContainer: serviceContainer,
                        session: session,
                        isPersonalBest: viewModel.isBest(session)
                    )
                )
            }
        }
        .onAppear {
            viewModel.loadSessions()

            let currentXP = viewModel.totalXP

            if lastXP < currentXP {

                displayedXP = lastXP
                animatedProgress = viewModel.progress(for: lastXP)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    animateXP = true

                    withAnimation(.easeOut(duration: 1.0)) {
                        displayedXP = currentXP
                        animatedProgress = viewModel.levelProgress
                    }
                }

                lastXP = currentXP

            } else {

                displayedXP = currentXP
                animatedProgress = viewModel.levelProgress

                DispatchQueue.main.async {
                    animateXP = true
                }
            }
        }
    }

    // MARK: - Header
    private var profileHeader: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                Group {
                    if let avatar = viewModel.profileImage {
                        Image(uiImage: avatar)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "person.crop.circle")
                            .resizable()
                            .scaledToFill()
                            .foregroundColor(.gray.opacity(0.7))
                    }
                }
                .frame(width: 72, height: 72)
                .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.profileName)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Button {
                        viewModel.openGameCenter()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "gamecontroller.fill")
                            Text("Game Center")
                        }
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(8)
                    }
                    .buttonStyle(
                        DeptButtonStyle(
                            backgroundColor: AppColor.commonAccentBlue,
                            cornerRadius: 6,
                            depth: 3
                        )
                    )
                }

                Spacer()

                NavigationLink {
                    SettingsView(viewModel: .init(serviceContainer: serviceContainer))
                        .toolbar(.hidden, for: .tabBar)
                } label: {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(width: 60, height: 42)
                }
                .buttonStyle(DeptButtonStyle())
            }

            VStack(spacing: 8) {
                HStack {
                    Label {
                        Text("LEVEL \(viewModel.level)")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundColor(.blue)
                    } icon: {
                        Image(systemName: "bolt.shield.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                            .symbolEffect(.pulse.byLayer, options: .repeating)
                    }

                    Spacer()

                    HStack(spacing: 3) {
                        Text("\(displayedXP)")
                            .contentTransition(.numericText())
                            .animation(
                                animateXP ? .easeOut(duration: 1) : nil,
                                value: displayedXP
                            )

                        Text("/ \(viewModel.nextLevelXP) XP")
                    }
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemGray6))
                            .frame(height: 8)

                        Capsule()
                            .fill(AppColor.commonAccentBlue)
                            .frame(
                                width: geo.size.width * animatedProgress,
                                height: 8
                            )
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.03), radius: 12, x: 0, y: 6)

    }

    private var personalBestsSection: some View {
        HStack(spacing: 14) {
            PersonalBestCard(
                title: "SPEED",
                mode: .speed,
                icon: "bolt.fill",
                iconColor: .orange,
                session: viewModel.bestSpeed
            ) {
                selectedSession = $0
            }

            PersonalBestCard(
                title: "SURVIVAL",
                mode: .survival,
                icon: "heart.fill",
                iconColor: .red,
                session: viewModel.bestSurvival
            ) {
                selectedSession = $0
            }

            PersonalBestCard(
                title: "RUSH",
                mode: .rush,
                icon: "flame.fill",
                iconColor: .orange,
                session: viewModel.bestRush
            ) {
                selectedSession = $0
            }
        }
    }

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity")
                .font(.system(size: 16, weight: .bold, design: .rounded))

            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 8) {

                    DropdownMenu(
                        id: .mode,
                        icon: "line.3.horizontal.decrease.circle",
                        selection: $viewModel.selectedMode,
                        expandedMenu: $expandedMenu
                    )

                    DropdownMenu(
                        id: .metric,
                        icon: "chart.bar",
                        selection: $viewModel.selectedMetric,
                        expandedMenu: $expandedMenu
                    )

                    DropdownMenu(
                        id: .range,
                        icon: "calendar",
                        selection: $viewModel.selectedRange,
                        expandedMenu: $expandedMenu
                    )
                }
                .zIndex(10)

                Chart(viewModel.chartPoints) { point in
                    let visualValue = max(point.value, 1)

                    BarMark(
                        x: .value("Day", point.date),
                        y: .value(viewModel.selectedMetric.title, visualValue),
                        width: .fixed(
                            viewModel.selectedRange == .last7Days ? 12 : 6
                        )
                    )
                    .cornerRadius(4)
                    .foregroundStyle(
                        point.value == 0
                        ? Color(.systemGray6)
                        : (point.isCurrent ? AppColor.commonAccentBlue : Color(.systemGray4))
                    )
                }
                .chartXAxis {
                    AxisMarks(
                        values: viewModel.xAxisDates
                    ) { value in

                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(
                                    viewModel.selectedRange.xAxisLabel(for: date)
                                )
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .trailing) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel {
                            if let number = value.as(Double.self) {
                                Text(viewModel.formatYAxis(number))
                                    .font(.system(size: 10, weight: .medium, design: .monospaced)) // ← важно!
                                    .foregroundColor(.secondary)
                                    .frame(width: 25, alignment: .leading) // фиксированная ширина
                                    .multilineTextAlignment(.leading)
                            }
                        }
                    }
                }
                .chartYScale(domain: viewModel.yDomain)
                .chartPlotStyle { plotArea in
                    plotArea
                        .frame(maxWidth: .infinity)
                }
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .padding(.leading, 8)
                .padding(.top, 4)

                Divider()
                    .background(Color(.systemGray6))

                HStack(alignment: .center) {
                    statItem(
                        value: viewModel.chartSummary?.primary.formattedValue ?? "0",
                        label: viewModel.chartSummary?.primary.title.uppercased() ?? "SOLVED"
                    )
                    Spacer()
                    statItem(
                        value: viewModel.chartSummary?.secondary.formattedValue ?? "0",
                        label: viewModel.chartSummary?.secondary.title.uppercased() ?? "SESSIONS"
                    )
                    Spacer()
                    statItem(
                        value: viewModel.chartSummary?.tertiary.formattedValue ?? "0",
                        label: viewModel.chartSummary?.tertiary.title.uppercased() ?? "XP"
                    )
                }
                .padding(.top, 4)
            }
            .padding(20)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(24)
            .shadow(color: Color.black.opacity(0.02), radius: 10, x: 0, y: 5)
        }
    }

    private var learningHeatmapSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learning Heatmap")
                .font(.system(size: 16, weight: .bold, design: .rounded))

            VStack(spacing: 16) {
                MultiplicationGridView(
                    grid: viewModel.learningGrid,
                    configuration: .heatmap,
                    selection: heatmapSelection,
                    interaction: heatmapInteraction
                )
                .aspectRatio(1, contentMode: .fit)

                HStack(spacing: 16) {
                    legendItem(color: Color.colorGreenPerfect, title: "Perfect")
                    legendItem(color: Color.colorGreenGood, title: "Good")
                    legendItem(color: Color.colorOrangeHigh, title: "Practice")
                    legendItem(color: Color.colorOrangeHard, title: "Weak")
                }
            }
            .padding(.vertical, 20)
            .padding(.leading, 10)
            .padding(.trailing, 20)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }

    @ViewBuilder
    private var recentSessionsPreview: some View {
        if !viewModel.sessions.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text("Recent Sessions")
                    .font(.system(size: 16, weight: .bold, design: .rounded))

                ForEach(viewModel.sessions.prefix(3), id: \.id) { session in
                    HistoryRow(
                        session: session,
                        isPersonalBest: viewModel.isBest(session)
                    ) { _ in
                        selectedSession = session
                    }
                }
            }
        }
    }

    private func legendItem(
        color: Color,
        title: String
    ) -> some View {
        HStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 4)
                .fill(color)
                .frame(width: 14, height: 14)

            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
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

struct PersonalBestCard: View {
    let title: String
    let mode: PracticeMode
    let icon: String
    let iconColor: Color
    let session: PracticeSession?
    var onTap: (PracticeSession) -> Void

    var body: some View {
        Button {
            if let session {
                onTap(session)
            }
        } label: {
            VStack(spacing: 8) {
                //                ZStack {

                //                    HStack {
                //                        Spacer()

                ShimmerTrophy()
                    .opacity(session == nil ? 0.25 : 1)
                //                    }
                //                }
                //                .frame(height: 20)
                HStack(spacing: 2) {
                    Text(title)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    Image(systemName: icon)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                HStack {
                    if let session {
                        Text("\(session.correctAnswers)/\(session.questionsCount)")
                            .foregroundColor(.primary)

                        Text("\(session.accuracy)%")
                            .foregroundColor(.secondary)
                    } else {
                        Text("—")
                            .foregroundColor(.secondary)

                        Text("No record")
                            .foregroundColor(.secondary)
                    }

                }
                .font(.system(size: 11, weight: .semibold, design: .rounded))
            }
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 10)
            .background {
                Color.white
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(DeptButtonStyle(backgroundColor: .white, cornerRadius: 14))
        .disabled(session == nil)
    }
}
