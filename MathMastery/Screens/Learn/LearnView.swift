import SwiftUI

struct LearnView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {

                VStack(spacing: 16) {

                    Text("Multiplication Table")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .padding(.top)

                    Text("Tap a cell to see the calculation details.")
                        .font(.system(size: 17))
                        .foregroundColor(.secondary)

                    selectedView

                    gridView
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("MathMastery")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.commonAccentBlue)
                }
                .sharedBackgroundVisibility(.hidden)

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                    } label: {
                        Image("img_student_purple")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 35, height: 35)
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(.white, for: .navigationBar)
        }
    }

    // MARK: - Selected view
    private var selectedView: some View {
        Text(viewModel.selectedText)
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(AppColor.commonAccentBlue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColor.commonAccentBlue.opacity(0.08))
            )
            .padding(.horizontal)
    }


    private var gridView: some View {

        let spacing: CGFloat = 6
        let cellHeight: CGFloat = 44

        return VStack(spacing: spacing) {

            // HEADER ROW
            HStack(spacing: spacing) {

                Text("×")
                    .frame(width: cellHeight, height: cellHeight)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                ForEach(viewModel.numbers, id: \.self) { column in
                    Text("\(column)")
                        .frame(width: cellHeight, height: cellHeight)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            // DATA ROWS
            ForEach(viewModel.numbers, id: \.self) { row in

                HStack(spacing: spacing) {

                    // row header
                    Text("\(row)")
                        .frame(width: cellHeight, height: cellHeight)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    // values
                    ForEach(viewModel.numbers, id: \.self) { column in

                        let isSelected = viewModel.isSelected(row: row, column: column)
                        let value = viewModel.value(row: row, column: column)

                        Text("\(value)")
                            .font(.system(size: 16, weight: .medium))
                            .frame(width: cellHeight, height: cellHeight)
                            .foregroundColor(.primary)
                            .background(
                                isSelected
                                ? AppColor.commonAccentBlue.opacity(0.15)
                                : Color.green.opacity(0.15)
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(
                                        isSelected ? AppColor.commonAccentBlue : .clear,
                                        lineWidth: 2.5
                                    )
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    viewModel.selectCell(row: row, column: column)
                                }
                            }
                    }
                }
            }
        }
        .gesture(   // 👈 ВОТ СЮДА
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let rowHeight: CGFloat = 50
                        let colWidth: CGFloat = 50

                        let col = Int(value.location.x / colWidth) - 1
                        let row = Int(value.location.y / rowHeight) - 1

                        guard row >= 0,
                              col >= 0,
                              row < viewModel.numbers.count,
                              col < viewModel.numbers.count else { return }

                        let r = viewModel.numbers[row]
                        let c = viewModel.numbers[col]

                        viewModel.selectCell(row: r, column: c)
                    }
            )
    }

    // MARK: - Sizes (safe constants)
    private var dynamicFontSize: CGFloat {
        16
    }

    private var headerFontSize: CGFloat {
        15
    }


    // MARK: - Sizes
    private func dynamicFontSize(_ cellSize: CGFloat) -> CGFloat {
        let base = cellSize * 0.42
        return max(min(base, 20), 13)
    }

    private func headerFontSize(_ cellSize: CGFloat) -> CGFloat {
        cellSize > 45 ? 17 : 15
    }
}

#Preview {
    LearnView(
        viewModel: .init(
            serviceContainer: PreviewServiceContainer()
        )
    )
}
