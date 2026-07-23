import SwiftUI

struct PracticeModeScreen<Content: View>: View {
    enum HeaderAction {
        case close
        case pause
        case exitConfirm
    }
    @State private var showPauseOverlay = false
    let canChangeTable: Bool
    let title: String
    let headerAction: HeaderAction
    let onBackToTableSelection: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    let onRestart: () -> Void
    let onBack: () -> Void
    let content: Content

    init(
        title: String,
        canChangeTable: Bool = false,
        headerAction: HeaderAction = .close,
        onBackToTableSelection: @escaping () -> Void = {},
        onPause: @escaping () -> Void = {},
        onResume: @escaping () -> Void = {},
        onRestart: @escaping () -> Void = {},
        onBack: @escaping () -> Void = {},
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.canChangeTable = canChangeTable
        self.headerAction = headerAction
        self.onBackToTableSelection = onBackToTableSelection
        self.onPause = onPause
        self.onResume = onResume
        self.onRestart = onRestart
        self.onBack = onBack
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(spacing: 24) {
                    content
                }
                .padding(.horizontal, 22)
                .padding(.top, 18)
                .padding(.bottom, 28)
                .frame(maxWidth: .infinity)
                .background(ScrollViewConfigurator())
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationBarBackButtonHidden(true)
        .overlay {
            if headerAction == .pause || headerAction == .exitConfirm {
                PauseOverlay(
                    isPresented: $showPauseOverlay,
                    mode: headerAction == .pause ? .pause : .exit,
                    canChangeTable: canChangeTable,
                    onContinue: {
                        showPauseOverlay = false
                        if headerAction == .pause {
                            onResume()
                        }
                    },
                    onRestart: {
                        showPauseOverlay = false
                        onRestart()
                    },
                    onBack: {
                        showPauseOverlay = false
                        onBack()
                    },
                    onBackToTableSelection: {
                        showPauseOverlay = false
                        onBackToTableSelection()
                    }
                )
            }
        }
    }

    private var header: some View {
        HStack {
            Button {
                switch headerAction {
                case .close:
                    onBack()
                case .pause:
                    onPause()
                    showPauseOverlay = true
                case .exitConfirm:
                    showPauseOverlay = true
                }
            } label: {
                Image(systemName: iconName)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(width: 42, height: 42)
                    .background {
                        Circle()
                            .fill(Color.white)
                    }
            }
            .buttonStyle(.plain)
            Spacer()
            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
            Spacer()
            Color.clear
                .frame(width: 42, height: 42)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var iconName: String {
        switch headerAction {
        case .pause:
            return "pause.fill"
        case .close, .exitConfirm:
            return "xmark"
        }
    }
}
