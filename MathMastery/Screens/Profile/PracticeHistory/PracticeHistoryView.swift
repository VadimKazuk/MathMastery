import SwiftUI

struct HistoryListView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel
    @State private var selectedSession: PracticeSession?
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 14) {
                if viewModel.sessions.isEmpty {
                    ContentUnavailableView(
                        "No sessions yet",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Complete your first practice session")
                    )
                } else {
                    ForEach(viewModel.sessions, id: \.id) { session in
                        HistoryRow(
                            session: session,
                            isPersonalBest: viewModel.isBest(session)
                        ) { _ in
                            selectedSession = session
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("History")
        .sheet(item: $selectedSession) { session in
            PracticeResultView(
                viewModel: .init(
                    serviceContainer: serviceContainer,
                    session: session,
                    isPersonalBest: viewModel.isBest(session))
            )
        }
        //            .navigationDestination(for: PracticeSession.self) { session in
        //                PracticeResultView(
        //                    viewModel: .init(serviceContainer: serviceContainer, session: session),
        //                    retryAction: {  },
        //                    switchModeAction: {  },
        //                    hubAction: {  }
        //                )
        //            }
        
        .task {
            viewModel.loadSessions()
        }
    }
}

import SwiftUI

struct HistoryRow: View {
    let session: PracticeSession
    let isPersonalBest: Bool
    var onTap: ((PracticeSession) -> Void)? = nil

    private var headerText: String {
        if let table = session.focusTable {
            return "\(session.mode.title) x\(table)"
        } else {
            return session.mode.title
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            ProgressRing(
                progress: CGFloat(session.accuracy) / 100,
                color: session.mode.accentColor,
                lineWidth: 4,
                animated: true
            ) {
                Text("\(session.accuracy)%")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundColor(session.mode.accentColor)
            }
            .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Image(session.mode.icImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)

                    Text(headerText)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    if isPersonalBest {
                        ShimmerTrophy()
                    }
                }

                HStack(spacing: 12) {
                    Text("\(session.correctAnswers)/\(session.questionsCount) solved")

                    if let avgTime = session.averageResponseTime {
                        Text("•")
                        Text(String(format: "%.1fs avg", avgTime))
                    }

                    if session.longestStreak > 0 {
                        Text("•")

                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 10))

                            Text("\(session.longestStreak)")
                        }
                        .foregroundColor(.orange)
                    }
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)

                Text(session.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 11))
                    .foregroundColor(.secondary)
                    .padding(.top, 1)
            }

            Spacer()

            Button {
                onTap?(session)
            } label: {
                HStack {
                    Image("ic_tap_finger_white")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
                .frame(width: 42, height: 32)
            }
            .buttonStyle(DeptButtonStyle())
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(
            color: Color.black.opacity(0.01),
            radius: 6,
            x: 0,
            y: 3
        )
    }
}
