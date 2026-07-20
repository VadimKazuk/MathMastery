import SwiftUI

final class AppColor {
    static let commonLightGray = Color("color_main_light_gray", bundle: nil)
    static let commonBgWhite = Color("color_bg_white", bundle: nil)
    static let commonAccentBlue = Color("color_accent_blue", bundle: nil)
    static let colorTodayBlue = Color("color_today_blue", bundle: nil)
    static let commonRedDark = Color("color_red_dark", bundle: nil)
    static let commonPinkSoft = Color("color_pink_soft", bundle: nil)

    static let colorGreenPerfect = Color("color_green_perfect", bundle: nil)
    static let colorOrangeMedium = Color("color_orange_medium", bundle: nil)
    static let colorGreenGood = Color("color_green_good", bundle: nil)
    static let colorOrangeHigh = Color("color_orange_high", bundle: nil)
    static let colorOrangeHard = Color("color_orange_hard", bundle: nil)

    //flame
    static let colorFlameBlue_0 = Color("color_flame_blue_0", bundle: nil)
    static let colorFlameYellow_1 = Color("color_flame_yellow_1", bundle: nil)
    static let colorFlameOrange_2 = Color("color_flame_orange_2", bundle: nil)
    static let colorFlameRed_3 = Color("color_flame_red_3", bundle: nil)
    static let colorFlamePurple_4 = Color("color_flame_purple_4", bundle: nil)
}


extension Color {
    func darker(by percentage: CGFloat) -> Color {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        return Color(red: max(r - percentage, 0), green: max(g - percentage, 0), blue: max(b - percentage, 0), opacity: a)
    }
}
