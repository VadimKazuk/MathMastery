import SwiftUI
import Combine

struct ProfileInfoSettingsView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel

    @Environment(\.dismiss) private var dismiss

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    HStack(spacing: 16) {
                        ZStack(alignment: .bottomTrailing) {
                            Image(viewModel.avatarName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 76, height: 76)
                                .clipShape(Circle())
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.name.isEmpty ? "Alex Johnson" : viewModel.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("Mastery Level: Advanced\nAlgebra")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }

                        Spacer()
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)

                    VStack(alignment: .leading, spacing: 20) {
                        CustomInputField(
                            label: "NAME / NICKNAME",
                            placeholder: "Alex Johnson",
                            text: $viewModel.name,
                            iconName: "person"
                        )

                        CustomInputField(
                            label: "EMAIL ADDRESS",
                            placeholder: "alex.j@example.com",
                            text: $viewModel.email,
                            iconName: "envelope"
                        )

                        HStack(spacing: 16) {
                            CustomInputField(
                                label: "AGE (OPTIONAL)",
                                placeholder: "e.g. 15",
                                text: $viewModel.age,
                                iconName: "calendar"
                            )

                            CustomInputField(
                                label: "GRADE (OPTIONAL)",
                                placeholder: "10th Grade",
                                text: $viewModel.grade,
                                iconName: "graduationcap"
                            )
                        }
                    }
                }
                .padding(.horizontal, 24)
            }

            Spacer()

            Button(action: {
                viewModel.saveProfile()
                dismiss()
            }) {
                HStack(spacing: 8) {
                    Text("Save Profile")
                        .font(.headline)
                    Image(systemName: "checkmark.circle")
                        .font(.body)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color(red: 0.0, green: 0.35, blue: 0.8))
                .cornerRadius(27)
                .shadow(color: Color(red: 0.0, green: 0.35, blue: 0.8).opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color(red: 0.98, green: 0.98, blue: 1.0))
        .navigationTitle("Change Profile Information")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct CustomInputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let iconName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.gray)

            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .foregroundColor(Color.blue.opacity(0.6))
                    .frame(width: 20)

                TextField(placeholder, text: $text)
                    .font(.body)
            }
            .padding(.horizontal, 16)
            .frame(height: 50)
            .background(Color(red: 0.95, green: 0.95, blue: 0.98))
            .cornerRadius(16)
        }
    }
}

extension ProfileInfoSettingsView {
    final class ViewModel: ObservableObject {
        private let accountService: AccountService

        @Published var name: String = ""
        @Published var email: String = ""
        @Published var age: String = ""
        @Published var grade: String = ""

        var avatarName: String {
            "img_profile_\(accountService.profile.avatarId)"
        }

        init(serviceContainer: ServiceContainer) {
            self.accountService = serviceContainer.resolve(AccountService.self)

            let profile = accountService.profile

            name = profile.name
            age = profile.age
            grade = profile.grade

            if profile.email.isEmpty {
                email = accountService.user?.email ?? ""
            } else {
                email = profile.email
            }
        }

        func saveProfile() {
            var profile = accountService.profile

            profile.name = name
            profile.email = email
            profile.age = age
            profile.grade = grade

            accountService.profile = profile
        }
    }
}

#Preview {
    ProfileInfoSettingsView(viewModel: .init(serviceContainer: PreviewServiceContainer()))
}
