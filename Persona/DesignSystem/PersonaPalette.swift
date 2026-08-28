import SwiftUI

/// Colour.
///
/// The palette is built around one saturated brand indigo, a deep navy ink, and
/// a set of soft tinted surfaces. Nothing here is a system grey: neutral greys
/// are what make an interface read as unfinished rather than restrained.
///
/// Three rules:
///  1. **Indigo is Persona.** It carries the primary action, the active state and
///     the mark. Nothing else may use it.
///  2. **Surfaces are tinted, never neutral.** Each block of content sits on a
///     hue that belongs to its meaning — indigo for Persona's reasoning, amber
///     for a warning, mint for a result.
///  3. **Risk is still not colour-coded.** A green "safe" badge next to an orange
///     "risky" one teaches people to approve on colour alone. Stakes change the
///     words and the work, never the hue of the button.
enum PersonaPalette {

    // MARK: Brand

    /// Persona's indigo. The primary action, the active tab, the mark.
    static let brand = Color(hex: 0x4B3BEB)
    /// The darker end of the brand gradient, and pressed states.
    static let brandDeep = Color(hex: 0x3526C4)
    /// The lighter end. Highlights on the mark, glows.
    static let brandLight = Color(hex: 0x7C6DFF)
    /// A wash of brand behind content that belongs to Persona itself.
    static let brandTint = Color(hex: 0xEFEDFF)

    // MARK: Canvas and surfaces

    /// The page. Not pure white — a whisper of indigo in it, so that a pure-white
    /// card laid on top actually reads as lifted. White cards on a white page is
    /// the single fastest way to make an interface look unfinished.
    static let canvas = Color(hex: 0xFBFBFE)
    /// The default content block. A cool off-white with a trace of indigo in it,
    /// which is what stops a card looking like a dead grey rectangle.
    static let surface = Color(hex: 0xF6F6FC)
    /// A card that sits *above* the page rather than in it. Paired with `elevation`.
    static let surfaceRaised = Color.white
    /// A well inside a surface — icon tiles, avatars, quoted content.
    static let well = Color.white
    /// Hairlines and card borders.
    static let border = Color(hex: 0xE7E7F2)
    /// The same border one step darker, for controls that have to hold their own
    /// shape against the page rather than just divide content.
    static let borderStrong = Color(hex: 0xDCDCEC)

    // MARK: Text

    /// Deep navy rather than black. Pure black on white is harsh and reads cheap.
    static let ink = Color(hex: 0x11132E)
    static let inkSecondary = Color(hex: 0x5B6080)
    static let inkTertiary = Color(hex: 0x9BA0BE)
    static let inkInverted = Color.white

    // MARK: Semantic
    //
    // Outcome only. Each pairs a saturated tone with the tint it sits on.

    static let positive = Color(hex: 0x00B87C)
    static let positiveTint = Color(hex: 0xE4F8F1)

    static let negative = Color(hex: 0xF0405B)
    static let negativeTint = Color(hex: 0xFFECEF)

    static let caution = Color(hex: 0xF5A524)
    static let cautionTint = Color(hex: 0xFFF6E5)

    /// Quoted from Messages for the draft bubble. Not an accent this app owns.
    static let iMessage = Color(hex: 0x1D8CFF)

    // MARK: Gradients

    /// The primary action, the mark, anything that should feel lit from within.
    static let brandGradient = LinearGradient(
        colors: [Color(hex: 0x6B5BFF), Color(hex: 0x3E2CDB)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// The mark's sphere. Three stops so the highlight has somewhere to fall off to.
    static let markGradient = LinearGradient(
        colors: [Color(hex: 0x9B8CFF), Color(hex: 0x5140F0), Color(hex: 0x2E1FB8)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Under a chart or a timeline, fading to nothing.
    static func fade(_ color: Color) -> LinearGradient {
        LinearGradient(
            colors: [color.opacity(0.22), color.opacity(0.0)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

extension Color {
    /// Hex literals keep the palette readable as a palette. Every value in this
    /// file was picked as a colour, not derived from a system role.
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}
