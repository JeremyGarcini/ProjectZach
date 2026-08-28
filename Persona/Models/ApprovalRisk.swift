import SwiftUI

/// How much a mistake would cost.
///
/// Risk deliberately carries no colour. Encoding "safe" as green and "risky" as
/// orange invites approving on colour alone, which is exactly the reflex this
/// screen should not build. It changes the words and the amount of work the
/// confirmation takes instead.
enum ApprovalRisk: Sendable {
    case low
    case high

    /// The eyebrow above the request title.
    var label: String {
        switch self {
        case .low: "Low stakes"
        case .high: "High stakes"
        }
    }

    /// The glyph in the eyebrow chip. Shape, not colour, is what distinguishes
    /// the two — a colour-only difference would be invisible to a chunk of users
    /// and would invite approving on hue alone.
    var symbol: String {
        switch self {
        case .low: "clock.fill"
        case .high: "person.crop.circle.fill"
        }
    }

    /// The chip is tinted to say *who this touches* — indigo for something inside
    /// Persona's own remit, amber for something that reaches another person. It is
    /// deliberately not a green/red safety rating.
    var chipTint: Color {
        switch self {
        case .low: PersonaPalette.brand
        case .high: PersonaPalette.caution
        }
    }

    /// Whether the commit needs a deliberate held press rather than a tap.
    var requiresHeldConfirmation: Bool { self == .high }

    /// Whether approving opens a final review of the exact thing being sent.
    var requiresSecondLook: Bool { self == .high }
}
