import SwiftUI

/// 4pt-based spacing scale shared by all views (mirrors the Android `Spacing` tokens).
enum Spacing {
    static let xxSmall: CGFloat = 4
    static let xSmall: CGFloat = 8
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xLarge: CGFloat = 32
}

enum Metrics {
    /// Readable line length on iPad and in landscape.
    static let maxContentWidth: CGFloat = 700
    /// Concentric with the 48pt logos inside cards (12pt radius + 16pt padding), as the iOS 26 HIG recommends.
    static let cardCornerRadius: CGFloat = 28
}

extension View {
    /// Grouped-style card on the system's secondary grouped background (adapts to dark mode).
    func cardStyle() -> some View {
        background(
            Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: Metrics.cardCornerRadius, style: .continuous)
        )
    }
}

extension View {
    /// Light selection haptic when `trigger` changes (iOS 17+; no-op before).
    @ViewBuilder
    func selectionFeedback<T: Equatable>(trigger: T) -> some View {
        if #available(iOS 17.0, *) {
            sensoryFeedback(.selection, trigger: trigger)
        } else {
            self
        }
    }
}
