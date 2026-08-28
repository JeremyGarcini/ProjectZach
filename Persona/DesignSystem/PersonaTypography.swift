import SwiftUI

/// Type roles.
///
/// Every role is built on a system text style, so Dynamic Type, Bold Text and
/// optical sizing keep working. What is added on top is the part SF Pro does not
/// do for free: negative tracking at display sizes. Large type set at default
/// tracking looks loose and amateur; tightening it is most of what separates a
/// designed headline from a default one.
extension View {

    /// The one sentence that answers "what is about to happen?".
    /// Nothing else on the screen may use this role.
    func personaHeroTitle() -> some View {
        font(.system(.largeTitle, weight: .bold))
            .tracking(-1.0)
            .lineSpacing(-2)
            .foregroundStyle(PersonaPalette.ink)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// The title of a state that replaced the request (sent, declined, failed).
    func personaOutcomeTitle() -> some View {
        font(.system(.title, weight: .bold))
            .tracking(-0.7)
            .foregroundStyle(PersonaPalette.ink)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// Sits directly under a title and qualifies it.
    func personaSubtitle() -> some View {
        font(.system(.callout, weight: .regular))
            .foregroundStyle(PersonaPalette.inkSecondary)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// The left-hand label of a key/value row.
    func personaRowLabel() -> some View {
        font(.system(.subheadline, weight: .regular))
            .foregroundStyle(PersonaPalette.inkSecondary)
    }

    /// The right-hand value of a key/value row, or a row's body copy.
    func personaRowValue() -> some View {
        font(.system(.subheadline, weight: .medium))
            .foregroundStyle(PersonaPalette.ink)
            .fixedSize(horizontal: false, vertical: true)
    }

    /// A time, price, or other value the user is being asked to compare.
    /// Monospaced digits stop the number jittering while it animates.
    func personaFigure(isEmphasised: Bool) -> some View {
        font(.system(.title2, weight: isEmphasised ? .bold : .medium))
            .monospacedDigit()
            .tracking(-0.4)
            .foregroundStyle(isEmphasised ? PersonaPalette.ink : PersonaPalette.inkTertiary)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }
}
