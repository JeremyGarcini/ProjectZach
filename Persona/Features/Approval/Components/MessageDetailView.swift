import SwiftUI

/// Who the message goes to, and the exact words that will arrive.
///
/// The draft is drawn as a real outgoing iMessage bubble rather than as body
/// text in a box. The point of the high-stakes screen is that this leaves
/// Persona and lands in someone's hand, so showing it in the form it will take
/// makes that concrete in a way a paragraph never does. The blue is quoted from
/// Messages; it is not an accent this app owns.
struct MessageDetailView: View {
    let proposal: MessageProposal
    /// The review sheet repeats this block, where the recipient is already
    /// established and the bubble should carry the screen on its own.
    var showsRecipient: Bool = true

    var body: some View {
        PersonaCard {
            if showsRecipient {
                recipient
                PersonaDivider()
            }
            bubble
        }
    }

    private var recipient: some View {
        HStack(spacing: PersonaMetrics.spaceSnug) {
            ContactAvatar(initials: proposal.recipientInitials)

            VStack(alignment: .leading, spacing: 2) {
                Text(proposal.recipient)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(PersonaPalette.ink)
                Text(proposal.relationship).personaRowLabel()
            }

            Spacer(minLength: PersonaMetrics.spaceTight)

            PersonaChip(text: "iMessage", symbol: "message.fill", tint: PersonaPalette.iMessage)
                .fixedSize()
        }
        .padding(PersonaMetrics.spaceRegular)
        .accessibilityElement(children: .combine)
    }

    private var bubble: some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack {
                Spacer(minLength: PersonaMetrics.spaceHeadline)

                Text(proposal.body)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, PersonaMetrics.spaceRegular)
                    .padding(.vertical, PersonaMetrics.spaceSnug)
                    .background(
                        LinearGradient(
                            colors: [PersonaPalette.iMessage, Color(hex: 0x0B6FE0)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        in: .rect(cornerRadius: 22, style: .continuous)
                    )
                    .personaGlow(PersonaPalette.iMessage, intensity: 0.35)
                    // The draft can change length when edited; morphing keeps the
                    // bubble from jumping.
                    .contentTransition(.interpolate)
            }

            Text("Not sent yet")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(PersonaPalette.inkTertiary)
        }
        .padding(PersonaMetrics.spaceRegular)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Draft message, not sent: \(proposal.body)")
    }
}
