import SwiftUI

/// Geometry and motion tokens.
///
/// Every number the interface uses lives here. Two rules keep the layout honest:
/// spacing is a 4-point scale, and radii are `.continuous` so corners match the
/// squircle curvature Apple uses across iOS.
enum PersonaMetrics {

    // MARK: Spacing — a strict 4pt scale

    /// Between a symbol and the word it belongs to.
    static let spaceHairline = 4.0
    /// Between two lines of the same thought (label above its value).
    static let spaceTight = 8.0
    /// Between siblings inside a row.
    static let spaceSnug = 12.0
    /// The default gutter inside a surface.
    static let spaceRegular = 16.0
    /// Screen margin. Matches the iOS readable-content inset on iPhone.
    static let spaceMargin = 20.0
    /// Between two distinct blocks of content.
    static let spaceSection = 24.0
    /// Between the title and the body it introduces.
    static let spaceHeadline = 32.0
    /// Around a lone element that needs air (outcome icons, empty states).
    static let spaceGenerous = 44.0

    // MARK: Radii — always paired with `.continuous`

    /// Inline chips, icon tiles, inner wells.
    static let radiusSmall = 14.0
    /// Grouped surfaces. Generous on purpose — tight corners read as utilitarian.
    static let radiusSurface = 22.0
    /// Full-bleed hero surfaces.
    static let radiusHero = 28.0

    // MARK: Layout

    /// Keeps line length readable and centers content on larger iPhones.
    static let contentMaxWidth = 480.0
    /// A true hairline, not a 1pt line. Matches UIKit separators.
    static let hairline = 1.0 / 3.0
    /// Minimum comfortable hit target, per the HIG.
    static let hitTarget = 44.0
    /// The distance over which content dissolves under a pinned bar. Long enough
    /// to read as a gradient, short enough that nothing important hides in it.
    static let scrollEdgeRamp = 56.0

    /// How far the ramp continues past the bar's own bottom edge. Without a little
    /// overhang the blur would stop on the exact pixel the bar ends and read as a
    /// hard cut; with too much, resting content sits inside the fade. The scroll
    /// view adds the same amount back as top padding so nothing starts obscured.
    static let scrollEdgeOverhang = 18.0

    // MARK: Motion
    //
    // Durations are deliberately short. The brief asks for transitions that
    // explain what happened without ever making the user wait, so nothing here
    // runs longer than ~0.45s and every spring is interruptible.

    /// What an animation is *for*. Naming the role rather than the curve keeps
    /// timing decisions in one place instead of scattered across views.
    enum Motion {
        /// Swapping one stage of the flow for another.
        case stage
        /// A control responding to touch.
        case control
        /// Text or a number changing in place.
        case value
    }

    static let stageTransition = Animation.spring(duration: 0.42, bounce: 0.12)
    static let controlResponse = Animation.spring(duration: 0.26, bounce: 0.08)
    static let valueChange = Animation.spring(duration: 0.34, bounce: 0.0)
    /// Substituted for every animation above when Reduce Motion is on. Movement
    /// disappears; the state change still gets a beat so it is never abrupt.
    static let reducedMotion = Animation.easeOut(duration: 0.18)

    /// The animation for `role`, honouring the Reduce Motion setting.
    static func motion(_ role: Motion, reduceMotion: Bool) -> Animation {
        guard !reduceMotion else { return reducedMotion }
        switch role {
        case .stage: return stageTransition
        case .control: return controlResponse
        case .value: return valueChange
        }
    }
}
