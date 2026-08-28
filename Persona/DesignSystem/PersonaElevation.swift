import SwiftUI

/// Depth.
///
/// Two things separate a shadow that looks designed from one that looks default.
///
/// **It is two shadows, not one.** A tight, darker one anchors the object to the
/// surface; a wide, faint one is the ambient light around it. A single blurred
/// black blob is the giveaway of an interface nobody looked at twice.
///
/// **It is not black.** Shadows here are cast in the ink navy, and a coloured
/// object casts a shadow in its *own* hue. That is why the primary button glows
/// indigo underneath instead of looking like it is sitting on a grey smudge.
extension View {

    /// A card lifted off the page.
    func personaElevation(_ level: PersonaElevation = .card) -> some View {
        shadow(color: level.contactColor, radius: level.contactRadius, y: level.contactOffset)
            .shadow(color: level.ambientColor, radius: level.ambientRadius, y: level.ambientOffset)
    }

    /// A coloured control that should look lit rather than painted.
    func personaGlow(_ color: Color, intensity: Double = 1) -> some View {
        shadow(color: color.opacity(0.34 * intensity), radius: 18, y: 8)
            .shadow(color: color.opacity(0.18 * intensity), radius: 4, y: 2)
    }
}

enum PersonaElevation {
    /// Content resting on the page.
    case card
    /// A pinned bar, or anything that content scrolls beneath.
    case raised

    private var ink: Color { PersonaPalette.ink }

    var contactColor: Color {
        switch self {
        case .card: ink.opacity(0.05)
        case .raised: ink.opacity(0.07)
        }
    }

    var contactRadius: Double {
        switch self {
        case .card: 3
        case .raised: 5
        }
    }

    var contactOffset: Double {
        switch self {
        case .card: 1
        case .raised: 2
        }
    }

    var ambientColor: Color {
        switch self {
        case .card: ink.opacity(0.06)
        case .raised: ink.opacity(0.09)
        }
    }

    var ambientRadius: Double {
        switch self {
        case .card: 24
        case .raised: 32
        }
    }

    var ambientOffset: Double {
        switch self {
        case .card: 10
        case .raised: 14
        }
    }
}
