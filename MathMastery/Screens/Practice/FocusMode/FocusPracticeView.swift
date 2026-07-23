import SwiftUI


struct FocusPracticeView: View {

    @StateObject var viewModel: ViewModel

    @State private var shakeAnimation: CGFloat = 0

    let onComplete: (PracticeSession) -> Void
    let onBackToTableSelection: () -> Void
    let onExit: () -> Void

    let canChangeTable: Bool

    init(
        viewModel: ViewModel,
        canChangeTable: Bool,
        onComplete: @escaping (PracticeSession) -> Void,
        onBackToTableSelection: @escaping () -> Void,
        onExit: @escaping () -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.canChangeTable = canChangeTable
        self.onComplete = onComplete
        self.onBackToTableSelection = onBackToTableSelection
        self.onExit = onExit
    }

    var body: some View {
        PracticeModeScreen(
            title: "Focus Mode",
            canChangeTable: canChangeTable,
            headerAction: .exitConfirm,
            onBackToTableSelection: {
                onBackToTableSelection()
            },
            onBack: {
                onExit()
            }
        ) {
            VStack(spacing: 20) {

                HStack {
                    progressBadge
                    Spacer()

                    if viewModel.showAnswerButton {
                        showAnswerButton
                            .transition(.opacity)
                    }
                }
                .frame(height: 50)
                .animation(
                    .easeOut(duration: 0.15),
                    value: viewModel.showAnswerButton
                )

                questionCard
                keypad
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

                // Анимируем только введенный ответ
                ZStack {
                    Text("00")
                        .hidden()

                    Text(viewModel.answerText.isEmpty ? "?" : viewModel.answerText)
                        .foregroundColor(viewModel.answerColor)
                }
                .frame(minWidth: 36)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(AppColor.commonAccentBlue.opacity(0.16))
                            .frame(height: 3)
                            .offset(y: 8)
                    }
                    .modifier(ShakeEffect(animatableData: shakeAnimation))
                    .onChange(of: viewModel.shakeTrigger) {
                        shakeAnimation = 0
                        withAnimation(
                            .easeOut(duration: 0.35)
                        ) {
                            shakeAnimation = 1
                        }
                    }
            }
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 136)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .stroke(
                    Color.black.opacity(0.08),
                    lineWidth: 3
                )

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

            keypadButton(
                title: viewModel.isWaitingForNext ? "NEXT" : nil,
                systemImage: viewModel.isWaitingForNext ? nil : "checkmark",
                isActionButton: true
            ) {
                viewModel.submitAnswer { result in
                    if let result {
                        onComplete(result)
                    }
                }
            }
        }
    }

    private var showAnswerButton: some View {
        CommonButton(
            title: "Show Answer",
            action: {
                viewModel.showAnswer()
            }
        )
        .frame(width: 150, height: 50)
    }

    private func keypadButton(
        title: String? = nil,
        systemImage: String? = nil,
        isActionButton: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Group {
                if let title {
                    Text(title)
                } else if let systemImage {
                    Image(systemName: systemImage)
                }
            }
            .font(.system(size: title == "NEXT" ? 18 : 24, weight: .bold, design: .rounded))
            .foregroundColor(isActionButton ? .white : .primary)
            .frame(maxWidth: .infinity)
            .frame(height: 68)
        }
        .buttonStyle(
            DepthButtonStyle(
                backgroundColor: isActionButton ? AppColor.commonAccentBlue : Color.white,
                cornerRadius: 14,
                depth: 5,
                borderWidth: 1
            )
        )
    }
}

enum FocusPracticeMode: Hashable {
    case table(Int)
    case all
}

struct ShakeEffect: GeometryEffect {

    var amount: CGFloat = 8
    var shakes: CGFloat = 4

    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {

        let translation = amount * sin(animatableData * .pi * shakes)

        return ProjectionTransform(
            CGAffineTransform(
                translationX: translation,
                y: 0
            )
        )
    }
}
