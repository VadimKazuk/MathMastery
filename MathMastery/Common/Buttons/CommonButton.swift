import SwiftUI

import SwiftUI

struct CommonButton: View {
    let title: String?
    let image: String?
    let action: () -> Void

    var fontSize: CGFloat = 18
    var imageSize: CGFloat = 18
    var textColor: Color = .white
    var backgroundColor: Color = AppColor.commonAccentBlue
    var cornerRadius: CGFloat = 24
    var verticalPadding: CGFloat = 16
    var depth: CGFloat = 6
    var spacing: CGFloat = 8

    init(
        title: String? = nil,
        image: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.image = image
        self.action = action
    }

    var body: some View {
        Button(action: action) {

            HStack(spacing: spacing) {

                if let image {
                    Image(systemName: image)
                        .font(.system(size: imageSize, weight: .bold))
                }

                if let title {
                    Text(title)
                        .font(
                            .system(
                                size: fontSize,
                                weight: .bold
                            )
                        )
                }
            }
            .foregroundColor(textColor)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            DeptButtonStyle(
                backgroundColor: backgroundColor,
                cornerRadius: cornerRadius,
                depth: depth
            )
        )
    }
}
