import SwiftUI

/// What the reservation is, and precisely what changes about it.
///
/// The before/after is the crux of the decision, so it gets the most visual
/// weight in the card: the old time struck through in tertiary, an arrow in a
/// tinted disc, the new time in brand indigo, and the delta as a chip. Each part
/// keeps its intrinsic width with a trailing spacer taking up the slack, so the
/// pair never squeezes on a small iPhone or at large Dynamic Type sizes.
struct ReservationDetailView: View {
    let proposal: ReservationProposal

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        PersonaCard {
            venue
            PersonaDivider()
            change
        }
    }

    private var venue: some View {
        HStack(spacing: PersonaMetrics.spaceSnug) {
            // Warm, not indigo. Indigo is Persona speaking; this tile is the
            // restaurant, and giving each subject its own hue is what keeps the
            // screen from reading as one flat brand colour top to bottom.
            SymbolTile(systemName: "fork.knife", tint: PersonaPalette.caution)

            VStack(alignment: .leading, spacing: 2) {
                Text(proposal.venue)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(PersonaPalette.ink)
                Text(proposal.partyDescription).personaRowLabel()
            }

            Spacer(minLength: 0)
        }
        .padding(PersonaMetrics.spaceRegular)
        .accessibilityElement(children: .combine)
    }

    /// At accessibility text sizes the two times plus an arrow plus a chip cannot
    /// share a line without truncating, and a truncated time is worse than no
    /// comparison at all. So the row becomes two labelled lines instead.
    @ViewBuilder
    private var change: some View {
        if dynamicTypeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: PersonaMetrics.spaceSnug) {
                labelledTime("Booked now", proposal.originalTime, isNew: false)
                labelledTime("New time", proposal.requestedTime, isNew: true)
            }
            .padding(PersonaMetrics.spaceRegular)
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(changeDescription)
        } else {
            inlineChange
        }
    }

    private func labelledTime(_ label: String, _ time: String, isNew: Bool) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).personaRowLabel()
            Text(time)
                .personaFigure(isEmphasised: isNew)
                .foregroundStyle(isNew ? PersonaPalette.brand : PersonaPalette.inkTertiary)
                .strikethrough(!isNew, color: PersonaPalette.inkTertiary)
                .contentTransition(.numericText())
        }
    }

    private var inlineChange: some View {
        HStack(alignment: .center, spacing: PersonaMetrics.spaceSnug) {
            Text(proposal.originalTime)
                .personaFigure(isEmphasised: false)
                .strikethrough(true, color: PersonaPalette.inkTertiary)

            Image(systemName: "arrow.right")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(PersonaPalette.brand)
                .frame(width: 24, height: 24)
                .background(PersonaPalette.brand.opacity(0.10), in: .circle)
                .accessibilityHidden(true)

            Text(proposal.requestedTime)
                .personaFigure(isEmphasised: true)
                .foregroundStyle(PersonaPalette.brand)
                // Editing the time rolls the digits instead of swapping them,
                // which is what tells the user their edit landed.
                .contentTransition(.numericText())

            Spacer(minLength: PersonaMetrics.spaceTight)

            PersonaChip(text: proposal.delayDescription, tint: PersonaPalette.inkSecondary)
                .fixedSize()
        }
        .padding(PersonaMetrics.spaceRegular)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(changeDescription)
    }

    private var changeDescription: String {
        "Currently \(proposal.originalTime), moving to \(proposal.requestedTime), \(proposal.delayDescription) later"
    }
}
