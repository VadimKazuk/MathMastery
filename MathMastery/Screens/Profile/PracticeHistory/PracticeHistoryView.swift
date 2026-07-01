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
                            HistoryRow(session: session) {_ in
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
                    viewModel: .init(serviceContainer: serviceContainer, session: session)
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
    var onTap: ((PracticeSession) -> Void)? = nil   // optional для превью

    var body: some View {
        Button(action: { onTap?(session) }) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: session.mode.systemImage)
                        .font(.title3)
                        .foregroundColor(session.mode.accentColor)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.mode.title)
                            .font(.headline)
                        Text(session.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("\(session.accuracy)%")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                }

                HStack(spacing: 20) {
                    Label("\(session.correctAnswers)/\(session.questionsCount)", systemImage: "checkmark.circle.fill")
                        .foregroundColor(.green)

                    if let avgTime = session.averageResponseTime {
                        Label(String(format: "%.1fs", avgTime), systemImage: "timer")
                            .foregroundColor(.purple)
                    }

                    Label("\(session.longestStreak)", systemImage: "flame.fill")
                        .foregroundColor(.orange)
                }
                .font(.system(size: 15, weight: .medium))

                if !session.mistakes.isEmpty {
                    Text("\(session.mistakes.count) mistakes")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}
