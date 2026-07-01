import SwiftUI
import Combine

// MARK: - Enums for Settings Selection
enum LearningRange: String, CaseIterable, Identifiable {
    case x2_x5 = "x2-x5"
    case x2_x10 = "x2-x10"
    case custom = "Custom"
    var id: String { self.rawValue }
}

enum CountdownDuration: Int, CaseIterable, Identifiable {
    case three = 3
    case five = 5
    case ten = 10
    var id: Int { self.rawValue }
}

enum AppTheme: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    var id: String { self.rawValue }
}

enum AccentColor: String, CaseIterable, Identifiable {
    case blue, green, brown, orange, purple, pink
    var id: String { self.rawValue }

    var color: Color {
        switch self {
        case .blue: return .blue
        case .green: return .green
        case .brown: return .brown // Substitute with your asset palette asset color
        case .orange: return .orange
        case .purple: return .purple
        case .pink: return .pink
        }
    }
}

// MARK: - View Model Extension
extension SettingsView {
    final class ViewModel: ObservableObject {
        private let serviceContainer: ServiceContainer
        private var cancellables = Set<AnyCancellable>()

        // Account
        // (Handled via navigation actions)

        // Learning
        @Published var selectedRange: LearningRange = .x2_x5
        @Published var rememberLastMode: Bool = false
        @Published var showExplanations: Bool = false
        @Published var highlightMistakes: Bool = false

        // Practice
        @Published var questionsPerSession: Int = 20
        @Published var prePracticeCountdown: Bool = false
        @Published var countdownDuration: CountdownDuration = .five
        @Published var hapticFeedback: Bool = false
        @Published var soundEffects: Bool = false

        // Daily Goal
        @Published var solvedQuestions: Int = 15
        @Published var targetQuestions: Int = 25
        @Published var goalMultiplier: Int = 25

        // Appearance
        @Published var selectedTheme: AppTheme = .light
        @Published var selectedAccentColor: AccentColor = .blue
        @Published var reduceAnimations: Bool = false

        init(serviceContainer: ServiceContainer) {
            self.serviceContainer = serviceContainer
        }
    }
}

// MARK: - Main Settings View
struct SettingsView: View {
    @EnvironmentObject var serviceContainer: ServiceContainer
    @StateObject var viewModel: ViewModel

    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Account Section
                Section(header: Text("ACCOUNT")) {
                    NavigationLink {
                        ProfilePictureSettingsView(viewModel: .init(serviceContainer: serviceContainer))
                    } label: {
                        Text("Change Avatar")
                    }
//                    NavigationLink {
//                        SettingsView(viewModel: .init(serviceContainer: serviceContainer))
//                    } label: {
//                        Text("Profile Information")
//                    }
                    NavigationLink(destination: Text("Profile Information View")) {
                        Text("Profile Information")
                    }
                }

                // MARK: - Learning Section
                Section(header: Text("LEARNING")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Default Range")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Picker("Default Range", selection: $viewModel.selectedRange) {
                            ForEach(LearningRange.allCases) { range in
                                Text(range.rawValue).tag(range)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    Toggle("Remember last mode", isOn: $viewModel.rememberLastMode)
                    Toggle("Show explanations", isOn: $viewModel.showExplanations)
                    Toggle("Highlight mistakes", isOn: $viewModel.highlightMistakes)
                }

                // MARK: - Practice Section
                Section(header: Text("PRACTICE")) {
                    NavigationLink(destination: Text("Questions Per Session Selection")) {
                        HStack {
                            Text("Questions per session")
                            Spacer()
                            Text("\(viewModel.questionsPerSession)")
                                .foregroundColor(.secondary)
                        }
                    }

                    Toggle("Pre-practice Countdown", isOn: $viewModel.prePracticeCountdown)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Countdown Duration")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Picker("Countdown Duration", selection: $viewModel.countdownDuration) {
                            ForEach(CountdownDuration.allCases) { duration in
                                Text("\(duration.rawValue)s").tag(duration)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    Toggle("Haptic Feedback", isOn: $viewModel.hapticFeedback)
                    Toggle("Sound Effects", isOn: $viewModel.soundEffects)
                }

                // MARK: - Daily Goal Section
                Section(header: Text("DAILY GOAL")) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Progress")
                                .font(.subheadline)
                                .bold()
                            Spacer()
                            Text("\(viewModel.solvedQuestions) / \(viewModel.targetQuestions) questions solved today")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }

                        ProgressView(value: Double(viewModel.solvedQuestions), total: Double(viewModel.targetQuestions))
                            .tint(.green)
                            .scaleEffect(x: 1, y: 2, anchor: .center) // Thickens the progress bar slightly to match UI
                            .padding(.vertical, 4)

                        Text("Goal Multiplier")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)

                        Picker("Goal Multiplier", selection: $viewModel.goalMultiplier) {
                            ForEach([10, 25, 50, 100], id: \.self) { value in
                                Text("\(value)").tag(value)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                }

                // MARK: - Appearance Section
                Section(header: Text("APPEARANCE")) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Theme")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Picker("Theme", selection: $viewModel.selectedTheme) {
                            ForEach(AppTheme.allCases) { theme in
                                Text(theme.rawValue).tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Accent Color")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        HStack(spacing: 12) {
                            ForEach(AccentColor.allCases) { accent in
                                ZStack {
                                    Circle()
                                        .fill(accent.color)
                                        .frame(width: 32, height: 32)
                                        .onTapGesture {
                                            viewModel.selectedAccentColor = accent
                                        }

                                    if viewModel.selectedAccentColor == accent {
                                        Circle()
                                            .stroke(Color.primary, lineWidth: 2)
                                            .frame(width: 38, height: 38)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))

                    Toggle("Reduce Animations", isOn: $viewModel.reduceAnimations)
                }

                // MARK: - Data & Privacy Section
                Section(header: Text("DATA & PRIVACY")) {
                    Button(action: { /* Handle reset logic */ }) {
                        HStack {
                            Text("Reset Practice History").foregroundColor(.red)
                            Spacer()
                            Image(systemName: "chevron.right").font(.footnote).foregroundColor(.secondary)
                        }
                    }
                    Button(action: { /* Handle reset logic */ }) {
                        HStack {
                            Text("Reset Statistics").foregroundColor(.red)
                            Spacer()
                            Image(systemName: "chevron.right").font(.footnote).foregroundColor(.secondary)
                        }
                    }
                    Button(action: { /* Handle default restoration */ }) {
                        HStack {
                            Text("Restore Defaults").foregroundColor(.blue)
                            Spacer()
                            Image(systemName: "chevron.right").font(.footnote).foregroundColor(.secondary)
                        }
                    }
                }

                // MARK: - About Section
                Section(header: Text("ABOUT")) {
                    NavigationLink(destination: Text("About MathMastery")) {
                        Text("About MathMastery")
                    }
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.2.0").foregroundColor(.secondary)
                    }
                    NavigationLink(destination: Text("Privacy Policy")) {
                        Text("Privacy Policy")
                    }
                    NavigationLink(destination: Text("Terms of Service")) {
                        Text("Terms of Service")
                    }
                    NavigationLink(destination: Text("Contact Support")) {
                        Text("Contact Support")
                    }
                }

                // MARK: - Footer Footer
                Section {
                    HStack {
                        Spacer()
                        Text("Crafted with effort for Math Masters")
                            .font(.caption)
                            .italic()
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}


#Preview {
    SettingsView(viewModel: .init(serviceContainer: PreviewServiceContainer()))
}
