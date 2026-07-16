import SwiftUI

struct MultiplicationGridView: View {

    let grid: MultiplicationGridState
    let configuration: GridConfiguration

    @ObservedObject var selection: GridSelectionController
    @ObservedObject var interaction: GridInteractionController

    private let spacing: CGFloat = 6

    private var style: GridStyleProvider {
        GridStyleProvider(
            configuration: configuration,
            selection: selection,
            grid: grid
        )
    }

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
            .coordinateSpace(name: GridConstants.coordinateSpaceName)
            .contentShape(Rectangle())

        if configuration.interactive {
            content.gesture(
                dragGesture(cellSize: cellSize),
                isEnabled: configuration.interactive
            )
        } else {
            content
        }
    }

    private func cellSize(for width: CGFloat) -> CGFloat {
        let columns = CGFloat(grid.numbers.count + 1)
        let totalSpacing = spacing * (columns - 1)

        return max((width - totalSpacing) / columns, 1)
    }

    private func headerRow(cellSize: CGFloat) -> some View {
        HStack(spacing: spacing) {
            HeaderCell(
                text: "×",
                color: style.headerColor(rowIndex: nil, columnIndex: nil),
                textColor: style.headerTextColor(rowIndex: nil, columnIndex: nil),
                borderColor: style.headerBorderColor(rowIndex: nil, columnIndex: nil),
                cellSize: cellSize
            )
            .onTapGesture {
                guard configuration.interactive else { return }
                selection.clear()
            }

            ForEach(grid.numbers.indices, id: \.self) { columnIndex in
                HeaderCell(
                    text: "\(grid.numbers[columnIndex])",
                    color: style.headerColor(rowIndex: nil, columnIndex: columnIndex),
                    textColor: style.headerTextColor(rowIndex: nil, columnIndex: columnIndex),
                    borderColor: style.headerBorderColor(rowIndex: nil, columnIndex: columnIndex),
                    cellSize: cellSize
                )
                .onTapGesture {
                    guard configuration.interactive else { return }
                    selection.selectColumn(
                        grid.numbers[columnIndex]
                    )
                }
            }
        }
    }

    private func multiplicationRows(cellSize: CGFloat) -> some View {
        ForEach(grid.numbers.indices, id: \.self) { rowIndex in
            HStack(spacing: spacing) {
                HeaderCell(
                    text: "\(grid.numbers[rowIndex])",
                    color: style.headerColor(rowIndex: rowIndex, columnIndex: nil),
                    textColor: style.headerTextColor(rowIndex: rowIndex, columnIndex: nil),
                    borderColor: style.headerBorderColor(rowIndex: rowIndex, columnIndex: nil),
                    cellSize: cellSize
                )
                .onTapGesture {
                    guard configuration.interactive else { return }

                    selection.selectRow(
                        grid.numbers[rowIndex]
                    )
                }

                ForEach(grid.numbers.indices, id: \.self) { columnIndex in

                    MultiplicationCell(
                        text: "\(grid.cell(row: rowIndex,column: columnIndex).value)",
                        showsText: configuration.showsCellValues,
                        color: configuration.showsCellColors
                            ? grid.cell(
                                row: rowIndex,
                                column: columnIndex
                            ).level.baseColor2
                            : Color.clear,
                        textColor: style.cellTextColor(
                            rowIndex: rowIndex,
                            columnIndex: columnIndex
                        ),
                        borderColor: style.cellBorderColor(
                            rowIndex: rowIndex,
                            columnIndex: columnIndex
                        ),
                        cellSize: cellSize,
                        onCenterChange: { center in
                            interaction.updateCellCenter(
                                center,
                                rowIndex: rowIndex,
                                columnIndex: columnIndex
                            )
                        }
                    )
                    .onTapGesture {
                        guard configuration.interactive else { return }

                        selection.selectCell(
                            rowIndex: rowIndex,
                            columnIndex: columnIndex
                        )
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
                    guard grid.numbers.indices.contains(column) else { return }
                    selection.selectColumn(grid.numbers[column])
                    return
                }

                if value.location.x < step {
                    guard grid.numbers.indices.contains(row) else { return }
                    selection.selectRow(grid.numbers[row])
                    return
                }

                interaction.selectClosestCell(
                    to: value.location,
                    selection: selection
                )
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
    let showsText: Bool
    let color: Color
    let textColor: Color
    let borderColor: Color
    let cellSize: CGFloat
    let onCenterChange: (CGPoint) -> Void

    var body: some View {
        let shape = RoundedRectangle(cornerRadius: 10)

        Text(showsText ? text : "")
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
                .onChange(of: geo.frame(in: .named(GridConstants.coordinateSpaceName))) { _, _ in
                    updateCenter(from: geo)
                }
        }
    }

    private func updateCenter(from geo: GeometryProxy) {
        DispatchQueue.main.async {
            let frame = geo.frame(in: .named(GridConstants.coordinateSpaceName))
            onCenterChange(CGPoint(x: frame.midX, y: frame.midY))
        }
    }
}
