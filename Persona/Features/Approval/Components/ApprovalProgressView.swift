import SwiftUI

/// In progress.
///
/// The mark itself becomes the activity indicator, so the screen does not sprout
/// a foreign spinner at the moment the user most wants to know that *Mira* is
/// the one doing the work. Cancel stays in the pinned bar for the whole window,
/// and the operation behind it is a real cancellable Task — not a timer the
/// interface pretends to stop.
struct ApprovalProgressView: View {
    let request: ApprovalRequest

    var body: some View {
        VStack(spacing: PersonaMetrics.spaceSection) {
            PersonaMark(size: 84, isWorking: true)
                .padding(.bottom, PersonaMetrics.spaceTight)

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
        .accessibilityLabel(title)
    }

    private var title: String {
        switch request.scenario {
        case .reservation: "Calling Bar Pitti"
        case .message: "Sending to Daniel"
        }
    }

    private var detail: String {
        switch request.scenario {
        case .reservation: "Asking for the later table. Nothing else about tonight changes."
        case .message: "Only the words you reviewed are going out."
        }
    }
}
