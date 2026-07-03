import SwiftUI


struct MultiplicationGridView: View {
    @ObservedObject var viewModel: LearnView.ViewModel

    private let spacing: CGFloat = 6

    var body: some View {
        GeometryReader { geo in
            let cellSize = cellSize(for: geo.size.width)

            gridContent(cellSize: cellSize, width: geo.size.width)
        }
    }

    @ViewBuilder
    private func gridContent(cellSize: CGFloat, width: CGFloat) -> some View {
        let content = VStack(spacing: spacing) {
            headerRow(cellSize: cellSize)
            multiplicationRows(cellSize: cellSize)
        }
            .frame(width: width)
            .coordinateSpace(name: LearnView.ViewModel.gridCoordinateSpaceName)
            .contentShape(Rectangle())

        if viewModel.isFocusMode {
            content.gesture(
                dragGesture(cellSize: cellSize),
                isEnabled: viewModel.isFocusMode
            )
        } else {
            content
        }
    }

    private func cellSize(for width: CGFloat) -> CGFloat {
        let columns = CGFloat(viewModel.numbers.count + 1)
        let totalSpacing = spacing * (columns - 1)

        return max((width - totalSpacing) / columns, 1)
    }

    private func headerRow(cellSize: CGFloat) -> some View {
        HStack(spacing: spacing) {
            HeaderCell(
                text: "×",
                color: viewModel.headerColor(rowIndex: nil, columnIndex: nil),
                textColor: viewModel.headerTextColor(rowIndex: nil, columnIndex: nil),
                borderColor: viewModel.headerBorderColor(rowIndex: nil, columnIndex: nil),
                cellSize: cellSize
            )
            .onTapGesture {
                guard viewModel.isFocusMode else { return }
                viewModel.clearSelection()
            }

            ForEach(viewModel.numbers.indices, id: \.self) { columnIndex in
                HeaderCell(
                    text: "\(viewModel.numbers[columnIndex])",
                    color: viewModel.headerColor(rowIndex: nil, columnIndex: columnIndex),
                    textColor: viewModel.headerTextColor(rowIndex: nil, columnIndex: columnIndex),
                    borderColor: viewModel.headerBorderColor(rowIndex: nil, columnIndex: columnIndex),
                    cellSize: cellSize
                )
                .onTapGesture {
                    guard viewModel.isFocusMode else { return }
                    viewModel.selectColumn(viewModel.numbers[columnIndex])
                }
            }
        }
    }

    private func multiplicationRows(cellSize: CGFloat) -> some View {
        ForEach(viewModel.numbers.indices, id: \.self) { rowIndex in
            HStack(spacing: spacing) {
                HeaderCell(
                    text: "\(viewModel.numbers[rowIndex])",
                    color: viewModel.headerColor(rowIndex: rowIndex, columnIndex: nil),
                    textColor: viewModel.headerTextColor(rowIndex: rowIndex, columnIndex: nil),
                    borderColor: viewModel.headerBorderColor(rowIndex: rowIndex, columnIndex: nil),
                    cellSize: cellSize
                )
                .onTapGesture {
                    guard viewModel.isFocusMode else { return }
                    viewModel.selectRow(viewModel.numbers[rowIndex])
                }

                ForEach(viewModel.numbers.indices, id: \.self) { columnIndex in
                    let cell = viewModel.gridState[rowIndex][columnIndex]

                    MultiplicationCell(
                        text: "\(cell.value)",
                        color: cell.level.color,
                        textColor: viewModel.cellTextColor(rowIndex: rowIndex, columnIndex: columnIndex),
                        borderColor: viewModel.cellBorderColor(rowIndex: rowIndex, columnIndex: columnIndex),
                        cellSize: cellSize,
                        onCenterChange: { center in
                            viewModel.updateCellCenter(
                                center,
                                rowIndex: rowIndex,
                                columnIndex: columnIndex
                            )
                        }
                    )
                    .onTapGesture {
                        guard viewModel.isFocusMode else { return }
                        viewModel.selectCell(rowIndex: rowIndex, columnIndex: columnIndex)
                    }
                }
            }
        }
    }

    private func dragGesture(cellSize: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in

                let step = cellSize + spacing

                let column = Int((value.location.x - step) / step)
                let row = Int((value.location.y - step) / step)

                // верхние множители
                if value.location.y < step {
                    guard viewModel.numbers.indices.contains(column) else { return }
                    viewModel.selectColumn(viewModel.numbers[column])
                    return
                }

                // левые множители
                if value.location.x < step {
                    guard viewModel.numbers.indices.contains(row) else { return }
                    viewModel.selectRow(viewModel.numbers[row])
                    return
                }

                // сама таблица
                viewModel.updateSelection(at: value.location)
            }
    }
}

struct HeaderCell: View {
    let text: String
    let color: Color
    let textColor: Color
    let borderColor: Color
    let cellSize: CGFloat

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 10)

        Text(text)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .foregroundColor(textColor)
            .frame(width: cellSize, height: cellSize)
            .background(color)
            .clipShape(shape)
            .overlay {
                shape.stroke(borderColor, lineWidth: 1.5)
            }
    }
}

struct MultiplicationCell: View {
    let text: String
    let color: Color
    let textColor: Color
    let borderColor: Color
    let cellSize: CGFloat
    let onCenterChange: (CGPoint) -> Void

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 10)

        Text(text)
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .foregroundColor(textColor)
            .frame(width: cellSize, height: cellSize)
            .background(color)
            .clipShape(shape)
            .overlay {
                shape.stroke(borderColor, lineWidth: 1.5)
            }
            .background(centerReader)
            .clipShape(shape)
    }

    private var centerReader: some View {
        GeometryReader { geo in
            Color.clear
                .onAppear {
                    updateCenter(from: geo)
                }
                .onChange(of: geo.frame(in: .named(LearnView.ViewModel.gridCoordinateSpaceName))) { _, _ in
                    updateCenter(from: geo)
                }
        }
    }

    private func updateCenter(from geo: GeometryProxy) {
        DispatchQueue.main.async {
            let frame = geo.frame(in: .named(LearnView.ViewModel.gridCoordinateSpaceName))
            onCenterChange(CGPoint(x: frame.midX, y: frame.midY))
        }
    }
}
