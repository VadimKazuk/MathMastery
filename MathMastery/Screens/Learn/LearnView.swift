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

                    GeometryReader { geometry in
                        let availableWidth = geometry.size.width - 32
                            let cellSize = cellSize(for: availableWidth)
                            let tablePadding: CGFloat = 10

                        VStack(spacing: 16) {
                            // Выбранное значение
                            Text(viewModel.selectedText)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(AppColor.commonAccentBlue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(AppColor.commonAccentBlue.opacity(0.08))
                                )

                            VStack(spacing: 8) {
                                // Header row
                                HStack(spacing: 6) {
                                    Text("×")
                                        .font(.headline)
                                        .foregroundColor(.secondary)
                                        .frame(width: cellSize, height: cellSize)

                                    ForEach(viewModel.numbers, id: \.self) { column in
                                        Text("\(column)")
                                            .font(.system(size: headerFontSize(for: cellSize), weight: .semibold))
                                            .foregroundColor(AppColor.commonAccentBlue)
                                            .frame(width: cellSize, height: cellSize)
                                            .background(Color.gray.opacity(0.15))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }

                                // Table rows
                                ForEach(viewModel.numbers, id: \.self) { row in
                                    HStack(spacing: 6) {
                                        Text("\(row)")
                                            .font(.system(size: headerFontSize(for: cellSize), weight: .semibold))
                                            .foregroundColor(AppColor.commonAccentBlue)
                                            .frame(width: cellSize, height: cellSize)
                                            .background(Color.gray.opacity(0.15))
                                            .clipShape(RoundedRectangle(cornerRadius: 10))

                                        ForEach(viewModel.numbers, id: \.self) { column in
                                            let isSelected = viewModel.isSelected(row: row, column: column)
                                            let value = viewModel.value(row: row, column: column)

                                            Text("\(value)")
                                                .font(.system(size: dynamicFontSize(for: cellSize), weight: .medium))
                                                .minimumScaleFactor(0.55)
                                                .lineLimit(1)
                                                .multilineTextAlignment(.center)
                                                .foregroundColor(.primary)
                                                .frame(width: cellSize, height: cellSize)
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
                        }
                        .padding(.vertical, 12)
                        .padding(.horizontal, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(.white)
                        )
                        .frame(maxWidth: .infinity)
                        .gesture(
                                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                                            .onChanged { value in
                                                let loc = value.location

                                                let colWidth = cellSize + 6
                                                let rowHeight = cellSize + 8

                                                // Финальная подгонка под твои логи
                                                let headerOffset: CGFloat = cellSize + 20   // сильно уменьшили

                                                let adjustedX = loc.x - 10
                                                let adjustedY = loc.y - headerOffset

                                                let columnIndex = max(0, Int(adjustedX / colWidth))
                                                var rowIndex = max(0, Int(adjustedY / rowHeight))

                                                // Защита первой строки
                                                if adjustedY < rowHeight * 0.7 {
                                                    rowIndex = 0
                                                }

                                                let numbers = viewModel.numbers

                                                guard columnIndex < numbers.count,
                                                      rowIndex < numbers.count else { return }

                                                let row = numbers[rowIndex]
                                                let column = numbers[columnIndex]

                                                print("→ col:\(columnIndex), row:\(rowIndex) | y:\(Int(loc.y)), adjustedY:\(Int(adjustedY)), rowHeight:\(Int(rowHeight))")

                                                withAnimation(.easeInOut(duration: 0.1)) {
                                                    viewModel.selectCell(row: row, column: column)
                                                }
                                            }
                                    )
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
                }
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("MathMastery")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.commonAccentBlue)
                        .fixedSize()
                }
                .sharedBackgroundVisibility(.hidden)

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {} label: {
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

    // MARK: - Dynamic Sizes
    private func cellSize(for width: CGFloat) -> CGFloat {
        let columnsCount: CGFloat = 10
        let spacing: CGFloat = 6
        let calculated = (width - spacing * (columnsCount - 1)) / columnsCount
        return max(calculated, 30)        // чуть уменьшили минимум
    }

    private func dynamicFontSize(for cellSize: CGFloat) -> CGFloat {
        let base = cellSize * 0.42
        return max(min(base, 20), 13)
    }

    private func headerFontSize(for cellSize: CGFloat) -> CGFloat {
        return cellSize > 45 ? 17 : 15
    }
}

#Preview {
    LearnView(
        viewModel: .init(
            serviceContainer: PreviewServiceContainer()
        )
    )
}
