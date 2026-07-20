import SwiftUI

struct DepthToggle: View {
    @Binding var value: Bool
    let onImage: String
    let offImage: String

    var body: some View {
        Button {
            value.toggle()
        } label: {
            Image(value ? onImage : offImage)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 18, height: 18)
                .frame(width: 42, height: 36)
        }
        .buttonStyle(
            ToggleDepthStyle(
                isSelected: value,
                selectedColor: AppColor.commonAccentBlue,
                unselectedColor: Color(.systemGray5),
                depth: 5,
                cornerRadius: 12
            )
        )
    }
}
