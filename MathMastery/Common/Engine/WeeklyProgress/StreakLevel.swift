import SwiftUI

enum StreakLevel {
    case zero
    case beginner
    case active
    case hot
    case legendary

    init(days: Int) {
        switch days {
        case 0:
            self = .zero
        case 1...6:
            self = .beginner
        case 7...29:
            self = .active
        case 30...99:
            self = .hot
        default:
            self = .legendary
        }
    }

    var imageName: String {
        switch self {
        case .zero:
            return "ic_flame_0"
        case .beginner:
            return "ic_flame_1"
        case .active:
            return "ic_flame_2"
        case .hot:
            return "ic_flame_3"
        case .legendary:
            return "ic_flame_4"
        }
    }

    var lottieImageName: String {
        switch self {
        case .zero:
            return "ic_flame_animated_0"
        case .beginner:
            return "ic_flame_animated_1"
        case .active:
            return "ic_flame_animated_2"
        case .hot:
            return "ic_flame_animated_3"
        case .legendary:
            return "ic_flame_animated_4"
        }
    }

    var color: Color {
        switch self {
        case .zero:
            return AppColor.colorFlameBlue_0
        case .beginner:
            return AppColor.colorFlameYellow_1
        case .active:
            return AppColor.colorFlameOrange_2
        case .hot:
            return AppColor.colorFlameRed_3
        case .legendary:
            return AppColor.colorFlamePurple_4
        }
    }

    var title: String {
        switch self {
        case .zero: return "Start Now!"
        case .beginner: return "Starting"
        case .active: return "On Fire!"
        case .hot: return "Unstoppable!"
        case .legendary: return "Legend!"
        }
    }
}
