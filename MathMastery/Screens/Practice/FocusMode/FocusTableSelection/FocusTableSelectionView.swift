import SwiftUI

struct FocusTableSelectionView: View {
    @StateObject private var viewModel: ViewModel
    let onSelect: (FocusPracticeTarget) -> Void
    
    init(
        serviceContainer: ServiceContainer,
        onSelect: @escaping (FocusPracticeTarget) -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: ViewModel(serviceContainer: serviceContainer))
        self.onSelect = onSelect
    }
    
    var body: some View {
        
        VStack(spacing: 0) {
            PracticeModeScreen(
                title: "Focus Mode",
                headerAction: .close,
                onComplete: {}
            ) {
                VStack(spacing: 0) {
                    
                    Text("Choose a table to master")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.bottom, 24)
                    
                    Button {
                        onSelect(.all)
                    } label: {
                        AllTablesCellView(
                            accuracy: viewModel.overallAccuracy,
                            state: viewModel.state(for: .all)
                        )
                    }
                    .buttonStyle(.plain)
                    .gridCellColumns(2)
                    .padding(.bottom, 16)
                    
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: 16),
                            GridItem(.flexible(), spacing: 16)
                        ],
                        spacing: 16
                    ) {
                        ForEach(viewModel.tables, id: \.self) { item in
                            
                            Button {
                                switch item {
                                case .all:
                                    onSelect(.all)
                                    
                                case .table(let table):
                                    onSelect(.table(table))
                                }
                            } label: {
                                cellView(for: item)
                            }
                            .buttonStyle(.plain)
                            .disabled(isDisabled(for: item))
                        }
                    }
                    
                    Text("Select a table to start your deep dive.")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding(.top, 32)
                }
            }
        }
    }
    
    @ViewBuilder
    private func cellView(for item: FocusTableSelection) -> some View {
        switch item {
        case .all:
            AllTablesCellView(
                accuracy: viewModel.overallAccuracy,
                state: viewModel.state(for: .all)
            )
            
        case .table(let table):
            TableCellView(
                table: table,
                status: viewModel.status(for: table),
                state: viewModel.state(for: .table(table))
            )
        }
    }
    
    private func isDisabled(for item: FocusTableSelection) -> Bool {
        switch item {
        case .all:
            return false
        case .table(let table):
            return viewModel.status(for: table) == .locked
        }
    }
}

// MARK: - Вспомогательные компоненты для UI

enum TableStatus: Equatable {
    case locked
    case progress(Int, MistakeLevel)
    case completed
}

enum FocusTableSelection: Hashable {
    case all
    case table(Int)
}

struct AllTablesCellView: View {
    
    let accuracy: Int
    @ObservedObject var state: TableCellState
    
    private var targetPercentage: Int {
        accuracy
    }
    
    var body: some View {
        VStack(spacing: 4) {
            
            HStack {
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(AppColor.commonAccentBlue.opacity(0.12), lineWidth: 4)
                    
                    Circle()
                        .trim(from: 0, to: state.animatedProgress)
                        .stroke(
                            AppColor.commonAccentBlue,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    
                    Text("\(state.displayedPercentage)%")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.commonAccentBlue)
                    
                }
                .frame(width: 46, height: 46)
                .padding(.top, 12)
                .padding(.trailing, 12)
            }
            
            Text("ALL")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("TABLES")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8)
        }
        .onAppear {
            runAnimationIfNeeded()
        }
    }
    
    private func runAnimationIfNeeded() {
        guard !state.hasAnimated else { return }
        state.hasAnimated = true
        
        let target = targetPercentage
        guard target > 0 else { return }
        
        let duration: Double = 0.8
        let steps = max(target, 1)
        let interval = duration / Double(steps)
        
        withAnimation(.easeInOut(duration: duration)) {
            state.animatedProgress = CGFloat(target) / 100.0
        }
        
        var step = 0
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            step += 1
            state.displayedPercentage = step
            
            if step >= target {
                timer.invalidate()
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    state.isAnimationFinished = true
                }
            }
        }
    }
}

struct TableCellView: View {
    let table: Int
    let status: TableStatus
    @ObservedObject var state: TableCellState
    
    private var targetPercentage: Int {
        switch status {
        case .progress(let percentage, _):
            return percentage
        case .completed:
            return 100
        case .locked:
            return 0
        }
    }
    
    private var progressColor: Color {
        switch status {
        case .locked:
            return .gray
        case .completed:
            return AppColor.commonAccentBlue
        case .progress(_, let level):
            return level.baseColor
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            
            HStack {
                Spacer()
                
                Group {
                    switch status {
                        
                    case .locked:
                        Image(systemName: "lock.fill")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary.opacity(0.6))
                            .frame(width: 46, height: 46)
                            .background(Circle().fill(Color(uiColor: .secondarySystemBackground)))
                        
                    case .progress, .completed:
                        ZStack {
                            Circle()
                                .stroke(progressColor.opacity(0.12), lineWidth: 4)
                            
                            Circle()
                                .trim(from: 0, to: state.animatedProgress)
                                .stroke(progressColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .rotationEffect(.degrees(-90))
                            
                            if status == .completed && state.isAnimationFinished {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(progressColor)
                            } else {
                                Text("\(state.displayedPercentage)%")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(progressColor)
                            }
                        }
                        .frame(width: 46, height: 46)
                    }
                }
                .padding(.top, 12)
                .padding(.trailing, 12)
            }
            
            Text("\(table)")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(status == .locked ? .secondary.opacity(0.5) : .primary)
            
            Text("TIMES\nTABLE")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.04), radius: 8)
        }
        .opacity(status == .locked ? 0.6 : 1.0)
        .onAppear {
            runAnimationIfNeeded()
        }
    }
    
    private func runAnimationIfNeeded() {
        guard !state.hasAnimated else { return }
        state.hasAnimated = true
        
        let target = targetPercentage
        guard target > 0 else { return }
        
        let duration: Double = 0.8
        let steps = max(target, 1)
        let interval = duration / Double(steps)
        
        withAnimation(.easeInOut(duration: duration)) {
            state.animatedProgress = CGFloat(target) / 100.0
        }
        
        var step = 0
        
        Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { timer in
            step += 1
            state.displayedPercentage = step
            
            if step >= target {
                timer.invalidate()
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    state.isAnimationFinished = true
                }
            }
        }
    }
}
