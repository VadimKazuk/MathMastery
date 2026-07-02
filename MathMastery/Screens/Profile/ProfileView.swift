import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel
    @State private var selectedSession: PracticeSession?

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    profileHeader
                    statsRow
                    mostDifficultSection
                    focusAreasSection
                    achievementsSection
                    recentSessionsPreview
                    NavigationLink {
                        HistoryListView(
                            viewModel: .init(serviceContainer: serviceContainer)
                        )
                        .toolbar(.hidden, for: .tabBar)
                    } label: {
                        HStack {
                            Text("View Full History")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("MathMastery")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.commonAccentBlue)
                        .fixedSize()
                }
                .sharedBackgroundVisibility(.hidden)

                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        SettingsView(
                            viewModel: .init(serviceContainer: serviceContainer)
                        )
                        .toolbar(.hidden, for: .tabBar)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(width: 36, height: 36)
                    }
                }
            }
            .toolbarBackground(Color.white, for: .navigationBar)
            .sheet(item: $selectedSession) { session in
                PracticeResultView(
                    viewModel: .init(serviceContainer: serviceContainer, session: session)
                )
            }
        }
        .task {
            viewModel.loadSessions()
        }
    }

    // MARK: - Header
    private var profileHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .strokeBorder(
                        LinearGradient(colors: [Color.green.opacity(0.6), Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 5
                    )
                    .frame(width: 118, height: 118)

                Image(viewModel.avatarName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 104, height: 104)
                    .clipShape(Circle())
            }

            Text(viewModel.displayName)
                .font(.system(size: 26, weight: .bold, design: .rounded))

            Text("MATHEMATICIAN APPRENTICE")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text("LEVEL 14")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.blue)
                    Spacer()
                    Text("2,450 / 3,000 XP")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }

                ProgressView(value: 2450, total: 3000)
                    .tint(.green)
                    .scaleEffect(x: 1, y: 1.4, anchor: .center)
            }
            .padding(.horizontal, 8)
        }
    }

    // MARK: - Stats
    private var statsRow: some View {
        HStack(spacing: 14) {
            StatCard(icon: "checkmark.circle.fill", value: "\(viewModel.overallAccuracy)%", label: "ACCURACY", color: .green)
            StatCard(icon: "timer", value: String(format: "%.1fs", viewModel.fastestTime), label: "FASTEST", color: .blue)
            StatCard(icon: "gauge", value: String(format: "%.1fs", viewModel.overallAverageTime), label: "AVERAGE", color: .purple)
        }
    }

    private var mostDifficultSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: "puzzlepiece.fill")
                    .foregroundColor(.orange)
                Text("12 × 13")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                Spacer()
            }
            Text("MOST DIFFICULT")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var focusAreasSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Focus Areas")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                Button("RETRY ALL") { }
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.blue)
            }

            FocusAreaRow(multiplier: 7, status: "Accuracy dropped by 15% this week", color: .orange)
            FocusAreaRow(multiplier: 8, status: "Average time: 4.5 seconds", color: .red)
            FocusAreaRow(multiplier: 12, status: "Stable performance", color: .gray)
        }
    }

    private var achievementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Achievements")
                .font(.system(size: 18, weight: .bold, design: .rounded))

            HStack(spacing: 16) {
                AchievementBadge(icon: "bolt.fill", color: .green, title: "Speed Demon")
                AchievementBadge(icon: "checkmark.seal.fill", color: .blue, title: "Perfect Week")
                AchievementBadge(icon: "crown.fill", color: .orange, title: "Grandmaster")
            }
        }
    }

    @ViewBuilder
    private var recentSessionsPreview: some View {
        if !viewModel.sessions.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                Text("Recent Sessions")
                    .font(.system(size: 18, weight: .bold, design: .rounded))

                ForEach(viewModel.sessions.prefix(3), id: \.id) { session in
                    HistoryRow(session: session) {_ in
                        selectedSession = session
                    }
                }
            }
        }
    }
}

// MARK: - Reusable Components
struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
