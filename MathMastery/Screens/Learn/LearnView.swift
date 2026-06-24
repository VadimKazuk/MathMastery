import SwiftUI

struct LearnView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel

    @State private var activeCell: (row: Int, col: Int)?
    @State private var cellCenters: [String: CGPoint] = [:]

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

                    Text("Tap or drag anywhere")
                        .foregroundColor(.secondary)

                    selectedView
                    gridView
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Selected
    private var selectedView: some View {
        Text(viewModel.selectedText)
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(AppColor.commonAccentBlue)
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColor.commonAccentBlue.opacity(0.08))
            )
            .padding(.horizontal)
    }

    // MARK: - GRID
    private var gridView: some View {

        let spacing: CGFloat = 6

        return VStack(spacing: spacing) {

            // HEADER
            HStack(spacing: spacing) {
                Text("×")
                    .frame(width: 30, height: 30)
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                ForEach(viewModel.numbers, id: \.self) { col in
                    Text("\(col)")
                        .frame(width: 30, height: 30)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }

            // GRID
            ForEach(viewModel.numbers.indices, id: \.self) { r in
                HStack(spacing: spacing) {

                    Text("\(viewModel.numbers[r])")
                        .frame(width: 30, height: 30)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    ForEach(viewModel.numbers.indices, id: \.self) { c in

                        let value = viewModel.value(row: viewModel.numbers[r],
                                                    column: viewModel.numbers[c])

                        let isSelected = activeCell?.row == r && activeCell?.col == c
                        let dist = distance(r, c)

                        Text("\(value)")
                            .frame(width: 30, height: 30)
                            .background(waveColor(dist, isSelected: isSelected))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .onAppear {
                                            let center = CGPoint(
                                                x: geo.frame(in: .named("GRID")).midX,
                                                y: geo.frame(in: .named("GRID")).midY
                                            )
                                            cellCenters["\(r)-\(c)"] = center
                                        }
                                }
                            )
                    }
                }
            }
        }
        .coordinateSpace(name: "GRID")
        .contentShape(Rectangle())
        .gesture(dragGesture())
    }

    // MARK: - DRAG (NO MATH GRID)
    private func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                updateSelection(at: value.location)
            }
    }
    private func waveOpacity(_ d: Int) -> Double {
        let maxDistance = 6
        guard d <= maxDistance else { return 0 }

        return max(0, 1.0 - Double(d) / Double(maxDistance))
    }

    // MARK: - HIT TEST (KEY PART)
    private func updateSelection(at point: CGPoint) {

        guard !cellCenters.isEmpty else { return }

        let closest = cellCenters.min { a, b in
            distanceSquared(a.value, point) < distanceSquared(b.value, point)
        }

        guard let key = closest?.key else { return }

        let parts = key.split(separator: "-")
        guard parts.count == 2,
              let r = Int(parts[0]),
              let c = Int(parts[1]) else { return }

        activeCell = (r, c)

        let rowValue = viewModel.numbers[r]
        let colValue = viewModel.numbers[c]

        viewModel.selectCell(row: rowValue, column: colValue)
    }

    private func distanceSquared(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return dx * dx + dy * dy
    }

    // MARK: - Wave
    private func waveColor(_ d: Int, isSelected: Bool) -> Color {
        if isSelected {
            return Color.green.opacity(0.85)
        }

        switch d {
        case 0: return Color.green.opacity(0.60)
        case 1: return Color.green.opacity(0.45)
        case 2: return Color.green.opacity(0.30)
        case 3: return Color.green.opacity(0.18)
        case 4: return Color.green.opacity(0.10)
        case 5: return Color.green.opacity(0.05)
        default: return Color.clear
        }
    }

    private func distance(_ r: Int, _ c: Int) -> Int {
        guard let activeCell else { return Int.max }
        return abs(r - activeCell.row) + abs(c - activeCell.col)
    }
}

#Preview {
    LearnView(
        viewModel: .init(
            serviceContainer: PreviewServiceContainer()
        )
    )
}
