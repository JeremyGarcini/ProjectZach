import SwiftUI

/// Done, declined, failed, or undone.
///
/// Every ending answers the same three questions in the same three positions:
/// what happened, what it means, and — in the pinned bar below — what you can
/// still do about it. Keeping the shape identical across four very different
/// outcomes is what makes the failure state feel handled rather than bolted on.
///
/// The result is centred on the bare page rather than inside a card. iOS reserves
/// this full-bleed, symbol-first treatment for completions — Apple Pay, AirDrop,
/// Wallet — and borrowing it makes the state read instantly.
struct ApprovalOutcomeView: View {
    let request: ApprovalRequest
    let stage: ApprovalStage

    var body: some View {
        VStack(spacing: PersonaMetrics.spaceSection) {
            emblem

            VStack(spacing: PersonaMetrics.spaceTight) {
                Text(title).personaOutcomeTitle()
                Text(detail)
                    .personaSubtitle()
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, PersonaMetrics.spaceGenerous)
        .accessibilityElement(children: .contain)
    }

    /// One symbol on a filled disc, wrapped in a halo of its own colour. It
    /// bounces once on arrival — enough to mark that something concluded, not
    /// enough to make anyone wait.
    private var emblem: some View {
        Image(systemName: symbol)
            .font(.system(size: 34, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 82, height: 82)
            .background(tint.gradient, in: .circle)
            .overlay {
                Circle().strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .white.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
            }
            // The halo is what stops the disc looking like a sticker.
            .padding(10)
            .background(tint.opacity(0.12), in: .circle)
            .personaGlow(tint, intensity: 0.8)
            .symbolEffect(.bounce, options: .nonRepeating)
            .accessibilityHidden(true)
    }

    // MARK: Copy
    //
    // Every string names the concrete thing that did or did not happen. "Action
    // completed" tells the user nothing; "Moved to 8:00 PM" tells them they can
    // stop thinking about it.

    private var title: String {
        switch (stage, request.scenario) {
        case (.succeeded, .reservation): reservationTitle
        case (.succeeded, .message): "Sent to Daniel"
        case (.declined, .reservation): "Dinner stays at 7:30 PM"
        case (.declined, .message): "Nothing sent"
        case (.failed, _): "Couldn’t send"
        case (.undone, .reservation): "Back to 7:30 PM"
        case (.undone, .message): "Message unsent"
        case (.awaiting, _), (.processing, _): ""
        }
    }

    private var reservationTitle: String {
        guard case .reservation(let proposal) = request.payload else { return "Dinner moved" }
        return "Moved to \(proposal.requestedTime)"
    }

    private var detail: String {
        switch (stage, request.scenario) {
        case (.succeeded, .reservation): "Bar Pitti has your table of four at the later time."
        case (.succeeded, .message): "He got exactly the words you approved."
        case (.declined, .reservation): "I didn’t call the restaurant, and I won’t raise it again tonight."
        case (.declined, .message): "The draft is still here if you change your mind."
        case (.failed, _): "Messages didn’t respond. Daniel heard nothing and your draft is untouched."
        case (.undone, .reservation): "I called back and restored the original booking."
        case (.undone, .message): "Recalled before it reached him."
        case (.awaiting, _), (.processing, _): ""
        }
    }

    private var symbol: String {
        switch stage {
        case .succeeded: "checkmark"
        case .declined: "hand.raised.fill"
        case .failed: "exclamationmark.triangle.fill"
        case .undone: "arrow.uturn.backward"
        case .awaiting, .processing: "circle"
        }
    }

    private var tint: Color {
        switch stage {
        case .succeeded: PersonaPalette.positive
        case .failed: PersonaPalette.negative
        case .declined: PersonaPalette.inkSecondary
        case .undone: PersonaPalette.brand
        case .awaiting, .processing: PersonaPalette.brand
        }
    }
}
