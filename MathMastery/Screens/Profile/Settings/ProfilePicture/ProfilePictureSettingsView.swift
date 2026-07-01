import SwiftUI
import Combine

// MARK: - Avatar Model
struct AvatarOption: Identifiable, Hashable {
    let id: Int
    let imageName: String
}

// MARK: - View Model Extension
extension ProfilePictureSettingsView {
    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private var cancellables = Set<AnyCancellable>()

        // 12 Profile picture options mapped to assets img_profile_1...img_profile_12
        @Published var avatarOptions: [AvatarOption] = (1...12).map {
            AvatarOption(id: $0, imageName: "img_profile_\($0)")
        }

        @Published var selectedAvatarId: Int = 1

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
        }

        func saveAvatarChanges() {
            print("Saved avatar asset: img_profile_\(selectedAvatarId)")
        }
    }
}

// MARK: - Main View
struct ProfilePictureSettingsView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel
    @Environment(\.dismiss) private var dismiss

    // Changed from 2 flexible items to 4 columns to achieve the 4x3 look for 12 items
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // MARK: - Current Avatar Preview Header
                    VStack(spacing: 12) {
                        ZStack(alignment: .bottomTrailing) {
                            Image("img_profile_\(viewModel.selectedAvatarId)")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 140, height: 140)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                        }

                        Text("CURRENT AVATAR")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.secondary)
                            .tracking(1.0)
                    }
                    .padding(.top, 16)

                    // MARK: - Grid Section Header
                    HStack {
                        Text("Choose your hero")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        Text("12 OPTIONS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 4)

                    // MARK: - Avatar Selector Grid (4x3 Layout)
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.avatarOptions) { avatar in
                            Button {
                                viewModel.selectedAvatarId = avatar.id
                            } label: {
                                Image(avatar.imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity)
                                    .aspectRatio(1.0, contentMode: .fit)
                                    .background(Color(uiColor: .systemGray6))
                                    // Decreased corner radius slightly (from 24 to 14) so small 4-column cards look cleaner
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14)
                                            .stroke(viewModel.selectedAvatarId == avatar.id ? Color.blue : Color.clear, lineWidth: 3)
                                    )
                                    .overlay(
                                        Group {
                                            if viewModel.selectedAvatarId == avatar.id {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.blue)
                                                    .background(Circle().fill(Color.white))
                                                    // Decreased system icon size slightly to scale with smaller squares
                                                    .font(.system(size: 16))
                                                    .padding(6)
                                            }
                                        },
                                        alignment: .topTrailing
                                    )
                                    .shadow(color: Color.black.opacity(0.03), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }

                    // MARK: - Information Banner
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                            .font(.system(size: 18))

                        Text("Choose an avatar that represents you! You can unlock special limited-edition avatars by completing math challenges and leveling up.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color.blue.opacity(0.8))
                            .lineSpacing(4)

                        Spacer()
                    }
                    .padding(16)
                    .background(Color.blue.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }

            // MARK: - Bottom Save CTA
            VStack {
                Button {
                    viewModel.saveAvatarChanges()
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Text("Save Changes")
                        Image(systemName: "sparkles")
                    }
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
            .padding(.bottom, 16)
            .background(Color(uiColor: .systemBackground))
        }
        .navigationTitle("Change Avatar")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview Mock Stubs
#Preview {
    NavigationStack {
        ProfilePictureSettingsView(viewModel: .init(serviceContainer: PreviewServiceContainer()))
    }
}
