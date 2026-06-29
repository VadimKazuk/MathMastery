import SwiftUI

struct SurvivalPracticeView: View {
    @StateObject var viewModel: ViewModel
    let onComplete: (PracticeResult) -> Void

    init(viewModel: ViewModel, onComplete: @escaping (PracticeResult) -> Void) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onComplete = onComplete
    }

    var body: some View {
        PracticeModeScreen(
            title: "Survival Mode",
            trailing: livesBadge,
            onComplete: {
                onComplete(viewModel.makeResult())
            }
        ) {
            VStack(spacing: 28) {
                VStack(spacing: 8) {
                    Text("\(viewModel.currentStreak) Streak")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.green)

                    Text("Don't break the streak")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.top, 42)

                VStack(spacing: 20) {
                    Text(viewModel.currentQuestion.title)
                        .font(.system(size: 36, weight: .bold, design: .rounded))

                    ProgressView(value: Double(viewModel.lives), total: 3)
                        .tint(AppColor.commonAccentBlue)
                        .frame(width: 120)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 138)
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
                }

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 14),
                        GridItem(.flexible(), spacing: 14)
                    ],
                    spacing: 14
                ) {
                    ForEach(viewModel.answerOptions, id: \.self) { answer in
                        Button {
                            if let result = viewModel.selectAnswer(answer) {
                                onComplete(result)
                            }
                        } label: {
                            Text("\(answer)")
                                .font(.system(size: 25, weight: .bold, design: .rounded))
                                .foregroundColor(AppColor.commonAccentBlue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 76)
                                .background {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white)
                                        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var livesBadge: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < viewModel.lives ? "heart.fill" : "heart")
                    .foregroundColor(index < viewModel.lives ? .red : .gray.opacity(0.5))
            }
        }
        .font(.system(size: 16, weight: .semibold))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background {
            Capsule()
                .fill(Color.white)
        }
    }
}
