import SwiftUI

struct FocusPracticeView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject var viewModel: ViewModel
    let onComplete: (PracticeSession) -> Void

    init(viewModel: ViewModel, onComplete: @escaping (PracticeSession) -> Void) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.onComplete = onComplete
    }

    var body: some View {
        PracticeModeScreen(
            title: "Focus Mode",
            headerAction: .exitConfirm,
            onBack: {
                dismiss()
            },
            onComplete: {
                onComplete(viewModel.makeResult())
            }
        ) {
            VStack(spacing: 20) {
                HStack {
                    Spacer()
                    progressBadge
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("\(Int(viewModel.progress * 100))% Complete")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary)

                    ProgressView(value: viewModel.progress)
                        .tint(AppColor.commonAccentBlue)
                        .animation(.easeInOut(duration: 0.35), value: viewModel.progress)

                    Text("MULTIPLICATION")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .tracking(1.2)
                        .foregroundColor(.secondary)
                }

                questionCard
                keypad

                if let feedback = viewModel.feedback {
                    Text(feedback)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(feedback == "Correct" ? .green : .red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                if viewModel.isAnswered {
                    Button {
                        if let result = viewModel.moveNextOrResult() {
                            onComplete(result)
                        }
                    } label: {
                        Text("Next")
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 58)
                            .background {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(AppColor.commonAccentBlue)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var progressBadge: some View {
        Text(viewModel.progressText)
            .font(.system(size: 13, weight: .bold, design: .rounded))
            .foregroundColor(AppColor.commonAccentBlue)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background {
                Capsule()
                    .fill(Color.white)
            }
    }

    private var questionCard: some View {
        VStack(spacing: 18) {
            HStack(spacing: 8) {
                Text("\(viewModel.currentQuestion.left)")
                Text("×")
                Text("\(viewModel.currentQuestion.right)")
                Text("=")
                Text(viewModel.answerText.isEmpty ? "?" : viewModel.answerText)
                    .foregroundColor(AppColor.commonAccentBlue)
                    .frame(minWidth: 48)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(AppColor.commonAccentBlue.opacity(0.16))
                            .frame(height: 3)
                            .offset(y: 8)
                    }
            }
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 136)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 6)
        }
    }

    private var keypad: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 3), spacing: 10) {
            ForEach(1...9, id: \.self) { digit in
                keypadButton(title: "\(digit)") {
                    viewModel.appendDigit(digit)
                }
            }

            keypadButton(systemImage: "delete.left") {
                viewModel.deleteDigit()
            }

            keypadButton(title: "0") {
                viewModel.appendDigit(0)
            }

            keypadButton(systemImage: "checkmark") {
                viewModel.submitAnswer()
            }
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColor.commonAccentBlue)
            }
        }
    }

    private func keypadButton(title: String? = nil, systemImage: String? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Group {
                if let title {
                    Text(title)
                } else if let systemImage {
                    Image(systemName: systemImage)
                }
            }
            .font(.system(size: 24, weight: .bold, design: .rounded))
            .foregroundColor(systemImage == "checkmark" ? .white : .primary)
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(systemImage == "checkmark" ? AppColor.commonAccentBlue : Color.white)
            }
        }
        .buttonStyle(.plain)
    }
}


enum FocusPracticeMode: Hashable {
    case table(Int)
    case all
}
