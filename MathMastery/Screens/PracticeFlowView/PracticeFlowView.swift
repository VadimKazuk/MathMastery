import SwiftUI

struct PracticeFlowView: View {
    let launch: PracticeLaunch
    let serviceContainer: ServiceContainer
    let onClose: () -> Void
    @State private var path: [PracticeRoute] = []

    var body: some View {
        NavigationStack(path: $path) {
            Color.clear
                .navigationDestination(for: PracticeRoute.self) { route in
                    destination(route)
                }
        }
        .task {
            openLaunch()
        }
    }
}

private extension PracticeFlowView {
    func openLaunch() {
        guard path.isEmpty else {
            return
        }

        switch launch {
        case .focus(let table, let canChangeTable):
            path = [
                .focusPractice(
                    table: table,
                    canChangeTable: canChangeTable
                )
            ]

        case .mode(let mode):
            switch mode {
            case .speed:
                path = [.speed]

            case .rush:
                path = [.rush]

            case .survival:
                path = [.survival]

            case .focus:
                path = [.focusTableSelection]
            }
        }
    }
}

private extension PracticeFlowView {
    @ViewBuilder
    func destination(_ route: PracticeRoute) -> some View {
        switch route {
        case .speed:
            SpeedPracticeView(
                viewModel: .init(
                    serviceContainer: serviceContainer
                ),
                onComplete: { session in
                    path.append(.result(session))
                },
                onExit: {
                    onClose()
                }
            )

        case .rush:
            RushPracticeView(
                viewModel: .init(
                    serviceContainer: serviceContainer
                ),
                onComplete: { session in
                    path.append(.result(session))
                },
                onExit: {
                    onClose()
                }
            )

        case .survival:
            SurvivalPracticeView(
                viewModel: .init(
                    serviceContainer: serviceContainer
                ),
                onComplete: { session in
                    path.append(.result(session))
                },
                onExit: {
                    onClose()
                }
            )

        case .focusTableSelection:
            FocusTableSelectionView(
                serviceContainer: serviceContainer
            ) { target in
                switch target {
                case .all:
                    path.append(
                        .focusPractice(
                            table: nil,
                            canChangeTable: true
                        )
                    )

                case .table(let table):
                    path.append(
                        .focusPractice(
                            table: table,
                            canChangeTable: true
                        )
                    )
                }
            } onExit: {
                onClose()
            }

        case .focusPractice(let table, let canChangeTable):
            FocusPracticeView(
                viewModel: .init(
                    serviceContainer: serviceContainer,
                    mode: table == nil ? .all : .table(table ?? 2),
                    focusTable: table
                ),
                canChangeTable: canChangeTable,
                onComplete: { session in
                    path.append(.result(session))
                },
                onBackToTableSelection: {
                    path.removeLast()
                },
                onExit: {
                    onClose()
                }
            )

        case .result(let session):
            PracticeResultView(
                viewModel: .init(
                    serviceContainer: serviceContainer,
                    session: session,
                    isPersonalBest: true
                ),
                switchModeAction: {
                    onClose()
                },
                closeAction: {
                    onClose()
                }
            )
        }
    }
}
