import SwiftUI

struct PauseOverlay: View {

    enum Mode {
        case pause
        case exit
    }

    @Binding var isPresented: Bool

    let mode: Mode

    let onContinue: () -> Void
    let onRestart: () -> Void
    let onBack: () -> Void

    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.32)
                    .ignoresSafeArea()
                    .onTapGesture {
                        onContinue()
                    }

                VStack(spacing: 30) {
                    VStack(spacing: 8) {
                        Text(
                            mode == .pause
                            ? "Practice Paused"
                            : "Leave Practice?"
                        )
                        .font(
                            .system(
                                size: 24,
                                weight: .bold,
                                design: .rounded
                            )
                        )

                        Text(
                            mode == .pause
                            ? "You can continue anytime."
                            : "Your current progress will be lost."
                        )
                        .font(
                            .system(
                                size: 16,
                                weight: .medium,
                                design: .rounded
                            )
                        )
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    }
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            Button {
                                onContinue()
                            } label: {
                                Text("Continue")
                                    .font(
                                        .system(
                                            size: 16,
                                            weight: .bold,
                                            design: .rounded
                                        )
                                    )
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                            }
                            .buttonStyle(
                                DepthButtonStyle(
                                    backgroundColor: Color(.systemGray5),
                                    cornerRadius: 14,
                                    depth: 5,
                                    borderWidth: 1
                                )
                            )
                            .foregroundColor(AppColor.commonAccentBlue)
                            Button {
                                onBack()
                            } label: {
                                Text("Back to Menu")
                                    .font(
                                        .system(
                                            size: 16,
                                            weight: .bold,
                                            design: .rounded
                                        )
                                    )
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                            }
                            .buttonStyle(
                                DepthButtonStyle(
                                    backgroundColor: .red,
                                    cornerRadius: 14,
                                    depth: 5,
                                    borderWidth: 1
                                )
                            )
                            .foregroundColor(.white)
                        }
                        if mode == .pause {
                            Button {
                                onRestart()
                            } label: {
                                Text("Restart")
                                    .font(
                                        .system(
                                            size: 16,
                                            weight: .bold,
                                            design: .rounded
                                        )
                                    )
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 52)
                            }
                            .buttonStyle(
                                DepthButtonStyle(
                                    backgroundColor: .white,
                                    cornerRadius: 14,
                                    depth: 5,
                                    borderWidth: 1
                                )
                            )
                            .foregroundColor(AppColor.commonAccentBlue)
                        }
                    }
                }
                .padding(24)
                .frame(width: 320)
                .background {
                    RoundedRectangle(
                        cornerRadius: 24,
                        style: .continuous
                    )
                    .fill(Color(.systemBackground))
                }
            }
            .transition(.opacity)
        }
    }
}
