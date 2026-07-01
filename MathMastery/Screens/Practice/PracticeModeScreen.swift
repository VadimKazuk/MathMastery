import SwiftUI

struct PracticeModeScreen<Trailing: View, Content: View>: View {
    @Environment(\.dismiss) private var dismiss

    @State private var showExitModal = false

    let title: String
    let trailing: Trailing
    let onComplete: () -> Void
    let content: Content

    init(
        title: String,
        trailing: Trailing,
        onComplete: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.trailing = trailing
        self.onComplete = onComplete
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                content
//                finishButton
            }
            .padding(.horizontal, 22)
            .padding(.top, 18)
            .padding(.bottom, 28)
            .frame(maxWidth: .infinity)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .overlay {
            exitOverlay
        }
    }

    private var header: some View {
        HStack(spacing: 14) {
            Button {
                showExitModal = true
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.primary.opacity(0.72))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)

            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(AppColor.commonAccentBlue)

            Spacer()

            trailing
        }
    }

    private var finishButton: some View {
        Button(action: onComplete) {
            Text("Finish Session")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(AppColor.commonAccentBlue)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white)
                }
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var exitOverlay: some View {
        if showExitModal {
            ZStack {
                Color.black.opacity(0.32)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showExitModal = false
                        }
                    }

                VStack(spacing: 20) {
                    Text("Leave Practice?")
                        .font(.system(size: 22, weight: .bold, design: .rounded))

                    Text("Your current progress will be lost.")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showExitModal = false
                            }
                        } label: {
                            Text("Stay")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(AppColor.commonAccentBlue)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color(.systemGray6))
                                }
                        }

                        Button {
                            showExitModal = false
                            dismiss()
                        } label: {
                            Text("Leave")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(.red)
                                }
                        }
                    }
                }
                .padding(24)
                .frame(width: 310)
                .background {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.96))
                        .shadow(color: .black.opacity(0.14), radius: 18, x: 0, y: 10)
                }
                .transition(.scale.combined(with: .opacity))
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showExitModal)
        }
    }
}

extension PracticeModeScreen where Trailing == EmptyView {
    init(
        title: String,
        onComplete: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            title: title,
            trailing: EmptyView(),
            onComplete: onComplete,
            content: content
        )
    }
}
