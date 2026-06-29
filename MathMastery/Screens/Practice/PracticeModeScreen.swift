import SwiftUI

struct PracticeModeScreen<Trailing: View, Content: View>: View {
    @Environment(\.dismiss) private var dismiss

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
    }

    private var header: some View {
        HStack(spacing: 14) {
            Button {
                dismiss()
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
