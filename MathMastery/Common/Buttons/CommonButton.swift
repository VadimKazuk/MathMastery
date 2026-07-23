import SwiftUI

struct CommonButton: View {
    let title: String?
    let image: String?
    let rightImage: String?
    let leftImage: String?
    let action: () -> Void

    var fontSize: CGFloat = 15
    var imageSize: CGFloat = 15
    var textColor: Color = .white
    var backgroundColor: Color = AppColor.commonAccentBlue
    var cornerRadius: CGFloat = 14
    var verticalPadding: CGFloat = 16
    var depth: CGFloat = 5
    var spacing: CGFloat = 8
        
    init(
        title: String? = nil,
        leftImage: String? = nil,
        image: String? = nil,
        rightImage: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.rightImage = rightImage
        self.image = image
        self.leftImage = leftImage
        self.action = action
    }

    var body: some View {
        Button(action: action) {

            HStack(spacing: spacing) {

                if let leftImage {
                    Image(systemName: leftImage)
                        .font(.system(size: imageSize, weight: .bold))
                }

                if let title {
                    Text(title)
                        .font(.system(size: fontSize, weight: .bold))
                } else if let image {
                    Image(systemName: image)
                        .font(.system(size: imageSize, weight: .bold))
                }

                if let rightImage {
                    Image(systemName: rightImage)
                        .font(.system(size: imageSize, weight: .bold))
                }
            }
            .foregroundColor(textColor)
            .padding(.vertical, verticalPadding)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(
            DepthButtonStyle(
                backgroundColor: backgroundColor,
                cornerRadius: cornerRadius,
                depth: depth
            )
        )
    }
}
