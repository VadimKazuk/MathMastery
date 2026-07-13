import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel

    @State private var selectedSession: PracticeSession?

    @AppStorage("lastShownXP") private var lastXP = 0
    @State private var animatedProgress: Double = 0
    @State private var displayedXP = 0

    @State private var animateXP = false

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    profileHeader
                    //                    statsRow
                    //                    achievementsSection
                    personalBestsSection
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
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .foregroundColor(.primary)
                    }
                }
                .padding(16)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            //            .toolbar {
            //                ToolbarItem(placement: .navigationBarLeading) {
            //                    Text("MathMastery")
            //                        .font(.system(size: 28, weight: .bold, design: .rounded))
            //                        .foregroundColor(AppColor.commonAccentBlue)
            //                        .fixedSize()
            //                }
            //                .sharedBackgroundVisibility(.hidden)
            //
            //                ToolbarItem(placement: .navigationBarTrailing) {
            //                    NavigationLink {
            //                        SettingsView(
            //                            viewModel: .init(serviceContainer: serviceContainer)
            //                        )
            //                        .toolbar(.hidden, for: .tabBar)
            //                    } label: {
            //                        Image(systemName: "gearshape.fill")
            //                            .font(.system(size: 20, weight: .semibold))
            //                            .foregroundColor(.primary)
            //                            .frame(width: 36, height: 36)
            //                    }
            //                }
            //            }
            //            .toolbarBackground(Color.white, for: .navigationBar)
            .sheet(item: $selectedSession) { session in
                PracticeResultView(
                    viewModel: .init(serviceContainer: serviceContainer, session: session)
                )
            }
        }
        .task {
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
            // Горизонтальный блок: Аватар + Текст
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
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 72, height: 72)
                .clipShape(Circle())


                VStack(alignment: .leading, spacing: 4) {

                    Text(viewModel.profileName)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("MATHEMATICIAN APPRENTICE")
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1.0)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button {
                    viewModel.openGameCenter()
                } label: {
                    Image(systemName: "gamecontroller.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(width: 42, height: 42)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.12))
                        )
                }
                .buttonStyle(.plain)
            }

            // Кастомный индикатор уровня и XP (на всю ширину под ними)
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

                // Кастомный плавный ProgressBar
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
        .contentShape(Rectangle())
    }

    // MARK: - Stats
    private var statsRow: some View {
        HStack(spacing: 14) {
            StatCard(title: "ACCURACY", value: "\(viewModel.overallAccuracy)%", icon: "checkmark.circle.fill", iconColor: .green)
            StatCard(title: "FASTEST", value: String(format: "%.1fs", viewModel.fastestTime), icon: "timer", iconColor: .blue)
            StatCard(title: "AVERAGE", value: String(format: "%.1fs", viewModel.overallAverageTime), icon: "gauge", iconColor: .purple)
        }
    }

    //    private var achievementsSection: some View {
    //        VStack(alignment: .leading, spacing: 12) {
    //            Text("Recent Achievements")
    //                .font(.system(size: 16, weight: .bold, design: .rounded))
    //
    //            HStack(spacing: 16) {
    //                AchievementBadge(icon: "bolt.fill", color: .green, title: "Speed Demon")
    //                AchievementBadge(icon: "checkmark.seal.fill", color: .blue, title: "Perfect Week")
    //                AchievementBadge(icon: "crown.fill", color: .orange, title: "Grandmaster")
    //            }
    //        }
    //    }

    @ViewBuilder
    private var recentSessionsPreview: some View {
        if !viewModel.sessions.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text("Recent Sessions")
                    .font(.system(size: 16, weight: .bold, design: .rounded))

                ForEach(viewModel.sessions.prefix(3), id: \.id) { session in
                    HistoryRow(session: session) {_ in
                        selectedSession = session
                    }
                }
            }
        }
    }

    private var personalBestsSection: some View {
        HStack(spacing: 14) {
            PersonalBestCard(
                title: "SPEED",
                icon: "bolt.fill",
                iconColor: .orange,
                session: viewModel.bestSpeed
            ) {
                selectedSession = $0
            }

            PersonalBestCard(
                title: "SURVIVAL",
                icon: "heart.fill",
                iconColor: .red,
                session: viewModel.bestSurvival
            ) {
                selectedSession = $0
            }

            PersonalBestCard(
                title: "RUSH",
                icon: "flame.fill",
                iconColor: .orange,
                session: viewModel.bestRush
            ) {
                selectedSession = $0
            }
        }
    }
}

// MARK: - Reusable Components
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let iconColor: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(iconColor)

            Text(title)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }
}

struct FocusAreaRow: View {
    let multiplier: Int
    let status: String
    let color: Color

    var body: some View {
        HStack {
            Text("×\(multiplier)")
                .font(.system(size: 18, weight: .bold))
                .padding(10)
                .background(color.opacity(0.15))
                .foregroundColor(color)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text("Table of \(multiplier)")
                    .font(.system(size: 16, weight: .semibold))
                Text(status)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

struct AchievementBadge: View {
    let icon: String
    let color: Color
    let title: String
    var locked: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(locked ? Color.gray.opacity(0.2) : color.opacity(0.12))
                .frame(width: 64, height: 64)
                .overlay {
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(locked ? .gray : color)
                }

            Text(title)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundStyle(locked ? .gray : .primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 40)
        }
        .frame(maxWidth: .infinity)
    }
}

struct PersonalBestCard: View {
    let title: String
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
                HStack {
                    Spacer()

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.yellow)
                        .opacity(session == nil ? 0.25 : 1)
                }

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)

                Text(title)
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.secondary)

                if let session {
                    Text("\(session.questionsCount)")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("\(session.accuracy)%")
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(.secondary)
                } else {
                    Text("—")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)

                    Text("No record")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 10)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
        .disabled(session == nil)
    }
}
