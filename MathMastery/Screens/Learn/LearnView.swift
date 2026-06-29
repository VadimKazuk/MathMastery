import Combine
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
                contentView
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .toolbar {
                leadingToolbarItem
                profileToolbarItem
            }
            .toolbarBackground(Color.white, for: .navigationBar)
        }
    }
}

// MARK: - Content

private extension LearnView {
    var contentView: some View {
        VStack(alignment: .leading, spacing: 24) {
            modeControl
            tableCard

            if viewModel.isFocusMode {
                focusTableSection
            }

            if viewModel.isFocusMode {
                equationCard
            }
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity)
    }

    var modeControl: some View {
        HStack(spacing: 0) {
            ForEach(LearnMode.allCases) { mode in
                Button {
                    withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                        viewModel.selectMode(mode)
                    }
                } label: {
                    Text(mode.title)
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(viewModel.mode == mode ? .white : Color.primary.opacity(0.75))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(viewModel.mode == mode ? AppColor.commonAccentBlue : Color.clear)
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        }
    }

    var focusTableSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("SET FOCUS TABLE")
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundColor(Color.primary.opacity(0.75))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.focusTables, id: \.self) { number in
                        Button {
                            withAnimation(.spring(response: 0.25, dampingFraction: 0.9)) {
                                viewModel.setFocusTable(number)
                            }
                        } label: {
                            Text("\(number)")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(viewModel.focusTableTextColor(number))
                                .frame(width: 62, height: 62)
                                .background {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(viewModel.focusTableColor(number))
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.gray.opacity(0.18), lineWidth: 2)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(6)
            }
        }
    }

    var tableCard: some View {
        MultiplicationGridView(viewModel: viewModel)
            .aspectRatio(1, contentMode: .fit)
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
            }
            .overlay(alignment: .bottomLeading) {
//                if viewModel.isFocusMode {
//                    focusProgressBar
//                        .padding(.horizontal, 16)
//                }
            }
    }

    var focusProgressBar: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                Capsule()
                    .fill(AppColor.commonAccentBlue)
                    .frame(width: geo.size.width * 0.5)

                Capsule()
                    .fill(AppColor.commonAccentBlue)
            }
        }
        .frame(height: 7)
    }

    var equationCard: some View {
        HStack(spacing: 16) {
            equationArrow(systemName: "chevron.left") {
                viewModel.moveSelection(offset: -1)
            }

            VStack(spacing: 12) {
                Text("CURRENT EQUATION")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .tracking(2)
                    .foregroundColor(Color.primary.opacity(0.7))

                Text(viewModel.equationTitle)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColor.commonAccentBlue)

                Text(viewModel.equationSubtitle)
                    .font(.system(size: 17, weight: .regular, design: .rounded))
                    .foregroundColor(Color.primary)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background {
                        Capsule()
                            .fill(Color.white.opacity(0.72))
                    }

                Text("ACTIVE LEARNING")
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundColor(Color.green.opacity(0.9))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 8)
                    .background {
                        Capsule()
                            .fill(Color.green.opacity(0.22))
                    }
            }
            .frame(maxWidth: .infinity)

            equationArrow(systemName: "chevron.right") {
                viewModel.moveSelection(offset: 1)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 34)
        .background {
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        }
    }

    func equationArrow(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColor.commonAccentBlue)
                .frame(width: 40, height: 40)
                .background {
                    Circle()
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 3)
                }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Toolbar

private extension LearnView {
    var leadingToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Text("MathMastery")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(AppColor.commonAccentBlue)
                .fixedSize()
        }
        .sharedBackgroundVisibility(.hidden)
    }

    var profileToolbarItem: some ToolbarContent {
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                print("Profile tapped")
            } label: {
                Image("img_profile_\(Int.random(in: 1...12))")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 35, height: 35)
                    .clipShape(Circle())
            }
        }
    }
}

// MARK: - Grid

private struct MultiplicationGridView: View {
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
            content.gesture(dragGesture)
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

            ForEach(viewModel.numbers.indices, id: \.self) { columnIndex in
                HeaderCell(
                    text: "\(viewModel.numbers[columnIndex])",
                    color: viewModel.headerColor(rowIndex: nil, columnIndex: columnIndex),
                    textColor: viewModel.headerTextColor(rowIndex: nil, columnIndex: columnIndex),
                    borderColor: viewModel.headerBorderColor(rowIndex: nil, columnIndex: columnIndex),
                    cellSize: cellSize
                )
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

                ForEach(viewModel.numbers.indices, id: \.self) { columnIndex in
                    MultiplicationCell(
                        text: viewModel.cellText(rowIndex: rowIndex, columnIndex: columnIndex),
                        color: viewModel.cellColor(rowIndex: rowIndex, columnIndex: columnIndex),
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
                }
            }
        }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                viewModel.updateSelection(at: value.location)
            }
    }
}

private struct HeaderCell: View {
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

private struct MultiplicationCell: View {
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
                .onChange(of: geo.frame(in: .named(LearnView.ViewModel.gridCoordinateSpaceName)).midX) { _, _ in
                    updateCenter(from: geo)
                }
                .onChange(of: geo.frame(in: .named(LearnView.ViewModel.gridCoordinateSpaceName)).midY) { _, _ in
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


#Preview {
    LearnView(
        viewModel: .init(
            serviceContainer: PreviewServiceContainer()
        )
    )
}
