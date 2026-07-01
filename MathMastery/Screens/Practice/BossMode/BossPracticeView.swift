import SwiftUI

struct BossPracticeView: View {
    @StateObject var viewModel: ViewModel
    let onComplete: (PracticeSession) -> Void

    init(viewModel: ViewModel, onComplete: @escaping (PracticeSession) -> Void) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onComplete = onComplete
    }

    var body: some View {
        PracticeModeScreen(
            title: "Boss Mode",
            onComplete: {
                onComplete(viewModel.makeResult())
            }
        ) {
            switch viewModel.phase {
            case .tableSelection:
                tableSelection
            case .active:
                activePractice
            }
        }
    }

    private var tableSelection: some View {
        VStack(spacing: 26) {
            Text("Choose a table to conquer")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(Color.primary.opacity(0.7))

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 12) {
                ForEach(viewModel.tables, id: \.self) { table in
                    Button {
                        viewModel.selectTable(table)
                    } label: {
                        Text("\(table)")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(viewModel.selectedTable == table ? .white : AppColor.commonAccentBlue)
                            .frame(maxWidth: .infinity)
                            .frame(height: 62)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(viewModel.selectedTable == table ? AppColor.commonAccentBlue : Color.white)
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }

            Button {
                viewModel.startTable()
            } label: {
                Text("Start ×\(viewModel.selectedTable)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColor.commonAccentBlue)
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
        }
        .padding(.top, 28)
    }

    private var activePractice: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text("×\(viewModel.selectedTable) TABLE")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .tracking(1.3)
                    .foregroundColor(.secondary)

                ProgressView(value: viewModel.progress)
                    .tint(AppColor.commonAccentBlue)
            }

            VStack(spacing: 20) {
                Text(viewModel.currentQuestion.title)
                    .font(.system(size: 36, weight: .bold, design: .rounded))

                Text("\(viewModel.questionIndex + 1) of \(viewModel.questions.count)")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 150)
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
