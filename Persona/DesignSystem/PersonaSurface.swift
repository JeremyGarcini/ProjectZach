import SwiftUI

/// A card lifted off the page: white, hairline border, two-part shadow.
///
/// This is the default container. It holds rows separated by `PersonaDivider`,
/// one level deep — a card never contains another card.
struct PersonaCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                PersonaPalette.surfaceRaised,
                in: .rect(cornerRadius: PersonaMetrics.radiusSurface, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: PersonaMetrics.radiusSurface, style: .continuous)
                    .strokeBorder(PersonaPalette.border, lineWidth: 1)
            }
            .personaElevation(.card)
    }
}

/// A block tinted by what it means rather than lifted off the page.
///
/// Used where the content belongs to something — Persona's own reasoning is
/// indigo, a warning is amber. The tint is what carries the meaning, so these
/// carry no shadow and no border; they are part of the page, not on top of it.
struct PersonaTintedBlock<Content: View>: View {
    var tint: Color
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: 0) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                tint,
                in: .rect(cornerRadius: PersonaMetrics.radiusSurface, style: .continuous)
            )
    }
}

/// A hairline between rows, inset from the leading edge the way iOS insets list
/// separators so the rule starts under the content, not under the margin.
struct PersonaDivider: View {
    var inset: Double = PersonaMetrics.spaceRegular
    /// A divider inside a tinted block has to be tinted too — a neutral grey rule
    /// on a lavender wash reads as a mistake.
    var color: Color = PersonaPalette.border

    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 1)
            .padding(.leading, inset)
            .accessibilityHidden(true)
    }
}

/// A small tinted pill. The eyebrow above a title, a status, a tag.
///
/// It reads as a label rather than a badge because the tint is low-contrast and
/// the type is small — loud enough to find, quiet enough not to compete with the
/// sentence underneath it.
struct PersonaChip: View {
    let text: String
    var symbol: String?
    var tint: Color = PersonaPalette.brand

    var body: some View {
        HStack(spacing: 5) {
            if let symbol {
                Image(systemName: symbol)
                    .font(.system(size: 9, weight: .bold))
            }
            Text(text)
                .font(.system(size: 11, weight: .bold))
                .tracking(0.7)
                .textCase(.uppercase)
        }
        .foregroundStyle(tint)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(tint.opacity(0.12), in: .capsule)
        .accessibilityElement(children: .combine)
    }
}

/// A symbol on a tinted rounded tile. The subject of a card, never decoration.
struct SymbolTile: View {
    let systemName: String
    var tint: Color = PersonaPalette.brand
    var size: Double = 40

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(
                tint.opacity(0.12),
                in: .rect(cornerRadius: PersonaMetrics.radiusSmall, style: .continuous)
            )
            .accessibilityHidden(true)
    }
}

/// The monogram circle iOS uses for a contact without a photo, on a colour
/// derived from the name so the same person is always the same colour.
struct ContactAvatar: View {
    let initials: String
    var size: Double = 42

    private static let palette: [Color] = [
        Color(hex: 0x00B87C), Color(hex: 0x4B3BEB), Color(hex: 0xF5A524),
        Color(hex: 0xF0405B), Color(hex: 0x0EA5C6), Color(hex: 0x8B5CF6)
    ]

    private var tint: Color {
        let seed = initials.unicodeScalars.reduce(0) { $0 + Int($1.value) }
        return Self.palette[seed % Self.palette.count]
    }

    var body: some View {
        Circle()
            .fill(tint.gradient)
            .overlay {
                Text(initials)
                    .font(.system(size: size * 0.36, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .frame(width: size, height: size)
            .personaGlow(tint, intensity: 0.5)
            .accessibilityHidden(true)
    }
}

/// A row that reads as one sentence: a quiet coloured label, then the thing
/// itself underneath.
struct PersonaStatementRow<Content: View>: View {
    let label: String
    var symbol: String?
    var tint: Color = PersonaPalette.brand
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: PersonaMetrics.spaceTight) {
            HStack(spacing: 6) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.system(size: 11, weight: .bold))
                }
                Text(label)
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.7)
                    .textCase(.uppercase)
            }
            .foregroundStyle(tint)

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(PersonaMetrics.spaceRegular)
        .accessibilityElement(children: .combine)
    }
}

/// A Settings-style row: label on the left, value hugging the right.
struct PersonaValueRow<Value: View>: View {
    let label: String
    @ViewBuilder var value: Value

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: PersonaMetrics.spaceSnug) {
            Text(label).personaRowLabel()
            Spacer(minLength: PersonaMetrics.spaceTight)
            value.layoutPriority(1)
        }
        .padding(.horizontal, PersonaMetrics.spaceRegular)
        .padding(.vertical, 14)
        .accessibilityElement(children: .combine)
    }
}

/// The one warning. Amber tile, amber wash, and it never appears on a request
/// that does not deserve it — a warning on every screen is a warning nobody reads.
struct PersonaCautionRow: View {
    let text: String
    var symbol: String = "exclamationmark.triangle.fill"

    var body: some View {
        HStack(alignment: .top, spacing: PersonaMetrics.spaceSnug) {
            SymbolTile(systemName: symbol, tint: PersonaPalette.caution, size: 34)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(PersonaPalette.ink)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(PersonaMetrics.spaceRegular)
        .background(
            PersonaPalette.cautionTint,
            in: .rect(cornerRadius: PersonaMetrics.radiusSurface, style: .continuous)
        )
        .accessibilityElement(children: .combine)
    }
}
