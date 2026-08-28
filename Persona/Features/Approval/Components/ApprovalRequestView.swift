import SwiftUI

/// The ask.
///
/// Hierarchy is the whole job. The title sits on the bare page at the largest
/// size on screen, so "Move dinner to 8:00 PM" is readable in about half a
/// second. Everything that supports the decision sits below it, and each block
/// is tinted by what it *is*: the subject of the request gets a lifted white
/// card, Persona's own reasoning gets an indigo wash, a consequence gets amber.
struct ApprovalRequestView: View {
    let request: ApprovalRequest

    var body: some View {
        VStack(alignment: .leading, spacing: PersonaMetrics.spaceSection) {
            headline
            detail
            rationale
            if let caution = request.caution {
                PersonaCautionRow(text: caution)
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var headline: some View {
        VStack(alignment: .leading, spacing: PersonaMetrics.spaceSnug) {
            PersonaChip(
                text: request.risk.label,
                symbol: request.risk.symbol,
                tint: request.risk.chipTint
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(request.title)
                    .personaHeroTitle()
                    // The title changes when the user edits the time, so it
                    // morphs rather than cutting.
                    .contentTransition(.interpolate)

                Text(request.subtitle).personaSubtitle()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    private var detail: some View {
        switch request.payload {
        case .reservation(let proposal):
            ReservationDetailView(proposal: proposal)
        case .message(let proposal):
            MessageDetailView(proposal: proposal)
        }
    }

    private var tintedRule: some View {
        PersonaDivider(inset: PersonaMetrics.spaceRegular, color: PersonaPalette.brand.opacity(0.10))
    }

    /// Persona's reasoning, in the order a person would ask for it: why now, then
    /// what you are going on. The indigo wash marks the whole block as Mira
    /// talking rather than as data about the request.
    private var rationale: some View {
        PersonaTintedBlock(tint: PersonaPalette.brandTint) {
            PersonaStatementRow(label: "Why now", symbol: "clock.fill") {
                Text(request.reason).personaRowValue()
            }

            if case .reservation(let proposal) = request.payload {
                tintedRule
                SignalTimelineView(signals: proposal.signals)
            }

            tintedRule

            PersonaStatementRow(label: "Based on", symbol: "quote.opening") {
                Text(request.evidence).personaRowValue()
            }
        }
    }
}
