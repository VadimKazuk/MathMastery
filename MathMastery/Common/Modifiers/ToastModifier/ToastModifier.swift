import SwiftUI

struct ToastModifier: ViewModifier {
    @StateObject var viewModel: ViewModel

    @State private var dragOffset: CGFloat = 0.0
    @State private var isDragging: Bool = false

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    func body(content: Content) -> some View {
        content
            .overlay(
                VStack {
                    if viewModel.isShowing {
                        ZStack(alignment: .topLeading) {
                            HStack(alignment: .top) {
                                Spacer()
                                Button {
                                    viewModel.hideToast()
                                } label: {
                                    Image("ic_close")
                                }
                            }
                            HStack(alignment: .top) {
                                Image("ic_warning")
                                    .foregroundColor(.white)
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(viewModel.title)
                                        .font(Font.system(size: 15, weight: .bold))
                                        .foregroundStyle(.black)
                                    Text(viewModel.message)
                                        .font(Font.system(size: 13, weight: .regular))
                                        .foregroundStyle(.black)
                                }
                            }
                        }
                        .padding()
                        .background(.pink)
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                        .offset(y: dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = max(min(value.translation.height, 0), -100)
                                    isDragging = true
                                    viewModel.dismissTimer()
                                }
                                .onEnded { value in
                                    isDragging = false
                                    if value.translation.height < -5 {
//                                        withAnimation {
                                        viewModel.hideToast()
                                            dragOffset = 0
//                                        }
                                    } else {
                                        withAnimation {
                                            dragOffset = 0
                                        }
                                        if !isDragging {
                                            viewModel.startTimer()
                                        }
                                    }
                                }
                        )
                        .onAppear {
                            dragOffset = 0
                        }
                    }
                }
                .padding(),
                alignment: .top
            )
    }
}

extension View {
    func toast(serviceContainer: ServiceContainer) -> some View {
        self.modifier(ToastModifier(viewModel: .init(serviceContainer: serviceContainer)))
    }
}
