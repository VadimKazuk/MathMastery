import SwiftUI

struct PracticeView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("QUESTION 4 OF 10")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .padding()
                        Spacer()
                        Text("STREAK: 12 🔥")
                            .font(.system(size: 16, weight: .semibold, design: .default))
                            .foregroundColor(AppColor.commonAccentBlue)
                            .padding()
                    }

                }
                .frame(maxWidth: .infinity)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                        Text("Practice")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColor.commonAccentBlue)
                            .fixedSize()
                    }
                    .sharedBackgroundVisibility(.hidden)

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        print("Profile tapped")
                    }) {
                        Image("img_student_purple")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 35, height: 35)
                            .clipShape(Circle())
                    }
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.white, for: .navigationBar)
        }
    }
}

#Preview {
    PracticeView(viewModel: .init(serviceContainer: PreviewServiceContainer()))
}



